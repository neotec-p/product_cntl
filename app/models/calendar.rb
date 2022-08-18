class Calendar < ActiveRecord::Base
  validates_numericality_of :year
  validates_numericality_of :month
  validates_numericality_of :day
  
  validate :valid_date?
  
  # public class method ========================================================
  def self.find_by_ymd(year, month, day)
    self.where(["year = ? and month = ? and day = ?", year, month, day]).first
  end
  
  def self.holiday?(date)
    calendar = self.find_by_ymd(date.year, date.month, date.day)
    
    return false if calendar.nil?
    
    return !calendar.holiday.blank?
  end
  
  def self.count_working_days(start_date, end_date)
    return 0 if (start_date.blank? || end_date.blank?)
    
    conds = ""
    cond_params = []
    
    conds += "? <= CONCAT(calendars.year, LPAD(calendars.month, 2, '0'), LPAD(calendars.day, 2, '0'))"
    conds += " and CONCAT(calendars.year, LPAD(calendars.month, 2, '0'), LPAD(calendars.day, 2, '0')) <= ?"
    conds += " and (calendars.holiday IS NULL or calendars.holiday = '')"

    pram  = start_date.year.to_s.rjust(4, "0")
    pram += start_date.month.to_s.rjust(2, "0")
    pram += start_date.day.to_s.rjust(2, "0")
    cond_params << pram

    pram  = end_date.year.to_s.rjust(4, "0")
    pram += end_date.month.to_s.rjust(2, "0")
    pram += end_date.day.to_s.rjust(2, "0")
    cond_params << pram
    
    days = self.where([conds] + cond_params)
    
    return days.size
  end
 
  # accessor ===================================================================

  # public instance method =====================================================
  def disp_text
    date = Date::new(self.year, self.month, self.day)
    
    return I18n.l date
  end
  
  def conv_date
    date = nil
    begin
      date = Date::new(self.year, self.month, self.day)
    rescue
      # do nothing
    end
    
    return date
  end

  def holiday?
    return !self.holiday.blank?
  end

  private

  # private instance method ====================================================
  def valid_date?
    begin
      date = Date::new(self.year, self.month, self.day)
      return true
    rescue
      # do nothing
    end
    
    msg = "year:" + year.to_s + "  month:" + month.to_s + "  day:" + day.to_s
    errors[:base] << I18n.t(:error_valid_format, :msg => msg)
  end
 
end
