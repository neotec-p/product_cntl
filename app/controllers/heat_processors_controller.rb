class HeatProcessorsController < ApplicationController
  before_action :set_heat_processor, :only => [:edit, :update, :destroy]

  # GET /%%controller_name%%/
  def index
    alls = HeatProcessor.available(params[:cond_id], params[:cond_name], params[:cond_address]).order("id asc")
    
    session_set_prm

    @heat_processors = alls.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @heat_processor = HeatProcessor.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
    @heat_processor = Trader.find(params[:id])
  end

  # POST /%%controller_name%%
  def create
    begin
      @heat_processor = HeatProcessor.new
      @heat_processor.attributes = heat_processor_params

      if not @heat_processor.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @heat_processor.save!()
      end

      flash[:notice] = t(:success_created, :id => @heat_processor.disp_text)
      redirect_to :action => :edit, :id => @heat_processor.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @heat_processor.attributes = heat_processor_params
      if not @heat_processor.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @heat_processor.save!
      end

      flash[:notice] = t(:success_updated, :id => @heat_processor.disp_text)
      redirect_to :action => :edit, :id => @heat_processor.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    @heat_processor.destroy

    flash[:notice] = t(:success_deleted, :id => @heat_processor.disp_text)
    redirect_to(:action => :index)
  end
  
  private
    def set_heat_processor
      @heat_processor = HeatProcessor.find(params[:id])
    end
  
    def heat_processor_params
      params.require(:heat_processor).permit(:name, :zip_code, :address, :tel, :fax, :addition_attr1, :lock_version)
    end
end
