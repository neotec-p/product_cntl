class SurfaceProcessPricesController < ApplicationController
  before_action :create_surface_processor_options
  before_action :set_surface_process_price, :only => [:edit, :update, :destroy]

  # GET /%%controller_name%%/
  def index
    surface_process_prices = SurfaceProcessPrice.available(params[:cond_customer_code], params[:cond_code], params[:cond_trader_id], params[:cond_process]).order("id asc")
    
    session_set_prm

    @surface_process_prices = surface_process_prices.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @surface_process_price = SurfaceProcessPrice.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @surface_process_price = SurfaceProcessPrice.new
      @surface_process_price.attributes = surface_process_price_params

      if not @surface_process_price.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @surface_process_price.save!()
      end

      flash[:notice] = t(:success_created, :id => @surface_process_price.disp_text)
      redirect_to :action => :edit, :id => @surface_process_price.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @surface_process_price.attributes = surface_process_price_params
      if not @surface_process_price.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @surface_process_price.save!
      end

      flash[:notice] = t(:success_updated, :id => @surface_process_price.disp_text)
      redirect_to :action => :edit, :id => @surface_process_price.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    @surface_process_price.destroy

    flash[:notice] = t(:success_deleted, :id => @surface_process_price.disp_text)
    redirect_to(:action => :index)
  end
  
  private
    def create_surface_processor_options
      @surface_processor_options = SurfaceProcessor.all.order(:id)
    end

    def set_surface_process_price
      @surface_process_price = SurfaceProcessPrice.find(params[:id])
    end

    def surface_process_price_params
      params.require(:surface_process_price).permit(:customer_code, :code, :material_id, :trader_id, :process, :condition, :price, :unit, :set, :addition_price, :addition_unit, :condition_weight, :condition_following, :lock_version)
    end
end
