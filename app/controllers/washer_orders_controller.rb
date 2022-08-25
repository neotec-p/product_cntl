class WasherOrdersController < ApplicationController
  before_action :create_options

  before_action :set_washer_order, :only => [:edit, :update, :collect_print]
  
  def index
    cond_trader_id = nil
    cond_trader_id = params[:cond_trader_id].to_i unless params[:cond_trader_id].blank?
    params[:cond_delivery_flag] = FLAG_NON if params[:cond_delivery_flag].blank?
    cond_delivery_flag = params[:cond_delivery_flag].to_i

    @search_cond_date_from_to = SearchCondDateFromTo.new
    @search_cond_date_from_to.set_attributes(params)

    conds = ""
    cond_params = []

    washer_orders = WasherOrder

    conds = "trader_id = IFNULL(?, trader_id)"
    cond_params << cond_trader_id

    if @search_cond_date_from_to.cond_date_from
      conds += " and ? <= delivery_ymd"
      cond_params << @search_cond_date_from_to.cond_date_from
    end
    if @search_cond_date_from_to.cond_date_to.present?
      conds += " and delivery_ymd < ?"
      cond_params << (@search_cond_date_from_to.cond_date_to + 1.days)
    end
    if params[:cond_unprinted]
      washer_orders = washer_orders.includes(:reports).where(reports_washer_orders: { report_id: nil })
    end
    if cond_delivery_flag != FLAG_NON
      conds += " and delivery_flag = ?"
      cond_params << cond_delivery_flag
    end

    washer_orders = washer_orders.where([conds] + cond_params).order("delivery_ymd desc").order(id: :desc)

    session_set_prm

    @washer_orders = washer_orders.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
    
    @washer_orders.each_with_index{ |washer_order, i|
      washer_order.no_in_list = i
    }
  end

  # 一括発行
  def print_all
    begin
      @washer_orders = []
      @print_all = PrintAll.new

      inputs = params.permit(:washer_order => [:id, :select_print])[:washer_order]
      is_valid = true

      inputs.each {|no, input|
        washer_order = WasherOrder.find(input[:id])
        washer_order.attributes = input
        washer_order.no_in_list = no.to_i
        washer_order.select_print = input[:select_print].to_i

        @washer_orders << washer_order

        next unless washer_order.select_print == FLAG_ON

        result = washer_order.valid?
        is_valid &&= result
        
        @print_all.targets << washer_order
      }

      @washer_orders.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return render :action => :index
      end
      
      cnt = 0
      ActiveRecord::Base::transaction do
        report = AsynchroPrintWasherOrder.prepare_report(@app.user)
        
        @print_all.targets.each{ |washer_order|
          washer_order.reports << report
          washer_order.save!
        }
        
        AsynchroPrintWasherOrder.delay.report(report, @app.user, *@print_all.targets)
