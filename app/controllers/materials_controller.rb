class MaterialsController < ApplicationController
  before_action :set_material, :only => [:edit, :update, :destroy, :stock, :collect_print]

  # GET /materials
  def index
    materials = Material.available(params[:cond_id], params[:cond_standard], params[:cond_diameter], params[:cond_surface]).order("standard asc, diameter asc, surface asc")
    
    session_set_prm
    
    @materials = materials.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end
  
  # GET /materials/new
  def new
    @material = Material.new
  end
  
  # GET /materials/1/edit
  def edit
  end
  
  # POST /materials
  def create
    begin
      @material = Material.new(material_params)

      if not @material.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @material.save!()
      end

      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :edit, :id => @material.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end
  
  # PUT /materials/1
  def update
    begin
      @material.attributes = material_params
      if not @material.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @material.save!
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
    if not @material.deletable?
      flash[:error] = t(:failed_to_delete)
      return redirect_to :action => :edit
    end
        
    @material.destroy

    flash[:notice] = t(:success_deleted, :id => notice_success)
    redirect_to(:action => :index)
  end

  def stock_index
    stock_index_core(PAGINATE_PER_PAGE)
    session_set_prm
  end

  def stock
    stock_core
    flash[:notice] = t(:notice_provide_materil_stock) if @material.provide_flag == FLAG_ON
  end

  # PUT /%%controller_name%%/1
  def collect_print
    begin
      stock_core
      
      @material_stock = MaterialStock.find(params[:material_stock_id])
      @material_stock.lock_version = params[:material_stock_lock_version]

      if not @material_stock.valid?
        return render :action => :stock
      end

      ActiveRecord::Base::transaction do
        @material_stock.collect_flag_on
        @material_stock.save!
      end

      success_message = :success_print_collect
      success_id = AsynchroPrintMaterialStock.create_print_message_print_all([@material_stock])

      flash[:notice] = t(success_message, :id => success_id)
      #redirect_to :action => :stock, :material_stocks_page => params[:material_stocks_page]
      redirect_to stock_material_path(@material.id, material_stocks_page: params[:material_stocks_page])

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :stock
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :stock
    end
  end

  def pop_material_for_text
    pop_stock_index_core
  end
  
  def pop_material_for_link
    pop_stock_index_core
  end
  
  private
  
  def notice_success
    @material.disp_text
  end
  
  def stock_core
    @material.calc_amount!
    
    material_orders = @material.material_orders.all.order("id desc")
    @material_orders = material_orders.paginate(:page => params[:material_orders_page], :per_page => PAGINATE_PER_PAGE_STOCK);
    
    material_stocks = @material.material_stocks.all.order("id desc")
    @material_stocks = material_stocks.paginate(:page => params[:material_stocks_page], :per_page => PAGINATE_PER_PAGE_STOCK);
    
    @material_stocks.each{ |material_stock|
      material_stock.calc_amount!
    }
  end
  
  def stock_index_core(paginate_per_page)
    cond_standard = ""
    cond_standard = params[:cond_standard] if params[:cond_standard]
    cond_diameter = ""
    cond_diameter = params[:cond_diameter] if params[:cond_diameter]

    conds  = "1 = 1"
    cond_params = []
    
    unless cond_standard.blank?
      conds += " and" unless conds.empty?
      conds += " standard = ?"
      cond_params << cond_standard
    end
    unless cond_diameter.blank?
      conds += " and" unless conds.empty?
      conds += " diameter = ?"
      cond_params << cond_diameter.to_f
    end

    materials = Material.where([conds] + cond_params).order("standard asc, diameter asc, surface asc")

    @materials = materials.paginate(:page => params[:page], :per_page => paginate_per_page);
    
    @materials.each{ |material|
      material.calc_amount!
    }

    result = {}
    Material.group(:standard, :diameter).order(:standard, :diameter).each {|x|
      result[x.standard] = [] if not result.has_key?(x.standard);
      result[x.standard] << [x.diameter, x.diameter]
    }
    @standard_material_json = result.to_json

    create_material_standard_options
  end
  
  def pop_stock_index_core
    stock_index_core(PAGINATE_PER_PAGE_POP)
    
    render :layout => "popup"
  end

  private
    def set_material
      @material = Material.find(params[:id])
    end

    def material_params
      params.require(:material).permit(:standard, :diameter, :surface, :provide_flag, :process, :dimensions, :unit_price, :unit_price_update_flag, :lock_version)
    end
end
