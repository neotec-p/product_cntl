class NoticesController < ApplicationController
  before_action :set_notice, :only => [:edit, :update, :destroy]

  def index
    notices = Notice.all.order("id desc")
    @notices = notices.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE)
  end

  def new
    @notice = Notice.new
    @notice.user = @app.user
  end

  # GET /notices/1/edit
  def edit
  end

  # POST /notices
  def create
    begin
      @notice = Notice.new(notice_params)
      @notice.user = @app.user

      if not @notice.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @notice.save!()
      end

      flash[:notice] = t(:success_created, :id => @notice.id)
      redirect_to :action => :edit, :id => @notice.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /notices/1
  def update
    begin
      @notice.attributes = notice_params
      if not @notice.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @notice.save!
      end

      flash[:notice] = t(:success_updated, :id => @notice.id)
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
    @notice.destroy

    flash[:notice] = t(:success_deleted, :id => @notice.id)
    redirect_to(:action => :index)
  end

  private
    def set_notice
      @notice = Notice.find(params[:id])
    end

    def notice_params
      params.require(:notice).permit(:contents, :lock_version)
    end
end
