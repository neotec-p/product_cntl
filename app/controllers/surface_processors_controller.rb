class SurfaceProcessorsController < ApplicationController
  before_action :set_surface_processor, :only => [:edit, :update, :destroy]

  # GET /%%controller_name%%/
  def index
    surface_processors = SurfaceProcessor.available(params[:cond_id], params[:cond_name], params[:cond_address]).order("id asc")
    
    session_set_prm

    @surface_processors = surface_processors.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @surface_processor = SurfaceProcessor.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @surface_processor = SurfaceProcessor.new(surface_processor_params)

      if not @surface_processor.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @surface_processor.save!()
      end

      flash[:notice] = t(:success_created, :id => @surface_processor.disp_text)
      redirect_to :action => :edit, :id => @surface_processor.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @surface_processor.attributes = surface_processor_params
      if not @surface_processor.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @surface_processor.save!
      end

      flash[:notice] = t(:success_updated, :id => @surface_processor.disp_text)
      redirect_to :action => :edit, :id => @surface_processor.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    @surface_processor.destroy

    flash[:notice] = t(:success_deleted, :id => @surface_processor.disp_text)
    redirect_to(:action => :index)
  end
  
  private
    def set_surface_processor
      @surface_processor = Trader.find(params[:id])
    end

    def surface_processor_params
      params.require(:surface_processor).permit(:name, :zip_code, :address, :tel, :fax, :addition_attr1, :addition_attr2, :lock_version)
    end
end
