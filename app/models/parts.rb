class Parts
  include ValidationsAdapter
  include ActiveRecord::Validations

  # accessor ===================================================================
  attr_accessor :material
  attr_accessor :washer1
  attr_accessor :washer2
  
  attr_accessor :material_id
  attr_accessor :washer_id1
  attr_accessor :washer_id2

  attr_accessor :fix_flag
  
  attr_accessor :production
  attr_accessor :item
  attr_accessor :no_in_list
  
  attr_accessor :attributes
  
  validates_presence_of     :material_id
  
  # public instance method =====================================================
  def initialize
    @attributes ||= {}
  end
  
  def set_attributes(params = nil)
    return unless params

p params

    self.material_id = params[:material_id]
    @attributes['material_id'] = self.material_id
    unless self.material_id.blank?
      self.material = Material.find(self.material_id)
      self.material.calc_amount!
    end

    self.washer_id1 = params[:washer_id1]
    @attributes['washer_id1'] = self.washer_id1
    unless self.washer_id1.blank?
      self.washer1 = Washer.find(self.washer_id1)
      self.washer1.calc_amount!
    end

    self.washer_id2 = params[:washer_id2]
    @attributes['washer_id2'] = self.washer_id2
    unless self.washer_id2.blank?
      self.washer2 = Washer.find(self.washer_id2)
      self.washer2.calc_amount!
    end
    
    self.fix_flag = params[:fix_flag].to_i
    @attributes['fix_flag'] = self.fix_flag
  end

end
