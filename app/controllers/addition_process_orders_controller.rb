class AdditionProcessOrdersController < ProcessOrdersController
  before_action :create_addition_processor_options
  before_action :set_addition_process_order, :only => [:edit, :update, :destroy]

  def new
    @addition_process_order = AdditionProcessOrder.new
    @production_detail = ProductionDetail.find(params[:production_detail_id])

    @addition_process_order.production_detail = @production_detail
    @addition_process_order.order_ymd = Date.today
    
    @addition_process_order.prepare_defalut
  end

  def edit
    @production_detail = @addition_process_order.production_detail
    
    flash[:alert] = t(:confirm_force_submit, :act => t(:status_arrival)) unless @addition_process_order.arrival_ymd.nil?
  end

  def create
    begin
      @addition_process_order = AdditionProcessOrder.new
      @production_detail = ProductionDetail.find(params[:production_detail_id])

      @addition_process_order.attributes = addition_process_order_params

      @addition_process_order.production_detail = @production_detail

      if not @addition_process_order.valid?
        return render :action => :new 
      end

      ActiveRecord::Base::transaction do
        @addition_process_order.save!()
      end

      flash[:notice] = t(:success_created, :id => notice_success(:process_order => @addition_process_order))
      redirect_to :action => :edit, :id => @addition_process_order.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  def update
    begin
      @addition_process_order.attributes = addition_process_order_params
      if not @addition_process_order.valid?
	return render :action => :edit
      end
      @addition_process_order.save!

      flash[:notice] = t(:success_updated, :id => notice_success(:process_order => @addition_process_order))
      redirect_to :action => :edit, :production_detail_id => @addition_process_order.production_detail_id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    @addition_process_order.destroy
    redirect_to(controller: :productions, action: :edit, id: @production_detail.production_id, flash: t(:success_deleted, :id => notice_success(:process_order => @addition_process_order)))
  end

  private

  def create_addition_processor_options
    @addition_processor_options = AdditionProcessor.all.order(:id)
  end

  private
    def set_addition_process_order
      @addition_process_order = AdditionProcessOrder.find(params[:id])
    end

    def addition_process_order_params
      params.require(:addition_process_order).permit(:trader_id, :order_ymd, :delivery_ymd, :delivery_ymd_add, :material, :process, :price, :summary1, :summary2, :arrival_ymd, :lock_version)
    end
end
