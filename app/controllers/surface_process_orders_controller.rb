class SurfaceProcessOrdersController < ProcessOrdersController
  before_action :create_surface_processor_options
  before_action :set_surface_process_order, :only => [:edit, :update, :destroy]

  def new
    @surface_process_order = SurfaceProcessOrder.new
    @production_detail = ProductionDetail.find(params[:production_detail_id])

    @surface_process_order.production_detail = @production_detail
    @surface_process_order.order_ymd = Date.today
    
    @surface_process_order.prepare_defalut
  end

  def edit
    @production_detail = @surface_process_order.production_detail
    
    flash[:alert] = t(:confirm_force_submit, :act => t(:status_arrival)) unless @surface_process_order.arrival_ymd.nil?
  end

  def create
    begin
      @surface_process_order = SurfaceProcessOrder.new
      @surface_process_order.attributes = surface_process_order_params

      @production_detail = ProductionDetail.find(params[:production_detail_id])
      @surface_process_order.production_detail = @production_detail

      if not @surface_process_order.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @surface_process_order.save!()
      end

      flash[:notice] = t(:success_created, :id => notice_success(:process_order => @surface_process_order))
      redirect_to :action => :edit, :id => @surface_process_order.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  def update
    begin
      @surface_process_order.attributes = surface_process_order_params
      #@production_detail = @surface_process_order.production_detail

      if not @surface_process_order.valid?
        return render :action => :edit
      end

      @surface_process_order.save!

      flash[:notice] = t(:success_updated, :id => notice_success(:process_order => @surface_process_order))
      #redirect_to :action => :edit, :production_detail_id => @surface_process_order.production_detail_id
      redirect_to edit_surface_process_order_path(:production_detail_id => @surface_process_order.production_detail_id)

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    @surface_process_order.destroy
    redirect_to(controller: :productions, action: :edit, id: @production_detail.production_id, flash: { notice: t(:success_deleted, :id => notice_success(:process_order => @surface_process_order)) })
  end

  private

  def create_surface_processor_options
    @surface_processor_options = SurfaceProcessor.all.order(:id)
  end

  private
    def set_surface_process_order
      @surface_process_order = SurfaceProcessOrder.find(params[:id])
    end

    def surface_process_order_params
      params.require(:surface_process_order).permit(:trader_id, :order_ymd, :delivery_ymd, :delivery_ymd_add, :material, :process, :price, :summary1, :summary2, :arrival_ymd, :lock_version)
    end
end
