class OrdersController < ApplicationController
  before_action :set_order, :only => [:edit, :update, :destroy, :fix_production, :fix_production_update]

  # 注文登録 get
  def multi_new
    @order_info = OrderInfo.new
    @order_info.order_ymd = Date.today

    @orders = []
    for i in 1..10
      order = Order.new
      order.id = i

      @orders << order
    end
  end

  # 注文登録 post
  def multi_create
    begin
      @order_info = OrderInfo.new(order_info_params)
      is_valid = @order_info.valid?

      @orders = []
      input_cnt = 0
      inputs = orders_multi_create_params
      inputs.each {|k, input|
        order = Order.new(input)
        order.id = k.to_i + 1

        input_cnt += 1 if order.include?

        order.order_no = @order_info.order_no
        order.order_ymd = @order_info.order_ymd

        if order.include?
        order.valid?
        result = order.errors.empty?
        is_valid &&= result
        end

        @orders << order
      }

      @orders.sort!{|a, b| a.id <=> b.id }

      if input_cnt == 0
      @orders[0].force_validate = true
      @orders[0].valid?
      result = @orders[0].errors.empty?
      is_valid &&= result
      end

      if not is_valid
        return render :action => :multi_new
      end

      cnt = 0
      ActiveRecord::Base::transaction do
        @orders.each {|order|
          next unless order.include?
          order.create_relations
          order.save!

          cnt += 1
        }
      end

      flash[:notice] = t(:success_created, :id => (cnt.to_s + t(:cases_unit)))

      redirect_to :action => :index

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :multi_new
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      logger.error(e.message)
puts e.backtrace.join("\n")
      render :action => :multi_new
    end
  end

  # 注文CSV登録 get
  def multi_import
    @orders = []
  end

  # 注文CSV登録 import
  def import
    upload_file = OrderUpload.new(params[:file])
    result = upload_file.import(@orders = [])

    flash[:notice] = t(:success_imported, :msg => (@orders.size.to_s + t(:cases_unit)))

    render :action => :multi_import
  end

  # 注文CSV登録 post
  def multi_import_create
    begin
      is_valid = true

      @orders = []
      input_cnt = 0
      inputs = order_params
      inputs ||= []
      
      inputs.each {|id, input|
        order = Order.new
        order.id = id

        order.attributes = input

        order.valid?
        result = order.errors.empty?
        is_valid &&= result

        @orders << order
      }

      @orders.sort!{|a, b| a.id <=> b.id }

      if not is_valid
        return render :action => :multi_import
      end

      cnt = 0
      ActiveRecord::Base::transaction do
        @orders.each {|order|
          next unless order.include?
          order.create_relations
          order.save!
          cnt += 1
        }
      end

      flash[:notice] = t(:success_created, :id => (cnt.to_s + t(:cases_unit)))

      redirect_to :action => :index

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :multi_import
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      logger.error(e.message)
      render :action => :multi_import
    end
  end

  # GET /%%controller_name%%/
  def index
    orders = Order.includes(:productions).where(
      "orders.necessary_amount IS NULL"
    ).order("orders.delivery_ymd asc, orders.order_ymd asc")

    session_set_prm

    @orders = orders.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /%%controller_name%%/new
  def new
    @order = Order.new
  end

  # GET /%%controller_name%%/1/edit
  def edit
  end

  # PUT /%%controller_name%%/1
  def update
    begin
      @order.attributes = order_params
      if not @order.valid?
        return render :action => :edit
      end

      ActiveRecord::Base::transaction do
        @order.create_relations
        @order.save!
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
    disp_text = @order.productions.first.disp_text
    ActiveRecord::Base::transaction do
      @order.productions.each { |production|
         production.destroy
      }
      @order.destroy
    end

    flash[:notice] = t(:success_deleted, :id => disp_text)
    redirect_to(:action => :index)
  end

  # 注残調整 get
  def fix_production
    @other_orders = find_other_orders(@order)
  end

  # 注残調整 put
  def fix_production_update
    begin
      @order.attributes = order_params

      @other_orders = find_other_orders(@order)

      if not @order.valid?
        return render :action => :fix_production
      end

      #この時点では、生産は１件だけ紐づいている前提
      production = @order.productions.first
      ActiveRecord::Base::transaction do

        production.production_details.each{ |production_detail|
          next unless production_detail.process_detail.process_type.protected_flag == PROTECTED_FLAG_START
          production_detail.result_amount_production = @order.necessary_amount
        }
        production.save!
        @order.save!
      end

      flash[:notice] = t(:success_updated, :id => notice_success)
      redirect_to :action => :fix_production

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :fix_production
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :fix_production
    end
  end

  # 材料確定 get
  def fix_parts
    productions = Production.includes(:order).where(["orders.necessary_amount IS NOT NULL and productions.parts_fix_flag = ?", FLAG_OFF]).order(Order.delivery_ymd_asc + ", " + Production.vote_no_asc).references(:order)

    session_set_prm

    @productions = productions.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);

    @partses = []
    cnt = 1
    @productions.each { |production|
      parts = Parts.new
      parts.no_in_list = cnt
      parts.production = production
      parts.fix_flag = FLAG_OFF

      material = production.materials.first
      unless material.nil?
        parts.material_id = material.id
        parts.material = material
        parts.material.calc_amount!
      end
      washer_production_seq1 = production.washer_production_seqs.where(seq: 1).first
      unless washer_production_seq1.nil?
        parts.washer_id1 = washer_production_seq1.washer.id
        parts.washer1 = washer_production_seq1.washer
        parts.washer1.calc_amount!
      end
      washer_production_seq2 = production.washer_production_seqs.where(seq: 2).first
      unless washer_production_seq2.nil?
        parts.washer_id2 = washer_production_seq2.washer.id
        parts.washer2 = washer_production_seq2.washer
        parts.washer2.calc_amount!
      end

      @partses << parts

      cnt += 1
    }
  end

  # 材料確定 put
  def fix_parts_update
    #begin
      @partses = []

      inputs = params[:parts]
      is_valid = true

      inputs.each {|no, input|
        parts = Parts.new
        parts.set_attributes(input)
        parts.no_in_list = no.to_i

        production = Production.find(input[:production_id])
        production.lock_version = input[:production_lock_version]

        parts.production = production

        @partses << parts

        next unless parts.fix_flag == FLAG_ON

        result = parts.valid?
        is_valid &&= result
      }

      @partses.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return render :action => :fix_parts
      end

      cnt = 0
      ActiveRecord::Base::transaction do
        @partses.each {|parts|
          next unless parts.fix_flag == FLAG_ON

          production = parts.production
          production.fix_parts(parts)

          production.save!
          cnt += 1
        }
      end

      flash[:notice] = t(:success_updated, :id => (cnt.to_s  + I18n.t(:cases_unit)))

      redirect_to :action => :fix_parts, :params => session[:prm]

    #rescue ActiveRecord::StaleObjectError => so
    #  flash[:error] = t(:error_stale_object)
    #  render :action => :fix_parts
    #rescue => e
    #  flash[:error] = t(:error_default, :message => e.message)
    #  render :action => :fix_parts
    #end
  end

  #=============================================================================

  private


  def notice_success(options = {})
    @order.productions.first.disp_text
  end

  def find_other_orders(order)
    production = order.productions.first
      
    conds =  " orders.id <> ?"
    conds += " and production_details.result_amount_production IS NOT NULL"
    # 2012.10.22 Modify N.Hanamura
    conds += " and productions.vote_no IN (SELECT distinct(productions.vote_no) FROM productions where productions.summation_id IS NULL)"
    #conds += " and productions.summation_id IS NULL"
    conds += " and productions.item_id = ?"

    other_orders = Order.includes([:productions => [:production_details => [:process_detail => :process_type]]]).where([conds, order.id, production.item_id]).order(Order.delivery_ymd_asc + ", " + Production.vote_no_asc + ", " + ProcessType.seq_asc).references(:productions, :production_detials, :process_detail, :process_type)

    other_orders.each {|order|
      order.sum_result_amount = 0

      order.productions.each {|production|
        production.production_details.each {|production_detail|
        order.sum_result_amount += production_detail.result_amount_production.to_i
        }
      }
    }

    return other_orders
  end


  private
    def set_order
       @order = find_order(params[:id])
    end

  def find_order(id)
    order = Order.find(id)
    order.productions.first&.tap {|production|
      order.vote_no = production.vote_no
      production.item&.tap {|item|
        order.item_customer_code = item.customer_code
        order.item_code = item.code
      }
    }

    return order
  end

    def order_params
      params.require(:order).permit(:hd_addition, :ro1_addition, :ro2_addition, :heat_addition, :surface_addition, :inspection_addition, :lock_version, :item_id, :necessary_amount)
    end

    def order_info_params
      params.require(:order_info).permit(:order_no, :order_ymd)
    end

    def orders_multi_create_params
      params.permit(:order => [:delivery_ymd, :order_amount, :item_customer_code, :item_code])[:order].to_h
    end
end
