class PrintAll
  #include ValidationsAdapter
  include ActiveRecord::Validations

  @targets = []

  validate :target_any?

  # accessor ===================================================================
  
  # public instance method =====================================================
  def initialize
    @targets ||= []
  end
  
  def targets
    return @targets
  end
  
  # private instance method ====================================================
  def set_result_amount
    amount = 0
    production_details.each{ |production_detail|
      amount += production_detail.result_amount_production.to_i
    }
    self[:result_amount] = amount
  end

  def target_any?
    errors.add(:targets, :required_any_select) if @targets.empty?
  end
  
end
