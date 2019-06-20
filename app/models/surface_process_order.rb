class SurfaceProcessOrder < ProcessOrder

  # public instance method =====================================================
  def prepare_defalut
    material = production_detail.production.materials.first
    material ||= Material.new
    process_detail = production_detail.process_detail
    process_detail ||= ProcessDetail.new
    self.trader = process_detail.trader
    self.trader ||= Trander.new
    
    self.material = material.standard
    self.process = process_detail.name.to_s + process_detail.condition.to_s
    self.price = trader.addition_attr2 if (!trader.nil? && !trader.addition_attr2.blank?)
    self.price ||= I18n.t(:notice_process_price_matrix)
    self.delivery_ymd_add = trader.addition_attr1
  end

end