# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require 'active_record_helper'
  require 'action_view_helper'
  require 'application_csv'
  
  before_action :set_locale
  before_action :authorize
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  #rescue_from Exception, :with => :error

  protected
  def error(e)
    logger.error(e.message);
    puts e.backtrace
    flash[:error] = t(:error_default, :message => e)
    #redirect_to(error_url)
  end

  def set_locale
     req_lang = request.env.fetch('HTTP_ACCEPT_LANGUAGE', 'ja').scan(/^[a-z]{2}/).first
    if (I18n.available_locales.any?{|loc| loc.to_s == req_lang})
      I18n.locale = req_lang
    end
  end
  
  def authorize
    begin
      return redirect_to(root_url) unless session[:user_id]
 
      @app = ApplicationCommon.new
      
      user = User.find(session[:user_id])
      raise unless user
      @app.user = user

      @app_search = ApplicationSearch.new(params) if action_name == :index.to_s || action_name == :admin_index.to_s
      
    rescue => e
      
      puts e.backtrace
      raise

      flash[:notice] = t(:error_authorize)
      
      redirect_to(root_url)
    end
  end
  
  def session_get_user
    return session[:user_id]
  end
  
  def session_set_user(user)
    session[:user_id] = user.id
  end
  
  def session_set_prm()
    return if params[:format].to_s == :xml.to_s
    session[:prm] = params
  end
  
  #材料.規格のプルダウンを生成
  def create_material_standard_options
    @standard_options = []
    
    materials = Material.group(:standard).all.order(
    "standard asc"
    )
    
    materials.each{ |material|
      @standard_options << [material.standard, material.standard]
    }
    
    cond_standard = nil
    cond_standard = params[:cond_standard] if params[:cond_standard]

    @diameter_options = Material.where(["standard = ?", cond_standard]).group(:diameter).order(:diameter).map {|m| [m.diameter, m.diameter]}

    result = {}
    Material.group(:standard, :diameter).order(:standard, :diameter).each {|x|
      result[x.standard] = [] if not result.has_key?(x.standard);
      result[x.standard] << [x.diameter, x.diameter]
    } 
    @standard_material_json = result.to_json
  end

end
