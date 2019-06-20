class DefectivesController < ApplicationController
  before_action :create_options
  before_action :set_defective, :only => [:edit, :update, :destroy]
  
  # GET /defectives
  def index
    @search_cond_date_from_to = SearchCondDateFromTo.new
    @search_cond_date_from_to.set_attributes(params)

    cond_item_customer_code = nil
    cond_item_customer_code = params[:cond_item_customer_code] unless params[:cond_item_customer_code].blank?
    cond_item_code = nil
    cond_item_code = params[:cond_item_code] unless params[:cond_item_code].blank?
    cond_contents = ""
    cond_contents = params[:cond_contents] unless params[:cond_contents].blank?

    defectives = Defective.available(@search_cond_date_from_to.cond_date_from,
                               @search_cond_date_from_to.cond_date_to,
                               params[:cond_item_customer_code],
                               params[:cond_item_code],
                               params[:cond_contents]).order("outbreak_ymd desc")
    
    session_set_prm
    
    @defectives = defectives.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
    
    @defectives.each{ |defective|
      defective.calc_amount!
    }

    respond_to do |format|
      format.html # index.html.erb
      format.csv  { send_data(@defectives.to_csv(Defective), :type => "text/csv") }
#      format.xml  { send_data(defectives.to_xml, :type => "text/xml; charset=utf8;", :disposition => "attachement") }
    end
  end
  
  # GET /defectives/new
  def new
    @defective = Defective.new
  end
  
  # GET /defectives/1/edit
  def edit
    @defective.calc_amount!
    
    defective_material_stock_seq1 = @defective.defective_material_stock_seqs.first
    unless defective_material_stock_seq1.nil?
      @defective.material_stock_id1 = defective_material_stock_seq1.material_stock_id
      @defective.material_weight1 = defective_material_stock_seq1.weight
    end
    
    defective_washer_stock_seq1 = @defective.defective_washer_stock_seqs.where("seq = 1").first
    unless defective_washer_stock_seq1.nil?
      @defective.washer_stock_id1 = defective_washer_stock_seq1.washer_stock_id
      @defective.washer_quantity1 = defective_washer_stock_seq1.quantity
    end
    defective_washer_stock_seq2 = @defective.defective_washer_stock_seqs.where("seq = 2").first
    unless defective_washer_stock_seq2.nil?
      @defective.washer_stock_id2 = defective_washer_stock_seq2.washer_stock_id
      @defective.washer_quantity2 = defective_washer_stock_seq2.quantity
    end
  end
  
  # POST /defectives
  def create
    begin
      @defective = Defective.new(defective_params)

      if not @defective.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @defective.save!
      end

      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :edit, :id => @defective.id
      
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end
  
  # PUT /defectives/1
  def update
    begin
      @defective.attributes = defective_params
      if not @defective.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @defective.save!
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
    @defective.destroy

    flash[:notice] = t(:success_deleted, :id => notice_success)
    redirect_to(:action => :index)
  end

  # 不良一覧発行 get
  def cond_print
    get_all_print
  end
  
  # 不良一覧発行 put
  def print
    begin
      get_all_print

      @defective_list = DefectiveList.new
      @defective_list.set_attributes(params)

      @defective_list.targets = Defective.where(["outbreak_ymd IS NOT NULL and ? <= outbreak_ymd and outbreak_ymd <= ?", @defective_list.cond_date_from, @defective_list.cond_date_to])

      if not @defective_list.valid?
        return render :action => :cond_print
      end
      
      cnt = 0
      ActiveRecord::Base::transaction do
        report = AsynchroPrintDefectiveList.prepare_report_with_term(@app.user, @defective_list.cond_date_from, @defective_list.cond_date_to)
        
        AsynchroPrintDefectiveList.delay.report_with_term(report, @app.user, @defective_list.cond_date_from, @defective_list.cond_date_to, *@defective_list.targets)
#        AsynchroPrintDefectiveList.report_with_term(report, @app.user, @defective_list.cond_date_from, @defective_list.cond_date_to, *@defective_list.targets)
      end
      
      success_message = :success_report
      success_id = AsynchroPrintDefectiveList.create_print_message_print_all(@defective_list.targets)
      
      flash[:notice] = t(success_message, :id => success_id)
      redirect_to :action => :cond_print

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :cond_print
    rescue => e
puts e.message + "\n"
puts e.backtrace.join("\n")
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :cond_print
    end
  end

  private
  
  def notice_success(options = {})
    return @defective.id
  end
  
  def create_options
    @defective_process_types = DefectiveProcessType.all.order(:seq)

    models = Model.all.order("models.name asc, models.code asc")

    @model_id_options = []
    models.each { |model|
      vals = [model.disp_text, model.id]
      @model_id_options << vals
    }

    @model_id_options
  end

  def get_all_print
    reports = Report.where(["report_type_id = ?", ReportType.find_by_code(REPORT_TYPE_T080)]).order("id desc")

    session_set_prm

    @reports = reports.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end


  private
    def defective_params
      params.require(:defective).permit(:outbreak_ymd, :defective_process_type_id, :model_id, :item_customer_code, :item_code, :amount, :weight, :material_stock_id1, :material_weight1, :washer_stock_id1, :washer_quantity1, :washer_stock_id2, :washer_quantity2, :lock_version)
    end

    def set_defective
      @defective = Defective.find(params[:id])
    end
end
