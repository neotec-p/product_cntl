class User < ActiveRecord::Base
  require 'digest/sha1'

  belongs_to :role
  
  has_many :reports
  has_many :summations
  has_many :memo
  has_many :information

  validates_presence_of     :login_id
  validates_alphanumeric_of :login_id
  validates_length_of     :login_id,  :maximum => 3
  validates_length_of     :last_name,  :maximum => 50 , :allow_blank => true
  validates_length_of     :first_name,  :maximum => 50, :allow_blank => true
  validates_presence_of     :role_id
  validates_numericality_of :role_id, :allow_blank => true

  validates_presence_of     :password,                 :if => :password_required?
  validates_length_of       :password, :maximum => 50, :if => :password_required?

  validates_confirmation_of :password

  # public class method ========================================================
  def self.authenticate(id, password)
    user = self.find_by_login_id(id)
    if user

      if (user.hashed_password.blank? || user.salt.blank?) && (password.blank? || id == password)
        user.password = id
        user.update_attribute(:hashed_password, user.hashed_password)
        user.update_attribute(:salt, user.salt)
      else
        expected_password = encrypted_password(password, user.salt)
        if user.hashed_password != expected_password
          user = nil
        end
      end

    end
    user
  end

  # accessor ===================================================================
  attr_accessor :password_confirmation
  attr_accessor :password_required
  attr_accessor :password_initialize

  # public instance method =====================================================
  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
    self.password_updated = Time.now
  end

  def password_required?
    !(password_required.blank? || password_required == '0')
  end

  def disp_text
    last_name + first_name
  end
  
  def role_purchase_or_sales?
    return (role.id == ROLE_PURCHASE || role.id == ROLE_SALES)
  end

  # private instance method ====================================================
  
  private

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  

  public
  def self.available(cond_login_id, cond_user_first_name, cond_user_last_name, cond_role_id)
    conds = "1 = 1"
    conds_param = []

    if cond_login_id.present?
      conds += " AND login_id = ?"
      conds_param << cond_login_id
    end
    if cond_user_first_name.present?
      conds += " AND first_name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_user_first_name.strip)]
    end
    if cond_user_last_name.present?
      conds += " AND last_name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_user_last_name.strip)]
    end
    if cond_role_id.present?
      conds += " AND role_id = ?"
      conds_param << cond_role_id
    end

    where([conds] + conds_param)
  end
end
