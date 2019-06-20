class WashersController < ApplicationController
  before_action :set_washer, :only => [:edit, :update, :destroy, :stock, :collect_print]
  # GET /washers
  def index
    washers = Washer.available(params[:cond_id], params[:cond_steel_class], params[:cond_diameter], params[:cond_surface]).order("steel_class asc, diameter asc, surface asc")
    
    session_set_prm
    
    @washers = washers.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /washers/new
  def new
    @washer = Washer.new
  end

  # GET /washers/1/edit
  def edit
  end

  # POST /washers
  def create
    begin
      @washer = Washer.new(washer_params)

      if not @washer.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @washer.save!()
      end

      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :edit, :id => @washer.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /washers/1
  def update
    begin
      @washer.attributes = washer_params
      if not @washer.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @washer.save!
      end

      flash[:notice] = t(:success_updated, :id => notice_success)
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
    if not @washer.deletable?
      flash[:error] = t(:failed_to_delete)
      return redirect_to :action => :edit
    end
        
    @washer.destroy

    flash[:notice] = t(:success_deleted, :id => notice_success)
    redirect_to(:action => :index)
  end

  def stock_index
    stock_index_core(PAGINATE_PER_PAGE)
    session_set_prm
  end

  def stock
    stock_core
    flash[:notice] = t(:notice_provide_materil_stock) if @washer.provide_flag == FLAG_ON
  end

  # PUT /%%controller_name%%/1
  def collect_print
    begin
      stock_core
      
      @washer_stock = WasherStock.find(params[:washer_stock_id])
      @washer_stock.lock_version = params[:washer_stock_lock_version]

      if not @washer_stock.valid?
        return render :action => :stock
      end

      ActiveRecord::Base::transaction do
        @washer_stock.collect_flag_on
        @washer_stock.save!
      end

      success_message = :success_stock_finish
      success_id = 1.to_s + I18n.t(:cases_unit)

      flash[:notice] = t(success_message, :id => success_id)
      redirect_to :action => :stock

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :stock
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :stock
    end
  end

  def pop_washer_for_text
    pop_stock_index_core
  end
  
  def pop_washer_for_link
    pop_stock_index_core
  end
  
  private
  
  def notice_success
    @washer.disp_text
  end
  
  def stock_core
    @washer.calc_amount!
    
    washer_orders = @washer.washer_orders.all.order("id desc")
    @washer_orders = washer_orders.paginate(:page => params[:washer_orders_page], :per_page => PAGINATE_PER_PAGE_STOCK);
    
    washer_stocks = @washer.washer_stocks.all.order("id desc")
    @washer_stocks = washer_stocks.paginate(:page => params[:washer_stocks_page], :per_page => PAGINATE_PER_PAGE_STOCK);
    
    @washer_stocks.each{ |washer_stock|
      washer_stock.calc_amount!
    }
  end
  
  def stock_index_core(paginate_per_page)
    cond_steel_class = ""
    cond_steel_class = params[:cond_steel_class] if params[:cond_steel_class]
    cond_diameter = ""
    cond_diameter = params[:cond_diameter] if params[:cond_diameter]

    conds  = "1 = 1"
    cond_params = []
    
    unless cond_steel_class.blank?
      conds += " and" unless conds.empty?
      conds += " steel_class = ?"
      cond_params << cond_steel_class
    end
    unless cond_diameter.blank?
      conds += " and" unless conds.empty?
      conds += " diameter = ?"
      cond_params << cond_diameter.to_f
    end

    washers = Washer.where([conds] + cond_params)
    washers.order(
      "steel_class asc, diameter asc, surface asc"
    )

    @washers = washers.paginate(:page => params[:page], :per_page => paginate_per_page);
    
    @washers.each{ |washer|
      washer.calc_amount!
    }

    result = {}
    Washer.group(:steel_class, :diameter).order(:steel_class, :diameter).each {|x|
      result[x.steel_class] = [] if not result.has_key?(x.steel_class);
      result[x.steel_class] << [x.diameter, x.diameter]
    }
    @standard_material_json = result.to_json

    create_washer_steel_class_options
  end
  
  def pop_stock_index_core
    stock_index_core(PAGINATE_PER_PAGE_POP)
    
    render :layout => "popup"
  end


  #座金.鋼種のプルダウンを生成
  def create_washer_steel_class_options
    @steel_class_options = []

    washers = Washer.all.group(:steel_class).order("steel_class asc")

    washers.each{ |washer|
      @steel_class_options << [washer.steel_class, washer.steel_class]
    }

    cond_steel_class = nil
    cond_steel_class = params[:cond_steel_class] if params[:cond_steel_class]

    washers = Washer.where(
    ["steel_class = ?", cond_steel_class]).group(:diameter).order(
    "diameter asc"
    )

    @diameter_options = []
    washers.each { |washer|
      @diameter_options << [washer.diameter, washer.diameter]
    }

    @diameter_options

    result = {}
    Washer.group(:steel_class, :diameter).order(:steel_class, :diameter).each {|x|
      result[x.steel_class] = [] if not result.has_key?(x.steel_class);
      result[x.steel_class] << [x.diameter, x.diameter]
    }
    @standard_material_json = result.to_json
  end

  
  private
    def set_washer
      @washer = Washer.find(params[:id])
    end

    def washer_params
      params.require(:washer).permit(:steel_class, :diameter, :surface, :provide_flag, :unit_price, :unit, :lock_version)
    end
end
