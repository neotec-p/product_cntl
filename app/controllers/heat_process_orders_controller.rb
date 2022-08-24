class HeatProcessOrdersController < ProcessOrdersController
  before_action :create_heat_processor_options
  before_action :set_heat_process_order, :only => [:edit, :update]

  def new
    @heat_process_order = HeatProcessOrder.new
    @production_detail = ProductionDetail.find(params[:production_detail_id])

    @heat_process_order.production_detail = @production_detail
    @heat_process_order.order_ymd = Date.today
    
    @heat_process_order.prepare_defalut
  end

  def edit
    @heat_process_order = HeatProcessOrder.find(params[:id])
    @production_detail = @heat_process_order.production_detail
    
    flash[:alert] = t(:confirm_force_submit, :act => t(:status_arrival)) unless @heat_process_order.arrival_ymd.nil?
  end

  def create
    begin
      @heat_process_order = HeatProcessOrder.new(heat_process_order_params)
      @production_detail = ProductionDetail.find(params[:production_detail_id])
      @heat_process_order.production_detail = @production_detail

      if not @heat_process_order.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @heat_process_order.save!()
      end

      flash[:notice] = t(:success_created, :id => notice_success(:process_order => @heat_process_order))
      redirect_to :action => :edit, :id => @heat_process_order.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  def update
    begin
      @heat_process_order.attributes = heat_process_order_params

      @production_detail = @heat_process_order.production_detail

      if params['delete'] #if params['delete.x']
        ActiveRecord::Base::transaction do
          @heat_process_order.destroy
        end

        flash[:notice] = t(:success_deleted, :id => notice_success(:process_order => @heat_process_order))

        redirect_to(:controller => :productions, :action => :edit, :id => @production_detail.production_id)

      else
        if not @heat_process_order.valid?
          return render :action => :edit
        end

        ActiveRecord::Base::transaction do
          @heat_process_order.save!
        end

        flash[:notice] = t(:success_updated, :id => notice_success(:process_order => @heat_process_order))
        redirect_to :action => :edit, :production_detail_id => @production_detail.id
      end

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  private

  def create_heat_processor_options
    @heat_processor_options = HeatProcessor.all.order(:id)
  end

    def set_heat_process_order
      @heat_process_order = HeatProcessOrder.find(params[:id])
    end

    def heat_process_order_params
      params.require(:heat_process_order).permit(:trader_id, :order_ymd, :delivery_ymd, :delivery_ymd_add, :material, :process, :price, :summary1, :summary2, :arrival_ymd, :lock_version)
    end
end
