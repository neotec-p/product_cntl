class MaterialOrdersController < ApplicationController
  before_action :create_options
  before_action :set_material_order, :only => [:edit, :update, :print_t150]
  
  def index
    cond_trader_id = nil
    cond_trader_id = params[:cond_trader_id].to_i unless params[:cond_trader_id].blank?
    params[:cond_delivery_flag] = FLAG_NON if params[:cond_delivery_flag].blank?
    cond_delivery_flag = params[:cond_delivery_flag].to_i

    @search_cond_date_from_to = SearchCondDateFromTo.new
    @search_cond_date_from_to.set_attributes(params)

    conds = ""
    cond_params = []

    material_orders = MaterialOrder

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
      material_orders = material_orders.includes(:reports).where(material_orders_reports: { report_id: nil })
    end
    if cond_delivery_flag != FLAG_NON
      conds += " and delivery_flag = ?"
      cond_params << cond_delivery_flag
    end

    material_orders = material_orders.where([conds] + cond_params).order("delivery_ymd desc").order(id: :desc)

    session_set_prm

    @material_orders = material_orders.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
    
    @material_orders.each_with_index{ |material_order, i|
      material_order.no_in_list = i
    }
  end

  # 一括発行
  def print_all
    begin
      @material_orders = []
      @print_all = PrintAll.new

      inputs = params.permit(:material_order => [:id, :select_print])[:material_order]
      is_valid = true

      inputs.each {|no, input|
        material_order = MaterialOrder.find(input[:id])
        material_order.attributes = input
        material_order.no_in_list = no.to_i
        material_order.select_print = input[:select_print].to_i

        @material_orders << material_order

        next unless material_order.select_print == FLAG_ON

        result = material_order.valid?
        is_valid &&= result
        
        @print_all.targets << material_order
      }

      @material_orders.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return render :action => :index
      end
      
      cnt = 0
      ActiveRecord::Base::transaction do
        report = AsynchroPrintMaterialOrder.prepare_report(@app.user)
        
        @print_all.targets.each{ |material_order|
          material_order.reports << report
          material_order.save!
        }
        
        AsynchroPrintMaterialOrder.delay.report(report, @app.user, *@print_all.targets)
#        AsynchroPrintMaterialOrder.report(report, @app.user, *@print_all.targets)
      end

      success_id = AsynchroPrintMaterialOrder.create_print_message_print_all(@print_all.targets)

      flash[:notice] = t(:success_report_all, :id => success_id)

      redirect_to :action => :index, :params => session[:prm]

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :index
    #rescue => e
    #  flash[:error] = t(:error_default, :message => e.message)
    #  render :action => :index
    end
  end
  
  # GET /%%controller_name%%/new
  def new
    @material_order = MaterialOrder.new

    @material = Material.find(params[:material_id])
    @material_order.material = @material

    @material_order.order_ymd = Date.today
    @material_order.delivery_flag = FLAG_OFF
  end

  # GET /%%controller_name%%/1/edit
  def edit
    @material = Material.find(@material_order.material_id)
    
    find_material_stocks
    notice_force_submit
  end

  # POST /%%controller_name%%
  def create
    begin
      @material_order = MaterialOrder.new(material_order_params)

      @material = Material.find(@material_order.material_id)
      @material_order.material = @material

      if not @material_order.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        #材料の単価を更新する
        @material_order.material_update_flag = FLAG_ON
        @material_order.save!
      end

      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :edit, :id => @material_order.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @material_order.attributes = material_order_params
      @material = Material.find(@material_order.material_id)

      find_material_stocks

      if params['delete'] #if params['delete.x']
        if not @material_order.deletable?
          return render :action => :edit
        end
        
        ActiveRecord::Base::transaction do
          @material_order.destroy
        end

        flash[:notice] = t(:success_deleted, :id => notice_success)
        redirect_to(:controller => :materials, :action => :stock, :id => @material.id)

      else
        if not @material_order.valid?
          return render :action => :edit
        end

        ActiveRecord::Base::transaction do
          #材料の単価を更新する
          @material_order.material_update_flag = FLAG_ON
          @material_order.save!
        end

        if params['accept']
          return redirect_to(:controller => :material_stocks, :action => :new, :material_order_id => @material_order.id)
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

  # 材料管理票の発行・回収
  def print_t150
    begin
      @material = Material.find(@material_order.material_id)
      
      @material_stocks = []
      @print_all = PrintAll.new

      inputs = params.permit(:material_stock => [:id, :select_print])[:material_stock]
      is_valid = true

      inputs.each {|no, input|
        material_stock = MaterialStock.find(input[:id])
        material_stock.attributes = input
        material_stock.no_in_list = no.to_i
        material_stock.select_print = input[:select_print].to_i

        @material_stocks << material_stock

        next unless material_stock.select_print == FLAG_ON

        result = material_stock.valid?
        is_valid &&= result
        
        @print_all.targets << material_stock
      }

      @material_stocks.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return render :action => :edit
      end

      if params['collect_print']
        ActiveRecord::Base::transaction do
          @print_all.targets.each{ |material_stock|
            material_stock.collect_flag_on

            material_stock.save!
          }
        end
        success_message = :success_print_collect
        
      else
        cnt = 0
        ActiveRecord::Base::transaction do
          report = AsynchroPrintMaterialStock.prepare_report(@app.user)
          
          @print_all.targets.each{ |material_stock|
            material_stock.reports << report
            material_stock.save!
          }
          
          AsynchroPrintMaterialStock.delay.report(report, @app.user, *@print_all.targets)
