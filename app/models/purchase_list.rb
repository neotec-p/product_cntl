class PurchaseList < SearchCondDateFromTo
  validates_presence_of     :cond_date_from
  validates_presence_of     :cond_date_to

  validates_date_compare_of :cond_date_to, :type => :future_than_or_equal_to, :compare_to => 'cond_date_from'

  validate :target_any?

  # accessor ===================================================================
  
  # public instance method =====================================================
  def initialize
    super
    @targets ||= []
  end
  
  def targets
    return @targets
  end
  
  def targets=(targets)
    @targets = targets
  end
  
  # private instance method ====================================================
  def target_any?
    errors[:base] << I18n.t(:notice_empty) if @targets.empty?
  end


end
