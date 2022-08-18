class AdditionProcessOrder < ProcessOrder

  # public instance method =====================================================
  def prepare_defalut
    material = production_detail.production.materials.first
    material ||= Material.new
    process_detail = production_detail.process_detail
    process_detail ||= ProcessDetail.new
    self.trader = process_detail.trader
    self.trader ||= Trander.new
    
    self.material = material.standard
    self.process = process_detail.name.to_s
    self.price = process_detail.condition.to_s
    self.delivery_ymd_add = trader.addition_attr1
  end

end