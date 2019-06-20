class UsersController < ApplicationController
  before_action :create_options
  before_action :set_user, :only => [:edit, :update, :destroy, :passwd, :passwd_update]

  # GET /%%controller_name%%/
  def index
    cond_code = nil
    cond_code = params[:cond_code] unless params[:cond_code].blank?
    cond_user_last_name = ''
    cond_user_last_name = params[:cond_user_last_name] unless params[:cond_user_last_name].blank?
    cond_user_first_name = ''
    cond_user_first_name = params[:cond_user_first_name] unless params[:cond_user_first_name].blank?
    cond_role_id = nil
    cond_role_id = params[:cond_role_id].to_i unless params[:cond_role_id].blank?
    
    users = User.available(params[:cond_code], params[:cond_user_first_name], params[:cond_user_last_name], params[:cond_role_id]).order(
        "login_id asc"
    )
    
    session_set_prm

    @users = users.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE)
  end

  # GET /%%controller_name%%/new
  def new
    @user = User.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @user = User.new(user_params)

      if not @user.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @user.save!
      end

      flash[:notice] = t(:success_created, :id => @user.disp_text)
      redirect_to :action => :edit, :id => @user.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @user.attributes = user_params
      if not @user.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @user.save!
      end

      flash[:notice] = t(:success_updated, :id => @user.disp_text)
      redirect_to :action => :edit

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    if @user.id == @app.user.id
      flash[:notice] = t(:error_delete_self);
      return render :action => :edit
    end

    ActiveRecord::Base::transaction do
      @user.destroy
    end

    flash[:notice] = t(:success_deleted, :id => @user.disp_text)
    redirect_to(:action => :index)
  end

  def passwd
  end

  def passwd_update
    begin
      @user.attributes = user_params

      if user_params[:password] != user_params[:password_confirmation]
        flash[:notice] = t(:error_pwd_match);
        return render :action => :passwd
      end

      if User.authenticate( @user.login_id, user_params[:password_required] ).blank?
        flash[:notice] = t(:error_login)
        return render :action => :passwd
      end
        
      if not @user.valid?
        return render :action => :passwd
      end

      ActiveRecord::Base::transaction do
        @user.save!
      end

      flash[:notice] = t(:success_updated, :id => @user.disp_text)
      redirect_to :action => :passwd

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :passwd
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :passwd
    end
  end

  private

  def create_options
    @roles = Role.all
  end
  
  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:login_id, :role_id, :last_name, :first_name, :password_required, :password, :password_confirmation, :lock_version)
    end
end
