class AdditionProcessorsController < ApplicationController
  before_action :set_addition_processor, :only => [:edit, :update, :destroy]

  # GET /%%controller_name%%/
  def index
    addition_processors = AdditionProcessor.available(params[:cond_id], params[:cond_name], params[:cond_address]).order(:id)
    
    session_set_prm

    @addition_processors = addition_processors.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @addition_processor = AdditionProcessor.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @addition_processor = AdditionProcessor.new(addition_processor_params)

      if not @addition_processor.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @addition_processor.save!()
      end

      flash[:notice] = t(:success_created, :id => @addition_processor.disp_text)
      redirect_to :action => :edit, :id => @addition_processor.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @addition_processor.attributes = addition_processor_params

      if not @addition_processor.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @addition_processor.save!
      end

      flash[:notice] = t(:success_updated, :id => @addition_processor.disp_text)
      redirect_to :action => :edit, :id => @addition_processor.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    @addition_processor.destroy

    flash[:notice] = t(:success_deleted, :id => @addition_processor.disp_text)
    redirect_to(:action => :index)
  end
  
  private
    def set_addition_processor
      @addition_processor = Trader.find(params[:id])
    end

    def addition_processor_params
      params.require(:addition_processor).permit(:name, :zip_code, :address, :tel, :fax, :addition_attr1, :lock_version)
    end
end