#        AsynchroPrintWasherOrder.report(report, @app.user, *@print_all.targets)
      end

      success_id = AsynchroPrintWasherOrder.create_print_message_print_all(@print_all.targets)

      flash[:notice] = t(:success_report_all, :id => success_id)

      redirect_to :action => :index, :params => session[:prm]

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :index
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :index
    end
  end
  
  # GET /%%controller_name%%/new
  def new
    @washer_order = WasherOrder.new

    @washer = Washer.find(params[:washer_id])
    @washer_order.washer = @washer

    @washer_order.order_ymd = Date.today
    @washer_order.delivery_flag = FLAG_OFF
  end

  # GET /%%controller_name%%/1/edit
  def edit
    @washer = Washer.find(@washer_order.washer_id)

    find_washer_stocks
    notice_force_submit
  end

  # POST /%%controller_name%%
  def create
    begin
      @washer_order = WasherOrder.new(washer_order_params)

      @washer = Washer.find(@washer_order.washer_id)
      @washer_order.washer = @washer

      if not @washer_order.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @washer_order.save!()
      end

      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :edit, :id => @washer_order.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @washer_order.attributes = washer_order_params
      @washer = Washer.find(@washer_order.washer_id)

      find_washer_stocks

      if params['delete'] #if params['delete.x']
        if not @washer_order.deletable?
          return render :action => :edit
        end

        ActiveRecord::Base::transaction do
          @washer_order.destroy
        end

        flash[:notice] = t(:success_deleted, :id => notice_success)
        redirect_to(:controller => :washers, :action => :stock, :id => @washer.id)
        
      else
        if not @washer_order.valid?
          return render :action => :edit
        end

        ActiveRecord::Base::transaction do
          @washer_order.save!
        end

        if params['accept']
          return redirect_to(:controller => :washer_stocks, :action => :new, :washer_order_id => @washer_order.id)
        end
        
        flash[:notice] = t(:success_updated, :id => notice_success)
      
        redirect_to :action => :edit
      end

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  # 在庫の回収
  def collect_print
    begin
      @washer = Washer.find(@washer_order.washer_id)
      
      @washer_stocks = []
      @print_all = PrintAll.new

      inputs = params[:washer_stock]
      is_valid = true

      inputs.each {|no, input|
        washer_stock = WasherStock.find(input[:id])
        washer_stock.attributes = input
        washer_stock.no_in_list = no.to_i
        washer_stock.select_print = input[:select_print].to_i

        @washer_stocks << washer_stock

        next unless washer_stock.select_print == FLAG_ON

        result = washer_stock.valid?
        is_valid &&= result
        
        @print_all.targets << washer_stock
      }

      @washer_stocks.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @print_all.targets.each{ |washer_stock|
          washer_stock.collect_flag_on

          washer_stock.save!
        }
      end
      success_message = :success_stock_finish
      
      success_id = @print_all.targets.size.to_s  + I18n.t(:cases_unit)
      
      flash[:notice] = t(success_message, :id => success_id)
      redirect_to :action => :edit, :id => @washer_order.id
      
    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end


  # 購入履歴発行 get
  def cond_print_t141
    get_all_print_t141
  end
  
  # 購入履歴発行 put
  def print_t141
    begin
      get_all_print_t141

      @purchase_list = PurchaseList.new
      @purchase_list.set_attributes(params)

      @purchase_list.targets = WasherOrder.where(["delivery_flag = ? and ? <= full_delivery_ymd and full_delivery_ymd <= ?", FLAG_ON, @purchase_list.cond_date_from, @purchase_list.cond_date_to])

      if not @purchase_list.valid?
        return render :action => :cond_print_t141
      end
      
      cnt = 0
      ActiveRecord::Base::transaction do
        report = AsynchroPrintWasherPurchaseList.prepare_report_with_term(@app.user, @purchase_list.cond_date_from, @purchase_list.cond_date_to)
        
        AsynchroPrintWasherPurchaseList.delay.report_with_term(report, @app.user, @purchase_list.cond_date_from, @purchase_list.cond_date_to, *@purchase_list.targets)
#        AsynchroPrintWasherPurchaseList.report_with_term(report, @app.user, @purchase_list.cond_date_from, @purchase_list.cond_date_to, *@purchase_list.targets)
      end
      
      success_message = :success_report
      success_id = AsynchroPrintWasherPurchaseList.create_print_message_print_all(@purchase_list.targets)
      
      flash[:notice] = t(success_message, :id => success_id)
      redirect_to :action => :cond_print_t141

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :cond_print_t141
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :cond_print_t141
    end
  end

  private

  def notice_success(options = {})
    return @washer_order.id
  end

  def create_options
    @washer_suppliers_options = WasherSupplier.all.order(:name)

    @delivery_flag_options = []
    @delivery_flag_options << [I18n.t(:status_delivery_flag_yet), FLAG_OFF]
    @delivery_flag_options << [I18n.t(:status_delivery_flag_full), FLAG_ON]
  end

  def find_washer_stocks
    @washer_stocks = @washer_order.washer_stocks.all.order("id desc")
    
    @washer_stocks.each_with_index{ |washer_stock, i|
      washer_stock.no_in_list = i
      washer_stock.calc_amount!
    }
  end

  def get_all_print_t141
    reports = Report.where(["report_type_id = ?", ReportType.find_by_code(REPORT_TYPE_T141)]).order("id desc")

    session_set_prm

    @reports = reports.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  def notice_force_submit
    flash[:alert] = t(:confirm_force_submit, :act => t(:status_arrival)) if @washer_order.delivery_flag == FLAG_ON
  end

  private
    def set_washer_order
      @washer_order = WasherOrder.find(params[:id])
    end

    def washer_order_params
      params.require(:washer_order).permit(:order_ymd, :trader_id, :delivery_ymd, :order_quantity, :reply_delivery_ymd, :delivery_flag, :full_delivery_ymd, :lock_version, :washer_id)
    end
end
