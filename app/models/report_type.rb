class ReportType < ActiveRecord::Base
  has_many :reports

  # public class method ========================================================
  def self.report_name(code)
    report_type = self.find_by_code(code)
    
    name = ""
    name = report_type.name unless report_type.nil?
    
    return name
  end

  # accessor ===================================================================

  # public instance method =====================================================

  private

  # private instance method ====================================================

end
