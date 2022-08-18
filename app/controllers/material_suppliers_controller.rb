class MaterialSuppliersController < ApplicationController
  before_action :set_material_supplier, :only => [:edit, :update, :destroy]
  
  # GET /%%controller_name%%/
  def index
    alls = MaterialSupplier.available(params[:cond_id], params[:cond_name], params[:cond_address]).order("id asc")

    session_set_prm

    @material_suppliers = alls.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @material_supplier = MaterialSupplier.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @material_supplier = MaterialSupplier.new(material_supplier_params)

      if not @material_supplier.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @material_supplier.save!()
      end

      flash[:notice] = t(:success_created, :id => @material_supplier.disp_text)
      redirect_to :action => :edit, :id => @material_supplier.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @material_supplier.attributes = material_supplier_params
      if not @material_supplier.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @material_supplier.save!
      end

      flash[:notice] = t(:success_updated, :id => @material_supplier.disp_text)
      redirect_to :action => :edit, :id => @material_supplier.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end
  
  def destroy
    @material_supplier.destroy

    flash[:notice] = t(:success_deleted, :id => @material_supplier.disp_text)
    redirect_to(:action => :index)
  end

  private
  
    def set_material_supplier
      @material_supplier = MaterialSupplier.find(params[:id])
    end


    def material_supplier_params
      params.require(:material_supplier).permit(:name, :zip_code, :address, :tel, :fax, :lock_version)
    end
end
