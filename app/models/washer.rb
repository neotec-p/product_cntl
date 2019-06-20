class Washer < ActiveRecord::Base
  has_many :item_washer_seqs
  has_many :items, :through => :item_washer_seqs
  
  has_many :washer_production_seqs
  has_many :productions, :through => :washer_production_seqs
  
  has_many :washer_stocks
  has_many :washer_orders
  
  has_many :washer_unit_price_histories, :dependent => :delete_all

  validates_presence_of     :steel_class
  validates_length_of     :steel_class,  :maximum => 50  
  
  validates_presence_of     :diameter
  
  validates_length_of     :surface,  :maximum => 50, :allow_blank => true
  
  validates_numericality_of :unit_price
  
  before_save :adjust_start_date_and_end_data

  # accessor ===================================================================
  attr_accessor :excess_amount
  attr_accessor :stock_amount
  attr_accessor :planned_amount
  attr_accessor :orderd_amount
  attr_accessor :stock_price

  # public class method ========================================================
  def self.find_washer_price_by_target_date(washer_id, target_date)
    washer = nil
    
    washer = Washer.where(["id = ? and start_ymd <= ? and ? <= end_ymd", washer_id, target_date, target_date]).first
    washer ||= WasherUnitPriceHistory.where(["washer_id = ? and start_ymd <= ? and ? <= end_ymd", washer_id, target_date, target_date]).first
    
    unit_price = washer.unit_price unless washer.nil?
    unit_price ||= 0
    
    return unit_price
  end

  def self.select_options
    washers = self.all.order("steel_class asc, diameter asc, surface asc")
    
    options = Array.new( washers.size + 1, nil )
    options.each_index { |y|
      options[y] = Array.new( 2, 0 )
    }
    
    options[0][0] = ""
    options[0][1] = ''
    
    cnt = 1
    washers.each { |washer|
      opt = washer.steel_class + ' ' + washer.diameter.to_s + ' ' + washer.surface
      
      options[cnt][0] = opt
      options[cnt][1] = washer.id
      cnt += 1
    }
    
    return options
  end
  
  # public instance method =====================================================
  def disp_text
    text = steel_class
    text += " - " + diameter.to_s unless diameter.blank?
    text += " - " + surface unless surface.blank?
    
    return text
  end

  def disp_text_with_pai
    text = steel_class
    text += " " + I18n.t(:diameter_pai, :scope => [:activerecord, :attributes, :commons]) + diameter.to_s unless diameter.blank?
    text += " " + surface unless surface.blank?
    
    return text
  end
  
  def collect_flag_on
    self.collect_flag = FLAG_ON
  end

  def calc_amount!
    accept_quantities = 0 #入荷済量（pcs）
    adjust_quantities = 0 #残量調整（pcs）
    processed_quantities = 0 #使用済量（pcs）
    prepared_quantities = 0 #段取量（pcs）
    defective_quantities = 0 #不良重量（pcs）
    @planned_amount = 0 #使用予定量（pcs）

    #SUM（材料在庫.入荷量 - 材料在庫.残量調整（pcs）)
    current_washer_stocks = washer_stocks.where(
      ["collect_flag = ?", FLAG_OFF]
    )
    
    #-- 在庫データと紐づく生産データから算出
    ro1_process_type = ProcessType.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO1)

    current_washer_stocks.each{ |washer_stock|
      accept_quantities += washer_stock.accept_quantity
      adjust_quantities += washer_stock.adjust_quantity unless washer_stock.adjust_quantity.nil?
      
      #SUM(月別不良.重量) = 在庫量からは引かない
      #状態「不良」の生産データから引かれるため、２重計上を防ぐ
      defective_quantities += 0
      
      washer_stock.productions.each { |production|
        lot = production.lot
        item = production.item
        order = production.order
        
        planed_amount = 0 #RO1より前
        processed_amount = 0 #RO1以降
        
        production.production_details.each{ |production_detail|
          #RO1より前
          if ro1_process_type.seq > production_detail.process_type.seq
            planed_amount += production_detail.result_amount_production.to_i
          #RO1以降
          else
            processed_amount += production_detail.result_amount_production.to_i
          end
        }
        
        #- 使用予定量（ｋｇ）
        @planned_amount += planed_amount
        
        #- 使用済量（pcs）
        #ロットの重量が入力されていないやつ
        if lot.nil?
          #[投入予定（kg）]
          #SUM(注文.必要数量)
          #SUM(ヘッダー工程以降の実績重量最新)
          processed_quantities += processed_amount
  
        #ロット重量が入力されているやつ
        else
          #SUM(ロット.実質数量)
          #SUM(ヘッダー工程以降の実績重量最新)
          processed_quantities += processed_amount
        end
  
        #段取り量（pcs）
        #座金は考慮しない
      }
    }
    
    #-- 在庫に紐づいていない生産データから算出
    #   生産（締めてないやつだけ)
    conds  = " productions.summation_id IS NULL"
    conds += " and not exists "
    conds += " (select 1 from washer_stock_production_seqs where washer_stock_production_seqs.production_id = productions.id)"
    
    current_productions = productions.where(conds)
    
    current_productions.each { |production|
      lot = production.lot
      item = production.item
      order = production.order

      #ロット登録されていないやつ
      if lot.nil?
        #[投入予定（kg）]
        #SUM(注文.必要数量)
        if production.parts_fix_flag == FLAG_ON
          #SUM(生産.実質数量)
          @planned_amount += production.result_amount
        end

      #ロット登録されているやつ
      else
        #SUM(生産.実質数量)
        @planned_amount += production.result_amount
      end

      #段取り量（pcs）
      #座金は考慮しない
    }
    
    #[実在庫（kg）]
    #入荷済量（pcs） + 残量調整（pcs） - 使用済量（pcs） - 段取量（pcs） - 不良重量（pcs）
    @stock_amount = accept_quantities + adjust_quantities - processed_quantities - prepared_quantities - defective_quantities

    #[在庫金額（円）]
    #実在庫 * 材料.単価（円）
    @stock_price = @stock_amount * unit_price

    #[注文済（kg）]    
    #SUM(材料注文管理.注文数量（pcs）) - SUM(材料在庫.入荷量（pcs）)
    #SUM(完納じゃない座金注文管理.注文数量（pcs）) - SUM(完納じゃない座金注文管理に紐づく材料在庫.入荷量（pcs）)
    @orderd_amount = 0
    current_washer_orders = washer_orders.where(
      ["delivery_flag = ?", FLAG_OFF]
    )
    
    current_washer_orders.each{ |current_washer_order|
      current_orderd_amount = current_washer_order.order_quantity
      current_accept_amount = current_washer_order.washer_stocks.sum(
      :accept_quantity
      )
      current_orderd_amount = current_orderd_amount - current_accept_amount
      current_orderd_amount = 0 if current_orderd_amount < 0
      @orderd_amount += current_orderd_amount
    }

    #[過不足（kg）]
    @excess_amount = @stock_amount + @orderd_amount - @planned_amount
  end
  
  def adjust_start_date_and_end_data
    today = Date.today
    self.created_ymd = today

    if self.new_record?
      #初回データは、ずっと有効
      self.start_ymd = DEFAULT_START_YMD
      self.end_ymd = DEFAULT_END_YMD

    else
      #保存前のデータを取得
      org = Washer.find(id)

      #本日中のデータは履歴作成対象外
      return if org.created_ymd == today

      #有効開始日は今日
      self.start_ymd = Date.today

      #履歴データの保存
      history = WasherUnitPriceHistory.new()

      history.washer = org

      includes = ["unit_price", "start_ymd", "end_ymd", "created_ymd"]
      org.attributes.each_key {|key|
        next unless includes.include?(key)
        history[key] = org[key]
      }

      #履歴の有効終了日は１日前
      history.end_ymd = self.start_ymd - 1.days
  
      history.save!
    end
  end

  def deletable?
    if !washer_stocks.empty? || !washer_orders.empty?
      errors[:base] << I18n.t(:error_delete_relation)
      return false
    end
    
    return true
  end


  def self.available(cond_id, cond_steel_class, cond_diameter, cond_surface)
    conds = "1 = 1"
    conds_param = []

    if cond_id.present?
      conds += " AND id = ?"
      conds_param << cond_id
    end
    if cond_steel_class.present?
      conds += " AND steel_class LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_steel_class.strip)]
    end
    if cond_diameter.present?
      conds += " AND diameter LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_diameter.strip)]
    end
    if cond_surface.present?
      conds  += " and surface like ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_surface.strip)]
    end

    where([conds] + conds_param)
  end
end
