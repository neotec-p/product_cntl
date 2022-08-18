class MaterialStocksController < ApplicationController
  before_action :set_material_stock, :only => [:edit, :update, :destroy]
  
  # GET /%%controller_name%%/new
  def new
    @material_stock = MaterialStock.new

    @material_order = MaterialOrder.find(params[:material_order_id])
    @material_stock.material_order = @material_order
    @material = Material.find(@material_order.material_id)
    @material_stock.material = @material
    
    @material_stock.calc_amount!
  end

  # GET /%%controller_name%%/1/edit
  def edit
    @material_order = MaterialOrder.find(@material_stock.material_order_id)
    @material = Material.find(@material_order.material_id)

    @material_stock.calc_amount!
    
    notice_force_submit
  end

  # POST /%%controller_name%%
  def create
    begin
      @material_stock = MaterialStock.new
      @material_stock.attributes = material_stock_params
      @material_stock.calc_amount!

      @material_order = MaterialOrder.find(@material_stock.material_order_id)
      @material_stock.material_order = @material_order
      @material = Material.find(@material_order.material_id)
      @material_stock.material = @material

      if not @material_stock.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @material_stock.save!()
      end

      flash[:notice] = t(:success_created, :id => @material_stock.id)
      redirect_to :action => :edit, :id => @material_stock.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @material_stock.attributes = material_stock_params
      @material_order = MaterialOrder.find(@material_stock.material_order_id)
      #@material = Material.find(@material_order.material_id)

      @material_stock.calc_amount!

      success_message = :success_updated
      success_id = @material_stock.id
        
      if params['stock_collect']
        @material_stock.collect_flag = FLAG_ON
        success_message = :success_print_collect
        success_id = ReportType.find_by_code(REPORT_TYPE_T150).name
     end

      if not @material_stock.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @material_stock.save!
      end

      flash[:notice] = t(success_message, :id => success_id)
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
    if not @material_stock.deletable?
      flash[:error] = t(:failed_to_delete)
      return redirect_to :action => :edit
    end
        
    ActiveRecord::Base::transaction do
      @material_stock.destroy
    end

    flash[:notice] = t(:success_deleted, :id => @material_stock.id)
    redirect_to(:controller => :material_orders, :action => :edit, :id => @material_order.id)
  end

  private
    def notice_force_submit
      flash[:alert] = t(:confirm_force_submit, :act => t(:button_stock_finish)) if @material_stock.collect_flag == FLAG_ON
    end
  
    def set_material_stock
      @material_stock = MaterialStock.find(params[:id])
    end

    def material_stock_params
      params.require(:material_stock).permit(:accept_weight, :accept_ymd, :inspection_no, :adjust_weight, :lock_version, :material_order_id)
    end
end
