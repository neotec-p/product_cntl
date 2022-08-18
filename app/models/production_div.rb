class ProductionDiv
  include ValidationsAdapter
  include ActiveRecord::Validations

  validates_presence_of :new_branch1_no
  validates_numericality_of :new_branch1_no, :allow_blank => true

  validates_presence_of :new_branch2_no
  validates_numericality_of :new_branch2_no, :allow_blank => true
  
  # accessor ===================================================================
  attr_accessor :vote_no
  
  attr_accessor :new_branch1_no
  attr_accessor :new_branch2_no

  attr_accessor :production_lock_version

  # public instance method =====================================================
  def set_attributes(params = nil)
    return unless params

    vals = params[get_model_name]

    self.new_branch1_no = vals[:new_branch1_no]
    self.new_branch2_no = vals[:new_branch2_no]

    self.vote_no = vals[:vote_no]
    self.production_lock_version = vals[:production_lock_version]
    
    return
  end

  def get_model_name
    return :production_div
  end

  def new_branch1_no_before_type_cast
    return self.new_branch1_no
  end
  def new_branch2_no_before_type_cast
    return self.new_branch2_no
  end
  
  validate :product_exist?

  # private instance method ====================================================
  def product_exist?
    unless (new_branch1_no.blank? || new_branch2_no.blank?)
      production = Production.find_by_vote_no_and_branch_nos(vote_no, new_branch1_no, new_branch2_no)
      unless production.nil?
        errors.add(:new_branch1_no, :taken)
        errors.add(:new_branch2_no, :taken)
      end
    end
  end

end