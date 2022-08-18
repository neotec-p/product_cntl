class ProcessExpense < ActiveRecord::Base
  belongs_to :item

  has_many :process_expense_histories

  validates_numericality_of :hd, :allow_blank => true
  validates_numericality_of :barrel, :allow_blank => true
  validates_numericality_of :hd_addition, :allow_blank => true
  validates_numericality_of :ro1, :allow_blank => true
  validates_numericality_of :ro1_addition, :allow_blank => true
  validates_numericality_of :ro2, :allow_blank => true
  validates_numericality_of :ro2_addition, :allow_blank => true
  validates_numericality_of :heat, :allow_blank => true
  validates_numericality_of :heat_addition, :allow_blank => true
  validates_numericality_of :surface, :allow_blank => true
  validates_numericality_of :surface_addition, :allow_blank => true
  validates_numericality_of :inspection, :allow_blank => true
  validates_numericality_of :inspection_addition, :allow_blank => true

  validates_numericality_of :ratio_hd, :allow_blank => true
  validates_numericality_of :ratio_barrel, :allow_blank => true
  validates_numericality_of :ratio_ro1, :allow_blank => true
  validates_numericality_of :ratio_ro2, :allow_blank => true
  validates_numericality_of :ratio_heat, :allow_blank => true
  validates_numericality_of :ratio_surface, :allow_blank => true

  before_save :prepare_save

  # public class method ========================================================
  def self.find_by_target_date(item_id, target_date)
    process_expense = nil

p "item_id",item_id
p "target_date", target_date
    
    process_expense = ProcessExpense.where(["item_id = ? and start_ymd <= ? and ? <= end_ymd", item_id, target_date, target_date]).first
    process_expense ||= ProcessExpenseHistory.where(["item_id = ? and start_ymd <= ? and ? <= end_ymd", item_id, target_date, target_date]).first
    
    return process_expense
  end

  # accessor ===================================================================
  attr_accessor :sum_ratio
  # public instance method =====================================================
  def sum_ratio
    return self.ratio_hd.to_i + self.ratio_barrel.to_i + self.ratio_ro1.to_i + self.ratio_ro2.to_i + self.ratio_heat.to_i + self.ratio_surface.to_i
  end

  private

  # private instance method ====================================================
  def prepare_save
    calc_value
    adjust_start_date_and_end_data
  end

  def calc_value
    process_ratio = ProcessRatio.first

    self.ratio_hd = 0
    self.ratio_barrel = 0
    self.ratio_ro1 = 0
    self.ratio_ro2 = 0
    self.ratio_heat = 0
    self.ratio_surface = 0

    self.hd = 0
    self.barrel = 0
    self.ro1 = 0
    self.ro2 = 0
    self.heat = 0
    self.surface = 0

    if ratio_process?(RATIO_FLAG_HD)
    self.ratio_hd = process_ratio.hd
    end
    if ratio_process?(RATIO_FLAG_BARREL)
    self.ratio_barrel = process_ratio.barrel
    end
    if ratio_process?(RATIO_FLAG_RO1)
    self.ratio_ro1 = process_ratio.ro1
    end
    if ratio_process?(RATIO_FLAG_RO2)
    self.ratio_ro2 = process_ratio.ro2
    end
    if ratio_process?(RATIO_FLAG_HEAT)
    self.ratio_heat = process_ratio.heat
    end
    if ratio_process?(RATIO_FLAG_SURFACE)
    self.ratio_surface = process_ratio.surface
    end

    self.inspection = (item.price * process_ratio.conf_inspection)

    additions = self.hd_addition.to_f + self.ro1_addition.to_f + self.ro2_addition.to_f + self.heat_addition.to_f + self.surface_addition.to_f + self.inspection_addition.to_f
    price = item.price - self.inspection - additions

    tmp_sum_ratio = sum_ratio
    
    if tmp_sum_ratio > 0
      self.hd = price * self.ratio_hd / tmp_sum_ratio
      self.barrel = price * self.ratio_barrel / tmp_sum_ratio
      self.ro1 = price * self.ratio_ro1 / tmp_sum_ratio
      self.ro2 = price * self.ratio_ro2 / tmp_sum_ratio
      self.heat = price * self.ratio_heat / tmp_sum_ratio
      self.surface = price * self.ratio_surface / tmp_sum_ratio
    end
  end

  def ratio_process?(ratio_type)
    process_detail = item.process_details.includes(:process_type).where(process_types: { ratio_flag: ratio_type}).first
    return false if process_detail.nil?

    return !process_detail.name.blank?
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
      org = ProcessExpense.find(id)

      #本日中のデータは履歴作成対象外
      return if org.created_ymd == today

      #有効開始日は今日
      self.start_ymd = Date.today

      #履歴データの保存
      history = ProcessExpenseHistory.new()

      history.process_expense = org

      exclusions = ["id", "lock_version", "created_at", "updated_at"]
      org.attributes.each_key {|key|
        next if exclusions.include?(key)
        history[key] = org[key]
      }

      #履歴の有効終了日は１日前
      history.end_ymd = self.start_ymd - 1.days
  
      history.save!
    end
  end

end
