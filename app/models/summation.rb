class Summation < ActiveRecord::Base
  belongs_to :summation_type
  belongs_to :asynchro_status
  belongs_to :user

  has_many :productions
  
  has_and_belongs_to_many :reports

  validates_presence_of     :summation_type_id
  validates_numericality_of :summation_type_id
  validates_presence_of     :asynchro_status_id
  validates_numericality_of :asynchro_status_id
  validates_presence_of     :target_ymd

  validates_presence_of     :user_id

  # public class method ========================================================
  # 締め処理対象月の初日を返す
  def self.get_current_month
    #月末締め処理のレコードがなければ、現在日時から見た先月の月初日
    today = (Date.today >> -1)
    target_ymd_month = Date::new(today.year, today.month, 1)

    #月末締め処理のレコードがあれば、最終レコードの翌月の月初日
    last_month = Summation.where(["summation_type_id = ? and asynchro_status_id = ?", SUMMATION_TYPE_MONTH, ASYNCHRO_STATUS_DONE]).maximum(:target_ymd)

    target_ymd_month = (last_month >> 1) unless last_month.nil?

    return target_ymd_month
  end
  
  # accessor ===================================================================

  # public instance method =====================================================

  private

# private instance method ====================================================

end
