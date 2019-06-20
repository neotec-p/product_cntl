class Material < ActiveRecord::Base
  has_many :item_material_seqs
  has_many :items, :through => :item_material_seqs
  
  has_many :material_production_seqs
  has_many :productions, :through => :material_production_seqs
  
  has_many :material_stocks
  has_many :material_orders
  
  has_many :material_unit_price_histories, :dependent => :delete_all

  validates_presence_of     :standard
  validates_length_of     :standard,  :maximum => 50  
  
  validates_presence_of     :diameter
  validates_numericality_of :diameter
  
  validates_length_of     :surface,  :maximum => 50, :allow_blank => true

  validates_presence_of     :unit_price
  validates_numericality_of :unit_price, :allow_blank => true
  
  before_save :adjust_start_date_and_end_data

  # public class method ========================================================
  def self.find_material_price_by_target_date(material_id, target_date)
    material = nil
    
    material = Material.where(["id = ? and start_ymd <= ? and ? <= end_ymd", material_id, target_date, target_date]).first
    material ||= MaterialUnitPriceHistory.where(["material_id = ? and start_ymd <= ? and ? <= end_ymd", material_id, target_date, target_date]).first
    
    unit_price = material.unit_price unless material.nil?
    unit_price ||= 0
    
    return unit_price
  end

  def self.select_options
    materials = self.all.order("standard asc, diameter asc, surface asc")
    
    options = Array.new( materials.size + 1, nil )
    options.each_index { |y|
      options[y] = Array.new( 2, 0 )
    }
    
    options[0][0] = I18n.t(:notice_select) #'選択してください'
    options[0][1] = ''
    
    cnt = 1
    materials.each { |material|
      opt = material.standard.to_s + " - " + material.diameter.to_s + " - " + material.surface.to_s
      
      options[cnt][0] = opt
      options[cnt][1] = material.id
      cnt += 1
    }
    
    return options
  end
  
  # accessor ===================================================================
  attr_accessor :excess_amount
  attr_accessor :stock_amount
  attr_accessor :planned_amount
  attr_accessor :orderd_amount
  attr_accessor :stock_price

  # public instance method =====================================================
  def disp_text
    text = standard
    text += " - " + diameter.to_s unless diameter.blank?
    text += " - " + surface unless surface.blank?
    
    return text
  end
  
  def disp_text_with_pai
    text = standard
    text += " " + I18n.t(:diameter_pai, :scope => [:activerecord, :attributes, :commons]) + diameter.to_s unless diameter.blank?
    text += " " + surface unless surface.blank?
    
    return text
  end
  
  def calc_amount!
    accept_weights = 0 #入荷済量（ｋｇ）
    adjust_weights = 0 #残量調整（ｋｇ）
    processed_weights = 0 #使用済量（ｋｇ）
    prepared_weights = 0 #段取量（ｋｇ）
    defective_weights = 0 #不良重量（ｋｇ）
    @planned_amount = 0 #使用予定量（ｋｇ）

    #SUM（材料在庫.入荷量 - 材料在庫.残量調整（ｋｇ）)
    current_material_stocks = material_stocks.where(
      ["collect_flag = ?", FLAG_OFF]
    )
    
    #-- 在庫データと紐づく生産データから算出
    hd_process_type = ProcessType.find_by_plan_process_flag(PLAN_PROCESS_FLAG_HD)

    current_material_stocks.each{ |material_stock|
      accept_weights += material_stock.accept_weight
      adjust_weights += material_stock.adjust_weight unless material_stock.adjust_weight.nil?
      
      #- 不良重量（ｋｇ） = 在庫量からは引かない
      #状態「不良」の生産データから引かれるため、２重計上を防ぐ
      defective_weights += 0

      material_stock.productions.each{ |production|
        lot = production.lot
        item = production.item
        order = production.order
        
        planed_amount = 0 #ヘッダーより前
        processed_amount = 0 #ヘッダー以降
        
        production.production_details.each{ |production_detail|
          #ヘッダーより前
          if hd_process_type.seq > production_detail.process_type.seq
            planed_amount += production_detail.result_amount_production.to_i
          #ヘッダー以降
          else
            processed_amount += production_detail.result_amount_production.to_i
          end
        }
        
        #- 使用予定量（ｋｇ）
        @planned_amount += planed_amount * item.weight
        
        #- 使用済量（ｋｇ）
        #ロットの重量が入力されていないやつ
        if lot.nil? || lot.weight.blank?
          #SUM(ヘッダー工程以降の実績重量最新) * 品目.重量（ｋｇ）
          processed_weights += processed_amount * item.weight
  
        #ロット重量が入力されているやつ
        else
          #SUM( SUM(ヘッダー工程以降の実績重量最新) * 品目.重量（ｋｇ） )
          #理論値計算を加算するやつ
          if item.logical_weight_flag == FLAG_ON
            #SUM(ヘッダー工程以降の実績重量最新) * 品目.重量（ｋｇ）
            processed_weights += processed_amount * item.weight
          #実績重量を加算するやつ
          else
            processed_weights += lot.weight
          end
        end

        #- 段取り量（ｋｇ）
        prepared_weights += production.production_details.sum(
        :defectiveness_amount
        )
      }
    }
    
    #-- 在庫に紐づいていない生産データから算出
    #   生産（締めてないやつだけ)
    conds  = " productions.summation_id IS NULL"
    conds += " and not exists "
    conds += " (select 1 from material_stock_production_seqs where material_stock_production_seqs.production_id = productions.id)"
    
    current_productions = productions.where(conds)
    
    current_productions.each { |production|
      lot = production.lot
      item = production.item
      order = production.order
      
      #ロットの重量が入力されていないやつ
      if lot.nil? || lot.weight.blank?
        #[投入予定（kg）]
        #SUM(注文.必要数量 * 品目.重量（ｋｇ）)
        if production.parts_fix_flag == FLAG_ON
          #生産の実績重量 * 品目.重量（ｋｇ）
          @planned_amount += production.result_amount.to_i * item.weight
        end

      #ロット重量が入力されているやつ
      else
        #SUM(ロット.実質数量)
        #理論値計算を加算するやつ
        if item.logical_weight_flag == FLAG_ON
          #生産の実績重量 * 品目.重量（ｋｇ）
          @planned_amount += production.result_amount.to_i * item.weight
        #実績重量を加算するやつ
        else
          @planned_amount += lot.weight
        end
      end

      #段取り量（ｋｇ）
      prepared_weights += production.production_details.sum(
      :defectiveness_amount
      )
    }
    
    #[実在庫（kg）]
    #入荷済量（ｋｇ） + 残量調整（ｋｇ） - 使用済量（ｋｇ） - 段取量（ｋｇ） - 不良重量（ｋｇ）
    @stock_amount = accept_weights + adjust_weights - processed_weights - prepared_weights - defective_weights

    #[在庫金額（円）]
    #実在庫 * 材料.単価（円）
    @stock_price = @stock_amount * unit_price

    #[注文済（kg）]
    #SUM(完納じゃない材料注文管理.注文数量（ｋｇ）) - SUM(完納じゃない材料注文管理に紐づく材料在庫.入荷量（ｋｇ）)
    @orderd_amount = 0
    current_material_orders = material_orders.where(
      ["delivery_flag = ?", FLAG_OFF]
    )
    
    current_material_orders.each{ |current_material_order|
      current_orderd_amount = current_material_order.order_weight
      current_accept_amount = current_material_order.material_stocks.sum(
      :accept_weight
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
      org = Material.find(id)

      #本日中のデータは履歴作成対象外
      return if org.created_ymd == today

      #有効開始日は今日
      self.start_ymd = Date.today

      #履歴データの保存
      history = MaterialUnitPriceHistory.new()

      history.material = org

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
    if !material_stocks.empty? || !material_orders.empty?
      errors[:base] << I18n.t(:error_delete_relation)
      return false
    end
    
    return true
  end

  def self.available(cond_id, cond_standard, cond_diameter, cond_surface)
    conds = "1 = 1"
    conds_param = []

    if cond_id.present?
      conds += " AND id = ?"
      conds_param << cond_id
    end
    if cond_standard.present?
      conds += " AND standard LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_standard.strip)]
    end
    if cond_diameter.present?
      conds += " AND diameter = ?"
      conds_param << cond_diameter
    end
    if cond_surface.present?
      conds  += " AND surface LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_surface.strip)]
    end

    where([conds] + conds_param)
  end
end
