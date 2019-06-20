class CustomersController < ApplicationController
  before_action :set_customer, :only => [:edit, :update, :destroy]
  
  # GET /customers
  def index
    customers = Customer.available(params[:cond_code], params[:cond_name]).order("code asc")
    
    session_set_prm
    
    @customers = customers.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end
  
  # GET /customers/new
  def new
    @customer = Customer.new
  end
  
  # GET /customers/1/edit
  def edit
  end
  
  # POST /customers
  def create
    begin
      @customer = Customer.new(customer_params)

      if not @customer.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @customer.save!
      end

      flash[:notice] = t(:success_created, :id => @customer.disp_text)
      redirect_to :action => :edit, :id => @customer.id
      
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end
  
  # PUT /customers/1
  def update
    begin
      @customer.attributes = customer_params
      if not @customer.valid?
	return render :action => :edit
      end

      ActiveRecord::Base::transaction do
	@customer.save!
      end

      flash[:notice] = t(:success_updated, :id => @customer.disp_text)
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
    @customer.destroy
    flash[:notice] = t(:success_deleted, :id => @customer.disp_text)
    redirect_to(:action => :index)
  end

  private
    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      params.require(:customer).permit(:code, :name, :note, :lock_version)
    end
end
