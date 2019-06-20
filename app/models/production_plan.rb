class ProductionPlan
  include ValidationsAdapter
  include ActiveRecord::Validations

  validates_date_compare_of :hd_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'hd_start_ymd'
  validates_date_compare_of :hd_addition_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'hd_addition_start_ymd'
  validates_date_compare_of :ro1_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'ro1_start_ymd'
  validates_date_compare_of :ro1_addition_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'ro1_addition_start_ymd'
  validates_date_compare_of :ro2_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'ro2_start_ymd'
  validates_date_compare_of :ro2_addition_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'ro2_addition_start_ymd'

  # accessor ===================================================================
  attr_accessor :hd_model_id
  attr_accessor :hd_start_ymd
  attr_accessor :hd_end_ymd
  attr_accessor :hd_addition_model_id
  attr_accessor :hd_addition_start_ymd
  attr_accessor :hd_addition_end_ymd
  attr_accessor :ro1_model_id
  attr_accessor :ro1_start_ymd
  attr_accessor :ro1_end_ymd
  attr_accessor :ro1_addition_model_id
  attr_accessor :ro1_addition_start_ymd
  attr_accessor :ro1_addition_end_ymd
  attr_accessor :ro2_model_id
  attr_accessor :ro2_start_ymd
  attr_accessor :ro2_end_ymd
  attr_accessor :ro2_addition_model_id
  attr_accessor :ro2_addition_start_ymd
  attr_accessor :ro2_addition_end_ymd

  attr_accessor :production
  attr_accessor :no_in_list

  attr_accessor :attributes
  attr_accessor :hd_model_id_options
  attr_accessor :hd_addition_model_id_options
  attr_accessor :ro1_model_id_options
  attr_accessor :ro1_addition_model_id_options
  attr_accessor :ro2_model_id_options
  attr_accessor :ro2_addition_model_id_options

  attr_accessor :hd_start_ymd_edit_flag
  attr_accessor :hd_end_ymd_edit_flag
  attr_accessor :hd_addition_start_ymd_edit_flag
  attr_accessor :hd_addition_end_ymd_edit_flag
  attr_accessor :ro1_start_ymd_edit_flag
  attr_accessor :ro1_end_ymd_edit_flag
  attr_accessor :ro1_addition_start_ymd_edit_flag
  attr_accessor :ro1_addition_end_ymd_edit_flag
  attr_accessor :ro2_start_ymd_edit_flag
  attr_accessor :ro2_end_ymd_edit_flag
  attr_accessor :ro2_addition_start_ymd_edit_flag
  attr_accessor :ro2_addition_end_ymd_edit_flag

  attr_accessor :disp_hd_start_ymd
  attr_accessor :disp_hd_end_ymd
  attr_accessor :disp_hd_addition_start_ymd
  attr_accessor :disp_hd_addition_end_ymd
  attr_accessor :disp_ro1_start_ymd
  attr_accessor :disp_ro1_end_ymd
  attr_accessor :disp_ro1_addition_start_ymd
  attr_accessor :disp_ro1_addition_end_ymd
  attr_accessor :disp_ro2_start_ymd
  attr_accessor :disp_ro2_end_ymd
  attr_accessor :disp_ro2_addition_start_ymd
  attr_accessor :disp_ro2_addition_end_ymd

  # public instance method =====================================================
  def initialize
    @attributes ||= {}
    @hd_model_id_options = nil
    @hd_addition_model_id_options = nil
    @ro1_model_id_options = nil
    @ro1_addition_model_id_options = nil
    @ro2_model_id_options = nil
    @ro2_addition_model_id_options = nil

    @hd_start_ymd_edit_flag = nil
    @hd_addition_start_ymd_edit_flag = nil
    @ro1_start_ymd_edit_flag = nil
    @ro1_addition_start_ymd_edit_flag = nil
    @ro2_start_ymd_edit_flag = nil
    @ro2_addition_start_ymd_edit_flag = nil
    @hd_end_ymd_edit_flag = nil
    @hd_addition_end_ymd_edit_flag = nil
    @ro1_end_ymd_edit_flag = nil
    @ro1_addition_end_ymd_edit_flag = nil
    @ro2_end_ymd_edit_flag = nil
    @ro2_addition_end_ymd_edit_flag = nil
  end

  def set_attributes(params = nil)
    return unless params

    self.hd_model_id = params[:hd_model_id]
    @attributes['hd_model_id'] = self.hd_model_id
    self.hd_start_ymd = conv_date(:hd_start_ymd, params)
    @attributes['hd_start_ymd'] = self.hd_start_ymd
    self.hd_end_ymd = conv_date(:hd_end_ymd, params)
    @attributes['hd_end_ymd'] = self.hd_end_ymd

    self.hd_addition_model_id = params[:hd_addition_model_id]
    @attributes['hd_addition_model_id'] = self.hd_addition_model_id
    self.hd_addition_start_ymd = conv_date(:hd_addition_start_ymd, params)
    @attributes['hd_addition_start_ymd'] = self.hd_addition_start_ymd
    self.hd_addition_end_ymd = conv_date(:hd_addition_end_ymd, params)
    @attributes['hd_addition_end_ymd'] = self.hd_addition_end_ymd

    self.ro1_model_id = params[:ro1_model_id]
    @attributes['ro1_model_id'] = self.ro1_model_id
    self.ro1_start_ymd = conv_date(:ro1_start_ymd, params)
    @attributes['ro1_start_ymd'] = self.ro1_start_ymd
    self.ro1_end_ymd = conv_date(:ro1_end_ymd, params)
    @attributes['ro1_end_ymd'] = self.ro1_end_ymd

    self.ro1_addition_model_id = params[:ro1_addition_model_id]
    @attributes['ro1_addition_model_id'] = self.ro1_addition_model_id
    self.ro1_addition_start_ymd = conv_date(:ro1_addition_start_ymd, params)
    @attributes['ro1_addition_start_ymd'] = self.ro1_addition_start_ymd
    self.ro1_addition_end_ymd = conv_date(:ro1_addition_end_ymd, params)
    @attributes['ro1_addition_end_ymd'] = self.ro1_addition_end_ymd

    self.ro2_model_id = params[:ro2_model_id]
    @attributes['ro2_model_id'] = self.ro2_model_id
    self.ro2_start_ymd = conv_date(:ro2_start_ymd, params)
    @attributes['ro2_start_ymd'] = self.ro2_start_ymd
    self.ro2_end_ymd = conv_date(:ro2_end_ymd, params)
    @attributes['ro2_end_ymd'] = self.ro2_end_ymd

    self.ro2_addition_model_id = params[:ro2_addition_model_id]
    @attributes['ro2_addition_model_id'] = self.ro2_addition_model_id
    self.ro2_addition_start_ymd = conv_date(:ro2_addition_start_ymd, params)
    @attributes['ro2_addition_start_ymd'] = self.ro2_addition_start_ymd
    self.ro2_addition_end_ymd = conv_date(:ro2_addition_end_ymd, params)
    @attributes['ro2_addition_end_ymd'] = self.ro2_addition_end_ymd

    @hd_start_ymd_edit_flag = conv_bool(:hd_start_ymd_edit_flag, params)
    @hd_end_ymd_edit_flag = conv_bool(:hd_end_ymd_edit_flag, params)
    @hd_addition_start_ymd_edit_flag = conv_bool(:hd_addition_start_ymd_edit_flag, params)
    @hd_addition_end_ymd_edit_flag = conv_bool(:hd_addition_end_ymd_edit_flag, params)
    @ro1_start_ymd_edit_flag = conv_bool(:ro1_start_ymd_edit_flag, params)
    @ro1_end_ymd_edit_flag = conv_bool(:ro1_end_ymd_edit_flag, params)
    @ro1_addition_start_ymd_edit_flag = conv_bool(:ro1_addition_start_ymd_edit_flag, params)
    @ro1_addition_end_ymd_edit_flag = conv_bool(:ro1_addition_end_ymd_edit_flag, params)
    @ro2_start_ymd_edit_flag = conv_bool(:ro2_start_ymd_edit_flag, params)
    @ro2_end_ymd_edit_flag = conv_bool(:ro2_end_ymd_edit_flag, params)
    @ro2_addition_start_ymd_edit_flag = conv_bool(:ro2_addition_start_ymd_edit_flag, params)
    @ro2_addition_end_ymd_edit_flag = conv_bool(:ro2_addition_end_ymd_edit_flag, params)

    self.disp_hd_start_ymd = conv_date(:disp_hd_start_ymd, params)
    self.disp_hd_end_ymd = conv_date(:disp_hd_end_ymd, params)
    self.disp_hd_addition_start_ymd = conv_date(:disp_hd_addition_start_ymd, params)
    self.disp_hd_addition_end_ymd = conv_date(:disp_hd_addition_end_ymd, params)
    self.disp_ro1_start_ymd = conv_date(:disp_ro1_start_ymd, params)
    self.disp_ro1_end_ymd = conv_date(:disp_ro1_end_ymd, params)
    self.disp_ro1_addition_start_ymd = conv_date(:disp_ro1_addition_start_ymd, params)
    self.disp_ro1_addition_end_ymd = conv_date(:disp_ro1_addition_end_ymd, params)
    self.disp_ro2_start_ymd = conv_date(:disp_ro2_start_ymd, params)
    self.disp_ro2_end_ymd = conv_date(:disp_ro2_end_ymd, params)
    self.disp_ro2_addition_start_ymd = conv_date(:disp_ro2_addition_start_ymd, params)
    self.disp_ro2_addition_end_ymd = conv_date(:disp_ro2_addition_end_ymd, params)
  end

  private

  # private instance method ====================================================
  def conv_date(attr_name, params = nil)
    return unless params
    val = nil
    date = params[attr_name].to_s.gsub("/", "-")
    begin
      val = Date.strptime(date, "%Y-%m-%d")
    rescue
      val = nil
    end
    return val
  end

  def conv_bool(attr_name, params = nil)
    return nil unless params
    return nil if params[attr_name].blank?

    val = false
    val = true if params[attr_name] == "true"
    return val
  end

end