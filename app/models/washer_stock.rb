class WasherStock < ActiveRecord::Base
  belongs_to :washer
  belongs_to :washer_order

  has_many :washer_stock_production_seqs
  has_many :productions, :through => :washer_stock_production_seqs
  
  has_many :defective_washer_stock_seqs
  has_many :defectives, :through => :defective_washer_stock_seqs

  validates_presence_of     :accept_quantity
  validates_numericality_of :accept_quantity, :allow_blank => true

  validates_presence_of     :accept_ymd

  validates_numericality_of :adjust_quantity, :allow_blank => true

  before_create :set_default
  
  # public class method ========================================================

  # accessor ===================================================================
  attr_accessor :no_in_list
  attr_accessor :select_print

  attr_accessor :excess_amount
  attr_accessor :stock_amount
  attr_accessor :stock_price

  # public instance method =====================================================
  def disp_print_flag
    if collect_flag == FLAG_OFF
        return I18n.t :status_stock
    else
        return I18n.t :status_stock_finish
    end
  end
  
  def collect_flag_on
    self.collect_flag = FLAG_ON
  end

  def calc_amount!
    processed_quantities = 0 #使用済量（pcs）
    prepared_quantities = 0 #段取量（pcs）
    defective_quantities = 0 #不良重量（pcs）
    
    @stock_amount = 0
    @excess_amount = 0
    @stock_price = 0
    
    return if self.collect_flag == FLAG_ON
    
    #使用済量（pcs）と段取量（pcs）
    ro1_process_type = ProcessType.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO1)

    productions.each { |production|
      lot = production.lot
      item = production.item
      order = production.order
      
      processed_amount = 0 #RO1以降
      
      production.production_details.each{ |production_detail|
        #RO1より前
        if ro1_process_type.seq > production_detail.process_type.seq
          # do nothing
        #RO1以降
        else
          processed_amount += production_detail.result_amount_production.to_i
        end
      }
      
      #ロットの重量が入力されていないやつ
      if lot.nil?
        #SUM(RO1工程以降の実績重量最新)
        processed_quantities += processed_amount

      #ロット重量が入力されているやつ
      else
        #SUM(RO1工程以降の実績重量最新)
        processed_quantities += processed_amount
      end

      #段取り量（pcs）
      #座金は考慮しない
    }

    #SUM(月別不良.数量) = 在庫量からは引かない
    #状態「不良」の生産データから引かれるため、２重計上を防ぐ
    defective_quantities = 0
    
    #[残量（pcs）]
    #入荷済量（pcs） - 使用済量（pcs） - 段取量（pcs） - 不良重量（pcs）
    @stock_amount = accept_quantity.to_f - processed_quantities - prepared_quantities - defective_quantities

    #[実残量（pcs）]
    #残量（pcs） + 残量調整（pcs）
    @excess_amount = @stock_amount + adjust_quantity.to_f
    
    #[在庫金額（円）]
    #実在庫 * 材料.単価（円）
    unit_price = washer.unit_price unless washer.nil?
    unit_price ||= 0
    @stock_price = @excess_amount * unit_price
  end
  
  def deletable?
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
    self.collect_flag = FLAG_OFF
  end

end
