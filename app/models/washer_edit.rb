class WasherEdit
  include ValidationsAdapter
  include ActiveRecord::Validations

  validates_numericality_of :washer_stock_id1, :allow_blank => true
  validates_numericality_of :washer_stock_id2, :allow_blank => true
  validates_numericality_of :washer_stock_id3, :allow_blank => true
  validates_numericality_of :washer_stock_id4, :allow_blank => true
  validates_numericality_of :washer_stock_id5, :allow_blank => true
  validates_numericality_of :washer_stock_id6, :allow_blank => true

  # accessor ===================================================================
  attr_accessor :washer_id1
  attr_accessor :washer_stock_id1
  attr_accessor :washer_stock_id2
  attr_accessor :washer_stock_id3
  attr_accessor :washer_id2
  attr_accessor :washer_stock_id4
  attr_accessor :washer_stock_id5
  attr_accessor :washer_stock_id6

  attr_accessor :washer_stock_rel_flag1
  attr_accessor :washer_stock_rel_flag2

  attr_accessor :production_lock_version

  # public instance method =====================================================
  def set_attributes(params = nil)
    return unless params

    vals = params[:washer_edit]

    self.washer_id1 = vals[:washer_id1]
    self.washer_stock_id1 = vals[:washer_stock_id1]
    self.washer_stock_id2 = vals[:washer_stock_id2]
    self.washer_stock_id3 = vals[:washer_stock_id3]
    self.washer_id2 = vals[:washer_id2]
    self.washer_stock_id4 = vals[:washer_stock_id4]
    self.washer_stock_id5 = vals[:washer_stock_id5]
    self.washer_stock_id6 = vals[:washer_stock_id6]

    self.washer_stock_rel_flag1 = vals[:washer_stock_rel_flag1].to_i
    self.washer_stock_rel_flag2 = vals[:washer_stock_rel_flag2].to_i
    
    self.production_lock_version = vals[:production_lock_version]
  end
  
  #自動で座金在庫と紐付ける
  def relate_auto(production)
    unless washer_id1.blank?
      # チェック解除で、連結も解除
      if washer_stock_rel_flag1 == FLAG_ON
        #すでに紐付け済みならば、紐付けしない
        if washer_stock_id1.blank?
          #引き当て可能な在庫を探す
          washer_stock = get_relatable_washer_stock(washer_id1, production)
          
          if washer_stock
            self.washer_stock_id1 = washer_stock.id
          else
            #なければ、バリデーションエラー
            errors[:base] << I18n.t(:error_valid_relate_auto_stocks)
          end
        end
      else
        # チェック解除で、連結も解除
        self.washer_stock_id1 = nil
        self.washer_stock_id2 = nil
        self.washer_stock_id3 = nil
      end
    end
    
    unless washer_id2.blank?
      # チェック解除で、連結も解除
      if washer_stock_rel_flag2 == FLAG_ON
        #すでに紐付け済みならば、紐付けしない
        if washer_stock_id4.blank?
          #引き当て可能な在庫を探す
          washer_stock = get_relatable_washer_stock(washer_id2, production)
          
          if washer_stock
            self.washer_stock_id4 = washer_stock.id
          else
            #なければ、バリデーションエラー
            errors[:base] << I18n.t(:error_valid_relate_auto_stocks)
          end
        end
      else
        # チェック解除で、連結も解除
        self.washer_stock_id4 = nil
        self.washer_stock_id5 = nil
        self.washer_stock_id6 = nil
      end
    end
  end
  
  def washer_stock_id1_before_type_cast
    return self.washer_stock_id1
  end

  def washer_stock_id2_before_type_cast
    return self.washer_stock_id2
  end

  def washer_stock_id3_before_type_cast
    return self.washer_stock_id3
  end

  def washer_stock_id4_before_type_cast
    return self.washer_stock_id4
  end

  def washer_stock_id5_before_type_cast
    return self.washer_stock_id5
  end

  def washer_stock_id6_before_type_cast
    return self.washer_stock_id6
  end
  
  validate :washer_stock_exist?

  # private instance method ====================================================
  def washer_stock_exist?
    unless washer_stock_id1.blank?
      if washer_id1.blank?
        errors.add(:washer_id1, :empty)
      else
        errors.add(:washer_stock_id1, :not_exist) unless washer_stock_exist_core?(washer_id1, washer_stock_id1)
      end
    end
    unless washer_stock_id2.blank?
      if washer_id1.blank?
        errors.add(:washer_id1, :empty)
      else
        errors.add(:washer_stock_id2, :not_exist) unless washer_stock_exist_core?(washer_id1, washer_stock_id2)
      end
    end
    unless washer_stock_id3.blank?
      if washer_id1.blank?
        errors.add(:washer_id1, :empty)
      else
        errors.add(:washer_stock_id3, :not_exist) unless washer_stock_exist_core?(washer_id1, washer_stock_id3)
      end
    end
    unless washer_stock_id4.blank?
      if washer_id2.blank?
        errors.add(:washer_id2, :empty)
      else
        errors.add(:washer_stock_id4, :not_exist) unless washer_stock_exist_core?(washer_id2, washer_stock_id4)
      end
    end
    unless washer_stock_id5.blank?
      if washer_id2.blank?
        errors.add(:washer_id2, :empty)
      else
        errors.add(:washer_stock_id5, :not_exist) unless washer_stock_exist_core?(washer_id2, washer_stock_id5)
      end
    end
    unless washer_stock_id6.blank?
      if washer_id2.blank?
        errors.add(:washer_id2, :empty)
      else
        errors.add(:washer_stock_id6, :not_exist) unless washer_stock_exist_core?(washer_id2, washer_stock_id6)
      end
    end
  end

  def washer_stock_exist_core?(washer_id, washer_stock_id)
    washer_stock = WasherStock.where(["id = ? and washer_id = ?", washer_stock_id, washer_id]).first
    return !(washer_stock.nil?)
  end

  def get_relatable_washer_stock(washer_id, production)
    washer_stocks = WasherStock.where(["washer_id = ?", washer_id]).order(:id)
    
    washer_stocks.each{ |washer_stock|
      washer_stock.calc_amount!
      return washer_stock if washer_stock.excess_amount >= production.result_amount
    }
    
    return nil
  end

end
