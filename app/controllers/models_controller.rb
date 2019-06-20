class ModelsController < ApplicationController
  before_action :create_plan_process_options
  before_action :set_model, :only => [:edit, :update, :destroy, :pop_model_production_plan]

  # GET /models
  def index
    models = Model.available(params[:cond_code], params[:cond_name]).order("code asc, name asc")

    session_set_prm

    @models = models.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /models/new
  def new
    @model = Model.new
  end

  # GET /models/1/edit
  def edit
  end

  # POST /models
  def create
    begin
      @model = Model.new
      @model.attributes = model_params

      if not @model.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @model.process_types = ProcessType.where(id: params[:process_types] || [])
        @model.save!
      end

      flash[:notice] = t(:success_created, :id => @model.disp_text)
      redirect_to :action => :edit, :id => @model.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /models/1
  def update
    begin
      @model.attributes = model_params
      if not @model.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @model.process_types = ProcessType.where(id: params[:process_types] || [])
        @model.save!
      end

      flash[:notice] = t(:success_updated, :id => @model.disp_text)
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
    @model.destroy

    flash[:notice] = t(:success_deleted, :id => @model.disp_text)
    redirect_to(:action => :index)
  end

  def pop_model_production_plan
    current_date = Date.today.beginning_of_week

    @plans = []
    POP_MODEL_PRODUCTION_PLAN_WEEKS.times { |i|
      7.times { |j|
        plan = {}

        plan[:date] = current_date
        plan[:date_class] = ('date-today' if current_date.today?) || ''

        plan_text = ""
        production_detail = ProductionDetail.where(["model_id = ? and plan_start_ymd <= ? and ? <= plan_end_ymd", @model.id, current_date, current_date]).first

        plan[:plan] = if production_detail
                        I18n.t(:notice_plan_done)
                      elsif Calendar.holiday?(current_date)
                        I18n.t(:notice_plan_holiday)
                      else
                        ""
                      end

        @plans << plan
        current_date = current_date.tomorrow
      }
    }

    render :layout => "popup"
  end

  private

    def set_model
      @model = Model.find(params[:id])
    end

    def model_params
      #params.require(:model).permit(:process_types)
      params.require(:model).permit(:code, :name, :note, :process_types)
    end


  def create_plan_process_options
    @plan_processes = ProcessType.find_plan_process
  end

end
