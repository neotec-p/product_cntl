class ProcessOrdersController < ApplicationController
  before_action :create_options

  # 一覧
  def index
    cond_lot_no = nil
    cond_lot_no = params[:cond_lot_no] unless params[:cond_lot_no].blank?
    
    process_orders = ProcessOrder.includes([:production_detail => {:production => :lot}]).where(
        ["lots.lot_no = IFNULL(?, lots.lot_no) and arrival_ymd IS NULL", cond_lot_no]).order(
        "lots.lot_no desc, process_orders.delivery_ymd desc"
    )

    session_set_prm

    @process_orders = process_orders.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE)
    
    @process_orders.each_with_index{ |process_order, i|
      process_order.no_in_list = i
    }
  end
  
  # 一括発行
  def print_all
    #begin
      @process_orders = []
      @print_all = PrintAll.new

      inputs = process_order_params
      is_valid = true

      inputs.each {|no, input|
        process_order = ProcessOrder.find(input[:id])
        process_order.attributes = input
        process_order.no_in_list = no.to_i
        process_order.select_print = input[:select_print].to_i

        @process_orders << process_order

        next unless process_order.select_print == FLAG_ON

        result = process_order.valid?
        is_valid &&= result
        
        @print_all.targets << process_order
      }

      @process_orders.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return redirect_to :action => :index
      end
      
      cnt = 0
      ActiveRecord::Base::transaction do
        report = AsynchroPrintProcessOrder.prepare_report(@app.user)
        
        @print_all.targets.each{ |process_order|
          process_order.reports << report
          process_order.save!
        }
        
        AsynchroPrintProcessOrder.delay.report(report, @app.user, *@print_all.targets)
#        AsynchroPrintProcessOrder.report(report, @app.user, *@print_all.targets)
      end

      success_id = AsynchroPrintProcessOrder.create_print_message_print_all(@print_all.targets)

      flash[:notice] = t(:success_report_all, :id => success_id)

      redirect_to :action => :index, :params => session[:prm]

    #rescue ActiveRecord::StaleObjectError => so
    #  flash[:error] = t(:error_stale_object)
    #  render :action => :index
    #rescue => e
    #  flash[:error] = t(:error_default, :message => e.message)
    #  render :action => :index
    #end
  end
  
  # 処理済一覧
  def treated_index
    cond_lot_no = nil
    cond_lot_no = params[:cond_lot_no] unless params[:cond_lot_no].blank?
    cond_trader_id = nil
    cond_trader_id = params[:cond_trader_id].to_i unless params[:cond_trader_id].blank?

    @search_cond_date_from_to = SearchCondDateFromTo.new
    @search_cond_date_from_to.set_attributes(params)

    conds = " arrival_ymd IS NOT NULL"
    cond_params = []

    conds += " and lot_no = IFNULL(?, lot_no)"
    cond_params << cond_lot_no
    conds += " and trader_id = IFNULL(?, trader_id)"
    cond_params << cond_trader_id
    unless @search_cond_date_from_to.cond_date_from.nil?
      conds += " and ? <= delivery_ymd"
      cond_params << @search_cond_date_from_to.cond_date_from
    end
    unless @search_cond_date_from_to.cond_date_to.blank?
      conds += " and delivery_ymd < ?"
      cond_params << (@search_cond_date_from_to.cond_date_to + 1.days)
    end
    
    process_orders = ProcessOrder.includes([:production_detail => {:production => :lot}]).where([conds] + cond_params).order(
      "lots.lot_no desc, process_orders.delivery_ymd desc"
    )

    session_set_prm

    @process_orders = process_orders.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  private

  def notice_success(options = {})
    process_order = options[:process_order]
    process_order.id
  end

  def create_options
    @processors = []
    @processors += HeatProcessor.all
    @processors += SurfaceProcessor.all
    @processors += AdditionProcessor.all
  end


  private
    def process_order_params
      #params.require(:process_order).permit
      params.permit(:process_order => [:id, :select_print])[:process_order]
    end
end
