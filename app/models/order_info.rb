require 'validations_adapter'

class OrderInfo
  include ValidationsAdapter
  include ActiveRecord::Validations

  attr_accessor :order_no
  attr_accessor :order_ymd

  validates_presence_of :order_no
  validates_alphanumeric_of :order_no

  validates_presence_of :order_ymd

  def set_attributes(params = nil)
    return unless params

    vals = params[:order_info]

    begin
      self.order_ymd = Date.strptime(vals[:order_ymd], "%Y/%m/%d")
    rescue
      self.order_ymd = nil
    end

    self.order_no = vals[:order_no]
  end

end
