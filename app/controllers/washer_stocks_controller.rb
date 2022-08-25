class WasherStocksController < ApplicationController
  before_action :set_washer_stock, :only => [:edit, :update, :destroy]
  
  # GET /%%controller_name%%/new
  def new
    @washer_stock = WasherStock.new

    @washer_order = WasherOrder.find(params[:washer_order_id])
    @washer_stock.washer_order = @washer_order
    @washer = Washer.find(@washer_order.washer_id)
    @washer_stock.washer = @washer
    
    @washer_stock.calc_amount!
  end

  # GET /%%controller_name%%/1/edit
  def edit
    @washer_order = WasherOrder.find(@washer_stock.washer_order_id)
    @washer = Washer.find(@washer_order.washer_id)

    @washer_stock.calc_amount!
    
    flash[:alert] = t(:confirm_force_submit, :act => t(:button_stock_finish)) if @washer_stock.collect_flag == FLAG_ON
  end

  # POST /%%controller_name%%
  def create
    begin
      @washer_stock = WasherStock.new(washer_stock_params)
      @washer_stock.calc_amount!

      @washer_order = WasherOrder.find(@washer_stock.washer_order_id)
      @washer_stock.washer_order = @washer_order
      @washer = Washer.find(@washer_order.washer_id)
      @washer_stock.washer = @washer

      if not @washer_stock.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @washer_stock.save!()
      end

      flash[:notice] = t(:success_created, :id => @washer_stock.id)
      redirect_to :action => :edit, :id => @washer_stock.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @washer_stock.attributes = washer_stock_params
      @washer_order = WasherOrder.find(@washer_stock.washer_order_id)
      #@washer = Washer.find(@washer_order.washer_id)

      @washer_stock.calc_amount!

      success_message = :success_updated
      success_id = @washer_stock.id
        
      if params['stock_collect']
        @washer_stock.collect_flag = FLAG_ON
        success_message = :success_print_collect
        success_id = ReportType.find_by_code(REPORT_TYPE_T150).name
      end

      if not @washer_stock.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @washer_stock.save!
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
    if not @washer_stock.deletable?
      flash[:error] = t(:failed_to_delete)
      return redirect_to :action => :edit
    end
    @washer_order = @washer_stock.washer_order
    @washer_stock.destroy

    flash[:notice] = t(:success_deleted, :id => @washer_stock.id)
    redirect_to(:controller => :washer_orders, :action => :edit, :id => @washer_order.id)
  end

  private
    def set_washer_stock
      @washer_stock = WasherStock.find(params[:id])
    end

    def washer_stock_params
      params.require(:washer_stock).permit(:accept_quantity, :accept_ymd, :inspection_no, :adjust_quantity, :lock_version, :washer_order_id)
    end
end
