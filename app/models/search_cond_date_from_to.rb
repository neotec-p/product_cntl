require 'validations_adapter'

class SearchCondDateFromTo
  include ValidationsAdapter
  include ActiveRecord::Validations

  # public class method ========================================================

  # accessor ===================================================================
  attr_accessor :attributes
  
  attr_accessor :cond_date_from
  attr_accessor :cond_date_to

  # public instance method =====================================================
  def initialize
    @attributes ||= {}
  end
  
  def set_attributes(params = nil)
    return unless params
    return unless params[:search_cond_date_from_to]
    
    vals = params[:search_cond_date_from_to]

    self.cond_date_from = conv_date(:cond_date_from, vals)
    @attributes[:cond_date_from] = self.cond_date_from
    self.cond_date_to = conv_date(:cond_date_to, vals)
    @attributes[:cond_date_to] = self.cond_date_to
  end

  private

  # private instance method ====================================================
  def conv_date(attr_name, params = nil)
    return unless params
    val = nil
    date = params[attr_name].to_s.gsub("/", "-")
    begin
      val = Date.strptime(date, "%Y-%m-%d")
    rescue
      val = nil
    end
    return val
  end

end