#          AsynchroPrintMaterialStock.report(report, @app.user, *@print_all.targets)
        end
        success_message = :success_report_all
      end
      
      success_id = AsynchroPrintMaterialStock.create_print_message_print_all(@print_all.targets)
      
      flash[:notice] = t(success_message, :id => success_id)
      redirect_to :action => :edit, :id => @material_order.id
      
    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  # 購入履歴発行 get
  def cond_print_t140
    get_all_print_t140
  end
  
  # 購入履歴発行 put
  def print_t140
    begin
      get_all_print_t140

      @purchase_list = PurchaseList.new
      @purchase_list.set_attributes(params)

      #@purchase_list.targets = MaterialOrder.where(["delivery_flag = ? and full_delivery_ymd IS NOT NULL and ? <= full_delivery_ymd and full_delivery_ymd <= ?", FLAG_ON, @purchase_list.cond_date_from, @purchase_list.cond_date_to])
      @purchase_list.targets = MaterialStock.includes(:material_order).where("accept_ymd >= ? AND accept_ymd <= ?", @purchase_list.cond_date_from, @purchase_list.cond_date_to).order("material_orders.trader_id desc").order(:accept_ymd)

      if not @purchase_list.valid?
        return render :action => :cond_print_t140
      end
      
      cnt = 0
      ActiveRecord::Base::transaction do
        report = AsynchroPrintMaterialPurchaseList.prepare_report_with_term(@app.user, @purchase_list.cond_date_from, @purchase_list.cond_date_to)
        
        AsynchroPrintMaterialPurchaseList.delay.report_with_term(report, @app.user, @purchase_list.cond_date_from, @purchase_list.cond_date_to, *@purchase_list.targets)
#        AsynchroPrintMaterialPurchaseList.report_with_term(report, @app.user, @purchase_list.cond_date_from, @purchase_list.cond_date_to, *@purchase_list.targets)
      end
      
      success_message = :success_report
      success_id = AsynchroPrintMaterialPurchaseList.create_print_message_print_all(@purchase_list.targets)
      
      flash[:notice] = t(success_message, :id => success_id)
      redirect_to :action => :cond_print_t140

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :cond_print_t140
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :cond_print_t140
    end
  end

  private

  def notice_success(options = {})
    return @material_order.id
  end

  def create_options
    @material_suppliers_options = MaterialSupplier.all.order(:name)

    @delivery_flag_options = []
    @delivery_flag_options << [I18n.t(:status_delivery_flag_yet), FLAG_OFF]
    @delivery_flag_options << [I18n.t(:status_delivery_flag_full), FLAG_ON]
  end

  def find_material_stocks
    @material_stocks = @material_order.material_stocks.all.order("id desc")
    
    @material_stocks.each_with_index{ |material_stock, i|
      material_stock.no_in_list = i
      material_stock.calc_amount!
    }
  end

  def get_all_print_t140
    reports = Report.where(["report_type_id = ?", ReportType.find_by_code(REPORT_TYPE_T140)]).order("id desc")

    session_set_prm

    @reports = reports.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  def notice_force_submit
    flash[:alert] = t(:confirm_force_submit, :act => t(:status_arrival)) if @material_order.delivery_flag == FLAG_ON
  end

  private
    def set_material_order
      @material_order = MaterialOrder.find(params[:id])
    end
  
    def material_order_params
      params.require(:material_order).permit(:order_ymd, :trader_id, :delivery_ymd, :order_weight, :reply_delivery_ymd, :purchase_price, :delivery_flag, :full_delivery_ymd, :lock_version, :material_id)
    end
end
