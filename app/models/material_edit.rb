class MaterialEdit
  include ValidationsAdapter
  include ActiveRecord::Validations

  validates_numericality_of :material_stock_id1, :allow_blank => true
  validates_numericality_of :material_stock_id2, :allow_blank => true
  validates_numericality_of :material_stock_id3, :allow_blank => true

  # accessor ===================================================================
  attr_accessor :material_id
  attr_accessor :material_stock_id1
  attr_accessor :material_stock_id2
  attr_accessor :material_stock_id3

  attr_accessor :production_lock_version

  # public instance method =====================================================
  def set_attributes(params = nil)
    return unless params

    vals = params[:material_edit]

    self.material_id = vals[:material_id]
    self.material_stock_id1 = vals[:material_stock_id1]
    self.material_stock_id2 = vals[:material_stock_id2]
    self.material_stock_id3 = vals[:material_stock_id3]
    
    self.production_lock_version = vals[:production_lock_version]
  end

  def material_stock_id1_before_type_cast
    return self.material_stock_id1
  end

  def material_stock_id2_before_type_cast
    return self.material_stock_id2
  end

  def material_stock_id3_before_type_cast
    return self.material_stock_id3
  end

  validate :material_stock_exist?

  # private instance method ====================================================
  def material_stock_exist?
    unless material_stock_id1.blank?
      if material_id.blank?
        errors.add(:material_id, :empty)
      else
        errors.add(:material_stock_id1, :not_exist) unless material_stock_exist_core?(material_stock_id1)
      end
    end
    unless material_stock_id2.blank?
      if material_id.blank?
        errors.add(:material_id, :empty)
      else
        errors.add(:material_stock_id2, :not_exist) unless material_stock_exist_core?(material_stock_id2)
      end
    end
    unless material_stock_id3.blank?
      if material_id.blank?
        errors.add(:material_id, :empty)
      else
        errors.add(:material_stock_id3, :not_exist) unless material_stock_exist_core?(material_stock_id3)
      end
    end
  end

  def material_stock_exist_core?(material_stock_id)
    material_stock = MaterialStock.where(["id = ? and material_id = ?", material_stock_id, material_id]).first
    return !(material_stock.nil?)
  end

end
