class HeatProcessPricesController < ApplicationController
  before_action :create_heat_processor_options
  before_action :set_heat_process_price, :only => [:edit, :update, :destroy]

  # GET /%%controller_name%%/
  def index
    heat_process_prices = HeatProcessPrice.available(params[:cond_customer_code], params[:cond_code], params[:cond_trader_id], params[:cond_process]).order("id asc")
    
    session_set_prm

    @heat_process_prices = heat_process_prices.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @heat_process_price = HeatProcessPrice.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @heat_process_price = HeatProcessPrice.new(heat_process_price_params)

      if not @heat_process_price.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @heat_process_price.save!()
      end

      flash[:notice] = t(:success_created, :id => @heat_process_price.disp_text)
      redirect_to :action => :edit, :id => @heat_process_price.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @heat_process_price.attributes = heat_process_price_params

      if params['delete.x']
      else
        if not @heat_process_price.valid?
          return render :action => :edit
        end

        ActiveRecord::Base::transaction do
          @heat_process_price.save!
        end

        flash[:notice] = t(:success_updated, :id => @heat_process_price.disp_text)
        redirect_to :action => :edit, :id => @heat_process_price.id
      end

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end
  
  def destroy
    @heat_process_price.destroy

    flash[:notice] = t(:success_deleted, :id => @heat_process_price.disp_text)
    redirect_to(:action => :index)
  end

  private
  
  def create_heat_processor_options
    @heat_processor_options = HeatProcessor.all.order(:id)
  end

    def set_heat_process_price
      @heat_process_price = ProcessPrice.find(params[:id])
    end

    def heat_process_price_params
      params.require(:heat_process_price).permit(:customer_code, :code, :material_id, :trader_id, :process, :condition, :price, :unit, :set, :addition_price, :addition_unit, :condition_weight, :condition_following, :lock_version)
    end
end
