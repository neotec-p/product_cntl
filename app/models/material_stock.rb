class MaterialStock < ActiveRecord::Base
  belongs_to :material
  belongs_to :material_order

  has_and_belongs_to_many :reports

  has_many :material_stock_production_seqs
  has_many :productions, :through => :material_stock_production_seqs
  
  has_many :defective_material_stock_seqs
  has_many :defectives, :through => :defective_material_stock_seqs

  validates_presence_of     :accept_weight
  validates_numericality_of :accept_weight, :allow_blank => true

  validates_presence_of     :accept_ymd

  validates_numericality_of :adjust_weight, :allow_blank => true

  before_create :set_default

  scope :date_range_of_accept_ymd, ->(first_date, last_date) { where("accept_ymd >= ? AND accept_ymd <= ?", first_date, last_date) }
  # Ex:- scope :active, -> {where(:active => true)}
  
  # public class method ========================================================

  # accessor ===================================================================
  attr_accessor :no_in_list
  attr_accessor :select_print

  attr_accessor :excess_amount
  attr_accessor :stock_amount
  attr_accessor :stock_price

  attr_accessor :price

  # public instance method =====================================================
  def disp_print_flag
    if print_flag.blank? || (print_flag == FLAG_OFF)
      return I18n.t :status_print_yet
    elsif (print_flag == FLAG_ON) && (collect_flag == FLAG_OFF)
      return I18n.t :status_print_done
    else
      return I18n.t :status_print_collect
    end
  end
  
  def collect_flag_on
    self.collect_flag = FLAG_ON
  end

  def calc_amount!
    processed_weights = 0 #使用済量（ｋｇ）
    prepared_weights = 0 #段取量（ｋｇ）
    defective_weights = 0 #不良重量（ｋｇ）
    
    @stock_amount = 0
    @excess_amount = 0
    @stock_price = 0
    
    return if self.collect_flag == FLAG_ON
    
    #使用済量（ｋｇ）と段取量（ｋｇ）
    hd_process_type = ProcessType.find_by_plan_process_flag(PLAN_PROCESS_FLAG_HD)
    
    productions.each { |production|
      lot = production.lot
      item = production.item
      order = production.order
      
      processed_amount = 0 #ヘッダー以降
      
      production.production_details.each{ |production_detail|
        #ヘッダーより前
        if hd_process_type.seq > production_detail.process_type.seq
          # do nothing
        #ヘッダー以降
        else
          processed_amount += production_detail.result_amount_production.to_i
        end
      }
      
      #ロットの重量が入力されていないやつ
      if lot.nil? || lot.weight.blank?
        #SUM(ヘッダー工程以降の実績重量最新) * 品目.重量（ｋｇ）
        processed_weights += processed_amount * item.weight

      #ロット重量が入力されているやつ
      else
        #SUM(ロット.実質数量)
        #理論値計算を加算するやつ
        if item.logical_weight_flag == FLAG_ON
          #SUM(ヘッダー工程以降の実績重量最新) * 品目.重量（ｋｇ）
          processed_weights += processed_amount * item.weight
        #実績重量を加算するやつ
        else
          processed_weights += lot.weight
        end
      end

      #段取り量（ｋｇ）
      prepared_weights += production.production_details.sum(
      :defectiveness_amount
      )
    }

    #SUM(月別不良.重量) = 在庫量からは引かない
    #状態「不良」の生産データから引かれるため、２重計上を防ぐ
    defective_weights = 0
    
    #[残量（kg）]
    #入荷済量（ｋｇ） - 使用済量（ｋｇ） - 段取量（ｋｇ） - 不良重量（ｋｇ）
    @stock_amount = accept_weight.to_f - processed_weights - prepared_weights - defective_weights

    #[実残量（kg）]
    #残量（kg） + 残量調整（kg）
    @excess_amount = @stock_amount + adjust_weight.to_f
    
    #[在庫金額（円）]
    #実在庫 * 材料.単価（円）
    unit_price = material.unit_price unless material.nil?
    unit_price ||= 0
    @stock_price = @excess_amount * unit_price
  end
  
  def deletable?
    if print_flag == FLAG_ON
      errors[:base] << I18n.t(:error_delete_relation)
      return false
    end
    
    unless productions.empty?
      errors[:base] << I18n.t(:error_delete_relation)
      return false
    end
    
    unless defectives.empty?
      errors[:base] << I18n.t(:error_delete_relation)
      return false
    end
    
    return true
  end

  private
  # private instance method ====================================================
  def set_default
    self.print_flag = FLAG_OFF
    self.collect_flag = FLAG_OFF
  end

end
