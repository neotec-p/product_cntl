class InternalProcessorsController < ApplicationController
  before_action :set_internal_processor, :only => [:edit, :update, :destroy]

  # GET /%%controller_name%%/
  def index
    internal_processors = InternalProcessor.available(params[:cond_id], params[:cond_name], params[:cond_address]).order("id asc")
    
    session_set_prm

    @internal_processors = internal_processors.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE)
  end

  # GET /%%controller_name%%/new
  def new
    @internal_processor = InternalProcessor.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # POST /%%controller_name%%
  def create
    begin
      @internal_processor = InternalProcessor.new(internal_processor_params)
      if not @internal_processor.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @internal_processor.save!()
      end

      flash[:notice] = t(:success_created, :id => @internal_processor.disp_text)
      redirect_to :action => :edit, :id => @internal_processor.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @internal_processor.attributes = internal_processor_params
      if not @internal_processor.valid?
        return render :action => :edit
      end

      @internal_processor.save!

      flash[:notice] = t(:success_updated, :id => @internal_processor.disp_text)
      redirect_to :action => :edit, :id => @internal_processor.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  def destroy
    @internal_processor.destroy
    redirect_to(action: :index, flash: { notice: t(:success_deleted, :id => @internal_processor.disp_text) })
  end
  
  private
    def set_internal_processor
      @internal_processor = Trader.find(params[:id])
    end

    def internal_processor_params
      params.require(:internal_processor).permit(:name, :zip_code, :address, :tel, :fax, :addition_attr3, :lock_version)
    end
end
