class LotDiv < ProductionDiv

  attr_accessor :cur_result_amount
  attr_accessor :cur_status_id
  attr_accessor :cur_weight
  attr_accessor :cur_case

  attr_accessor :lot_exist_flag

  attr_accessor :new_result_amount
  attr_accessor :new_status_id
  attr_accessor :new_weight
  attr_accessor :new_case

  validates_presence_of :cur_result_amount
  validates_numericality_of :cur_result_amount, :allow_blank => true

  validates_presence_of :cur_status_id
  
  validates_presence_of :cur_weight, { :if => Proc.new {|x| x.lot_exist_flag == FLAG_ON } }
  validates_numericality_of :cur_weight, :allow_blank => true
  validates_presence_of :cur_case, { :if => Proc.new {|x| x.lot_exist_flag == FLAG_ON } }
  validates_numericality_of :cur_case, :allow_blank => true

  validates_presence_of :new_result_amount
  validates_numericality_of :new_result_amount, :allow_blank => true

  validates_presence_of :new_status_id
  
  validates_presence_of :new_weight, { :if => Proc.new {|x| x.lot_exist_flag == FLAG_ON } }
  validates_numericality_of :new_weight, :allow_blank => true
  validates_presence_of :new_case, { :if => Proc.new {|x| x.lot_exist_flag == FLAG_ON } }
  validates_numericality_of :new_case, :allow_blank => true
  
  # public instance method =====================================================
  def set_attributes(params = nil)
    super
    
    return unless params

    vals = params[get_model_name]

    self.lot_exist_flag = vals[:lot_exist_flag].to_i
    
    self.cur_result_amount = vals[:cur_result_amount]
    self.cur_status_id = vals[:cur_status_id]
    self.cur_weight = vals[:cur_weight]
    self.cur_case = vals[:cur_case]
    self.new_result_amount = vals[:new_result_amount]
    self.new_status_id = vals[:new_status_id]
    self.new_weight = vals[:new_weight]
    self.new_case = vals[:new_case]
  end

  def get_model_name
    return :lot_div
  end

  def cur_result_amount_before_type_cast
    return self.cur_result_amount
  end
  def cur_weight_before_type_cast
    return self.cur_weight
  end
  def cur_case_before_type_cast
    return self.cur_case
  end
  def new_result_amount_before_type_cast
    return self.new_result_amount
  end
  def new_weight_before_type_cast
    return self.new_weight
  end
  def new_case_before_type_cast
    return self.new_case
  end

end
