class WasherSuppliersController < ApplicationController
  before_action :set_washer_supplier, :only => [:edit, :update, :destroy]

  # GET /%%controller_name%%/
  def index
    washer_suppliers = WasherSupplier.available(params[:cond_id], params[:cond_name], params[:cond_address]).order("id asc")

    session_set_prm

    @washer_suppliers = washer_suppliers.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @washer_supplier = WasherSupplier.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @washer_supplier = WasherSupplier.new(washer_supplier_params)

      if not @washer_supplier.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @washer_supplier.save!()
      end

      flash[:notice] = t(:success_created, :id => @washer_supplier.disp_text)
      redirect_to :action => :edit, :id => @washer_supplier.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @washer_supplier.attributes = washer_supplier_params
      if not @washer_supplier.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @washer_supplier.save!
      end

      flash[:notice] = t(:success_updated, :id => @washer_supplier.disp_text)
      redirect_to :action => :edit, :id => @washer_supplier.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end
  
  def destroy
    @washer_supplier.destroy

    flash[:notice] = t(:success_deleted, :id => @washer_supplier.disp_text)
    redirect_to(:action => :index)
  end

  private
    def set_washer_supplier
      @washer_supplier = WasherSupplier.find(params[:id])
    end

    def washer_supplier_params
      params.require(:washer_supplier).permit(:name, :zip_code, :address, :tel, :fax, :lock_version)
    end
end
