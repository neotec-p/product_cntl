require 'validations_adapter'

class ProductionsController < ApplicationController
  before_action :create_status_options, :only => [:index, :print_all, :edit, :update]
  
  before_action :set_production, only: [:edit, :update, :edit_material, :edit_material_update, :edit_washer, :div_branch, :div_branch_update, :div_lot, :div_lot_update]

  def index
    production_details = ProductionDetail.filter_by_productions(params[:cond_process_type_id], params[:cond_status_id], params[:cond_item_customer_code], params[:cond_item_code], params[:sort], params[:order], params[:cond_unprinted])

    session_set_prm

    @production_details = production_details.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE_PRODUCT)

    @production_details.each_with_index{ |production_detail, i|
      production_detail.no_in_list = i
    }
  end

  # 一括発行
  def print_all
    begin
      @production_details = []
      target_productions = []

      inputs = production_detail_params
      is_valid = true

      inputs.each {|k, input|
        production_detail = ProductionDetail.find(input[:id])
        production_detail.attributes = input
        production_detail.no_in_list = k.to_i + 1
        production_detail.select_print = input[:select_print].to_i

        @production_details << production_detail

        next unless production_detail.select_print == FLAG_ON

        result = production_detail.valid?
        is_valid &&= result

        if not target_productions.include?(production_detail.production)
          target_productions << production_detail.production
        end
      }

      return render :action => :index if !is_valid or target_productions.empty?

      target_productions = target_productions.sort {|a, b| a.disp_text <=> b.disp_text }
      ActiveRecord::Base::transaction do
        report = AsynchroPrintProduction.prepare_report(@app.user)
        
        target_productions.each {|production|
          production.reports << report
          production.save!
        }
        
        AsynchroPrintProduction.delay.report(report, @app.user, *target_productions)
#        AsynchroPrintProduction.report(report, @app.user, *@print_all.targets)
      end

      success_id = AsynchroPrintProduction.create_print_message_print_all(target_productions)
      flash[:notice] = t(:success_report_all, :id => success_id)

      redirect_to :action => :index, :params => session[:prm]

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :index
    rescue => e
puts e.message
puts e.backtrace.join("\n")
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :index
    end
  end
  
  # 管理NO別一覧
  def vote_no_index
    cond_vote_no = ""
    cond_vote_no = params[:cond_vote_no] unless params[:cond_vote_no].blank?

    if cond_vote_no.blank?
      @production_details = []
      return
    end

    conds  = " productions.vote_no = ?"
    conds += " and production_details.result_amount_production IS NOT NULL"
    conds += " and productions.parts_fix_flag = ?"
    # 2012.10.22 Modify N.Hanamura
    conds += " and EXISTS(SELECT * FROM productions where productions.vote_no = ? and productions.summation_id IS NULL)"
    #conds += " and productions.summation_id IS NULL"

    #@production_details = ProductionDetail.all.includes([[:process_detail => :process_type], [:production => :order]]).where([conds, cond_vote_no, FLAG_ON, cond_vote_no]).order(Order.delivery_ymd_asc + ", " + Production.vote_no_asc + ", " + ProcessType.seq_asc)
    @production_details = ProductionDetail.filter_with_vote_no(params[:cond_vote_no])

    sum_result_amount
    session_set_prm
  end

  # 商品コード別一覧
  def item_code_index
    cond_item_customer_code = nil
    cond_item_customer_code = params[:cond_item_customer_code] unless params[:cond_item_customer_code].blank?
    cond_item_code = nil
    cond_item_code = params[:cond_item_code] unless params[:cond_item_code].blank?

    if cond_item_customer_code.blank?
      @production_details = []
      return
    end

    conds  = " production_details.result_amount_production IS NOT NULL"
    conds += " and productions.parts_fix_flag = ?"
    # 2012.10.22 Modify N.Hanamura
    conds += " and productions.vote_no IN (SELECT distinct(productions.vote_no) FROM productions where productions.summation_id IS NULL)"
    #conds += " and productions.summation_id IS NULL"

    cond_params = [FLAG_ON]

    conds += " and productions.customer_code = IFNULL(?, productions.customer_code)"
    cond_params << cond_item_customer_code

    unless cond_item_code.blank?
      conds += " and productions.code = IFNULL(?, productions.code)"
      cond_params << cond_item_code
    end

    @production_details = ProductionDetail.includes([[:process_detail => :process_type], [:production => :order]]).where([conds] + cond_params).order(Order.delivery_ymd_asc + ", " + Production.vote_no_asc + ", " + ProcessType.seq_asc)

    sum_result_amount
    session_set_prm
  end

  # 材料別一覧
  def material_index
    create_material_standard_options
    
    cond_standard = ""
    cond_standard = params[:cond_standard] if params[:cond_standard]
    cond_diameter = ""
    cond_diameter = params[:cond_diameter] if params[:cond_diameter]

    conds  = " production_details.result_amount_production IS NOT NULL"
    conds += " and productions.parts_fix_flag = ?"
    conds += " and productions.summation_id IS NULL"

    cond_params = [FLAG_ON]

    unless cond_standard.blank?
      conds += " and materials.standard = ?"
    cond_params << cond_standard
    end
    unless cond_diameter.blank?
      conds += " and materials.diameter = ?"
    cond_params << cond_diameter.to_d
    end

    production_details = ProductionDetail.includes([[:process_detail => :process_type], [:production => :order], [:production => :materials]]).where([conds] + cond_params).order(Order.delivery_ymd_asc + ", " + Production.vote_no_asc + ", " + ProcessType.seq_asc)

    session_set_prm

    @production_details = production_details.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE_EDIT);
    
    if (!cond_standard.blank? && !cond_diameter.blank?)
      conds  = ""
      cond_params = []
      
      conds  = " standard = ?"
      cond_params << cond_standard
      conds += " and diameter = ?"
      cond_params << cond_diameter.to_d
    
      @materials = Material.where([conds] + cond_params).order("standard asc, diameter asc, surface asc")
      @materials.each{ |material|
        material.calc_amount!
      }
    end
    @materials ||= []
  end

  # 工程管理 get
  def edit
    @production.sort_production_details!
    
    notice_force_submit
  end

  # 工程管理 put
  def update
    @production.attributes = production_params
    @production.sort_production_details!

    unless @production.valid?
      puts "invalid? : #{@production.inspect}"
      puts "error: #{@production.errors.full_messages.join(',')}"
      return render :action => :edit
    end

    cnt = 0
    success_message = :success_updated
    success_id = notice_success
    ActiveRecord::Base::transaction do
      if params[:new_lot]
        lot = @production.create_new_lot
        @production.lot = lot

        if not @production.valid?
          return render :action => :edit
        end

        success_message = :success_new_lot
      success_id = lot.lot_no
      end

      if params[:report]
        report = AsynchroPrintProduction.prepare_report(@app.user)

        @production.reports << report

        targets = [@production]

        AsynchroPrintProduction.delay.report(report, @app.user, *targets)

        success_message = :success_report
        success_id = ReportType.report_name(REPORT_TYPE_T010)
      end

      @production.save!
    end

    #分割、枝番発行へ遷移
    return redirect_to(:action => :div_branch, :id => @production.id) if params[:div_branch]
    return redirect_to(:action => :div_lot, :id => @production.id) if params[:div_lot]
      
    #二次加工先へ遷移
    if params[:heat_process_orders] || params[:surface_process_orders] || params[:addition_process_orders]
      pd = ProductionDetail.find(params[:process_order_production_detail_id])
      
      action = :new
      process_order = ProcessOrder.new
      po_id = nil
      unless pd.process_order.nil?
        action = :edit
        po_id = pd.process_order.id
      end
         
      return redirect_to(:controller => :heat_process_orders, :action => action, :id => po_id, :production_detail_id => pd.id) if params[:heat_process_orders]
      return redirect_to(:controller => :surface_process_orders, :action => action, :id => po_id, :production_detail_id => pd.id) if params[:surface_process_orders]
      return iedirect_to(:controller => :addition_process_orders, :action => action, :id => po_id, :production_detail_id => pd.id) if params[:addition_process_orders]
    end
      
    flash[:notice] = t(success_message, :id => success_id)

    redirect_to :action => :edit
  end

  # 機種選択 get
  def multi_model
    #joins  = " INNER JOIN production_details"
    #joins += " ON productions.id = production_details.production_id"
    #joins  = " INNER JOIN process_details"
    #joins += " ON process_details.id = production_details.process_detail_id"
    #joins += " INNER JOIN process_types"
    #joins += " ON process_types.id = process_details.process_type_id"

    #conds  = " production_details.result_amount_production IS NOT NULL"
    #conds  = " process_types.seq <= ?"
    #conds += " and productions.parts_fix_flag = ?"
    #conds += " and productions.summation_id IS NULL"

    productions = Production.includes([:order, :production_details, :production_details => { :process_detail => :process_type }])
                     .where.not(production_details: { result_amount_production: nil })
                     .where(["process_types.seq <= ?", ProcessType.last_inner_process_type.seq])
                     .where(productions: { parts_fix_flag: FLAG_ON })
                     .where(productions: { summation_id: nil })
                     .order("orders.delivery_ymd asc, productions.vote_no asc")

    @productions = productions.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE_EDIT)

    session_set_prm

    @production_plans = []
    cnt = 1
    @productions.each { |production|

      production_plan = ProductionPlan.new
      production_plan.no_in_list = cnt
      production_plan.production = production

      production.production_details.each { |production_detail|
        case production_detail.process_type.plan_process_flag
        when PLAN_PROCESS_FLAG_HD
          production_plan.hd_model_id = production_detail.model_id
          production_plan.hd_model_id_options = production_detail.create_model_options
        when PLAN_PROCESS_FLAG_HD_ADDITION
          production_plan.hd_addition_model_id = production_detail.model_id
          production_plan.hd_addition_model_id_options = production_detail.create_model_options
        when PLAN_PROCESS_FLAG_RO1
          production_plan.ro1_model_id = production_detail.model_id
          production_plan.ro1_model_id_options = production_detail.create_model_options
        when PLAN_PROCESS_FLAG_RO1_ADDITION
          production_plan.ro1_addition_model_id = production_detail.model_id
          production_plan.ro1_addition_model_id_options = production_detail.create_model_options
        when PLAN_PROCESS_FLAG_RO2
          production_plan.ro2_model_id = production_detail.model_id
          production_plan.ro2_model_id_options = production_detail.create_model_options
        when PLAN_PROCESS_FLAG_RO2_ADDITION
          production_plan.ro2_addition_model_id = production_detail.model_id
          production_plan.ro2_addition_model_id_options = production_detail.create_model_options
        else
        # do nothing
        end
      }

      @production_plans << production_plan

      cnt += 1
    }
  end

  # 日程計画 put
  def multi_model_update
    begin
      @production_plans = []

      inputs = params[:production_plan]
      is_valid = true

      inputs.each {|no, input|
        production_plan = ProductionPlan.new
        production_plan.set_attributes(input)
        production_plan.no_in_list = no.to_i

        production = Production.find(input[:production_id])
        production.lock_version = input[:production_lock_version]
        production_plan.production = production

        production_detail = production.find_by_plan_process_flag(PLAN_PROCESS_FLAG_HD)
        production_plan.hd_model_id_options = production_detail.create_model_options unless production_detail.nil?
        production_detail = production.find_by_plan_process_flag(PLAN_PROCESS_FLAG_HD_ADDITION)
        production_plan.hd_addition_model_id_options = production_detail.create_model_options unless production_detail.nil?
        production_detail = production.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO1)
        production_plan.ro1_model_id_options = production_detail.create_model_options unless production_detail.nil?
        production_detail = production.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO1_ADDITION)
        production_plan.ro1_addition_model_id_options = production_detail.create_model_options unless production_detail.nil?
        production_detail = production.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO2)
        production_plan.ro2_model_id_options = production_detail.create_model_options unless production_detail.nil?
        production_detail = production.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO2_ADDITION)
        production_plan.ro2_addition_model_id_options = production_detail.create_model_options unless production_detail.nil?

        result = production_plan.valid?
        is_valid &&= result

        @production_plans << production_plan
      }

      @production_plans.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return render :action => :multi_model
      end

      cnt = 0
      ActiveRecord::Base::transaction do
        @production_plans.each {|production_plan|
          production = production_plan.production
          production.set_model(production_plan)
          
          production.save!
          cnt += 1
        }
      end

      flash[:notice] = t(:success_updated, :id => (cnt.to_s  + I18n.t(:cases_unit)))

      redirect_to :action => :multi_model, :params => session[:prm]

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :multi_model
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :multi_model
    end
  end

  # 日程計画 get
  def multi_plan
    cond_process_category = nil
    cond_process_category = params[:cond_process_category].to_i unless params[:cond_process_category].blank?
    cond_model_id = nil
    cond_model_id = params[:cond_model_id].to_i unless params[:cond_model_id].blank?

    create_plans_select_options

    joins  = " INNER JOIN production_details"
    joins += " ON productions.id = production_details.production_id"
    joins += " INNER JOIN process_details"
    joins += " ON process_details.id = production_details.process_detail_id"
    joins += " INNER JOIN process_types"
    joins += " ON process_types.id = process_details.process_type_id"

    conds  = " production_details.result_amount_production IS NOT NULL"
    conds += " and process_types.seq <= ?"
    conds += " and productions.parts_fix_flag = ?"
    conds += " and productions.id in ("
    conds += "     SELECT production_details.production_id"
    conds += "       FROM production_details"
    conds += "      INNER JOIN process_details"
    conds += "         ON process_details.id = production_details.process_detail_id"
    conds += "      INNER JOIN process_types"
    conds += "         ON process_types.id = process_details.process_type_id"
    conds += "      WHERE process_types.plan_process_flag in (?)"
    conds += "        and production_details.model_id IS NOT NULL"
    conds += "        and production_details.model_id = ?"
    conds += "     )"
    conds += " and productions.summation_id IS NULL"

    cond_process_flags = []
    case cond_process_category
    when PROCESS_CATEGORY_HD
      cond_process_flags = ProcessType.plan_process_flags_hd
    when PROCESS_CATEGORY_RO
      cond_process_flags = ProcessType.plan_process_flags_ro
    end

    productions = Production.joins(joins).includes([:order]).where([conds, ProcessType.last_inner_process_type.seq, FLAG_ON, cond_process_flags, cond_model_id]).order(Order.delivery_ymd_asc + ", " + Production.vote_no_asc)

    @productions = productions.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE_EDIT)

    session_set_prm

    @production_plans = []
    cnt = 1
    @productions.each { |production|

      production_plan = ProductionPlan.new
      production_plan.no_in_list = cnt
      production_plan.production = production

      production.production_details.each { |production_detail|
        case production_detail.process_type.plan_process_flag
        when PLAN_PROCESS_FLAG_HD
          production_plan.hd_start_ymd_edit_flag = true
          production_plan.hd_start_ymd = production_detail.plan_start_ymd
          production_plan.hd_end_ymd_edit_flag = true
          production_plan.hd_end_ymd = production_detail.plan_end_ymd

          if (cond_process_category == PROCESS_CATEGORY_RO) || (cond_model_id != production_detail.model_id)
            production_plan.hd_start_ymd_edit_flag = false
            production_plan.disp_hd_start_ymd = production_detail.plan_start_ymd
            production_plan.hd_end_ymd_edit_flag = false
            production_plan.disp_hd_end_ymd = production_detail.plan_end_ymd
          end
          unless production_detail.result_start_ymd.blank?
            production_plan.hd_start_ymd_edit_flag = false
            production_plan.hd_start_ymd = production_detail.result_start_ymd
            production_plan.disp_hd_start_ymd = production_detail.result_start_ymd
          end
          unless production_detail.result_end_ymd.blank?
            production_plan.hd_end_ymd_edit_flag = false
            production_plan.hd_end_ymd = production_detail.result_end_ymd
            production_plan.disp_hd_end_ymd = production_detail.result_end_ymd
          end
        when PLAN_PROCESS_FLAG_HD_ADDITION
          production_plan.hd_addition_start_ymd_edit_flag = true
          production_plan.hd_addition_start_ymd = production_detail.plan_start_ymd
          production_plan.hd_addition_end_ymd_edit_flag = true
          production_plan.hd_addition_end_ymd = production_detail.plan_end_ymd

          if (cond_process_category == PROCESS_CATEGORY_RO) || (cond_model_id != production_detail.model_id)
            production_plan.hd_addition_start_ymd_edit_flag = false
            production_plan.disp_hd_addition_start_ymd = production_detail.plan_start_ymd
            production_plan.hd_addition_end_ymd_edit_flag = false
            production_plan.disp_hd_addition_end_ymd = production_detail.plan_end_ymd
          end
          unless production_detail.result_start_ymd.blank?
            production_plan.hd_addition_start_ymd_edit_flag = false
            production_plan.hd_addition_start_ymd = production_detail.result_start_ymd
            production_plan.disp_hd_addition_start_ymd = production_detail.result_start_ymd
          end
          unless production_detail.result_end_ymd.blank?
            production_plan.hd_addition_end_ymd_edit_flag = false
            production_plan.hd_addition_end_ymd = production_detail.result_end_ymd
            production_plan.disp_hd_addition_end_ymd = production_detail.result_end_ymd
          end
        when PLAN_PROCESS_FLAG_RO1
          production_plan.ro1_start_ymd_edit_flag = true
          production_plan.ro1_start_ymd = production_detail.plan_start_ymd
          production_plan.ro1_end_ymd_edit_flag = true
          production_plan.ro1_end_ymd = production_detail.plan_end_ymd

          if (cond_process_category == PROCESS_CATEGORY_HD) || (cond_model_id != production_detail.model_id)
            production_plan.ro1_start_ymd_edit_flag = false
            production_plan.disp_ro1_start_ymd = production_detail.plan_start_ymd
            production_plan.ro1_end_ymd_edit_flag = false
            production_plan.disp_ro1_end_ymd = production_detail.plan_end_ymd
          end
          unless production_detail.result_start_ymd.blank?
            production_plan.ro1_start_ymd_edit_flag = false
            production_plan.ro1_start_ymd = production_detail.result_start_ymd
            production_plan.disp_ro1_start_ymd = production_detail.result_start_ymd
          end
          unless production_detail.result_end_ymd.blank?
            production_plan.ro1_end_ymd_edit_flag = false
            production_plan.ro1_end_ymd = production_detail.result_end_ymd
            production_plan.disp_ro1_end_ymd = production_detail.result_end_ymd
          end
        when PLAN_PROCESS_FLAG_RO1_ADDITION
          production_plan.ro1_addition_start_ymd_edit_flag = true
          production_plan.ro1_addition_start_ymd = production_detail.plan_start_ymd
          production_plan.ro1_addition_end_ymd_edit_flag = true
          production_plan.ro1_addition_end_ymd = production_detail.plan_end_ymd

          if (cond_process_category == PROCESS_CATEGORY_HD) || (cond_model_id != production_detail.model_id)
            production_plan.ro1_addition_start_ymd_edit_flag = false
            production_plan.disp_ro1_addition_start_ymd = production_detail.plan_start_ymd
            production_plan.ro1_addition_end_ymd_edit_flag = false
            production_plan.disp_ro1_addition_end_ymd = production_detail.plan_end_ymd
          end
          unless production_detail.result_start_ymd.blank?
            production_plan.ro1_addition_start_ymd_edit_flag = false
            production_plan.ro1_addition_start_ymd = production_detail.result_start_ymd
            production_plan.disp_ro1_addition_start_ymd = production_detail.result_start_ymd
          end
          unless production_detail.result_end_ymd.blank?
            production_plan.ro1_addition_end_ymd_edit_flag = false
            production_plan.ro1_addition_end_ymd = production_detail.result_end_ymd
            production_plan.disp_ro1_addition_end_ymd = production_detail.result_end_ymd
          end
        when PLAN_PROCESS_FLAG_RO2
          production_plan.ro2_start_ymd_edit_flag = true
          production_plan.ro2_start_ymd = production_detail.plan_start_ymd
          production_plan.ro2_end_ymd_edit_flag = true
          production_plan.ro2_end_ymd = production_detail.plan_end_ymd

          if (cond_process_category == PROCESS_CATEGORY_HD) || (cond_model_id != production_detail.model_id)
            production_plan.ro2_start_ymd_edit_flag = false
            production_plan.disp_ro2_start_ymd = production_detail.plan_start_ymd
            production_plan.ro2_end_ymd_edit_flag = false
            production_plan.disp_ro2_end_ymd = production_detail.plan_end_ymd
          end
          unless production_detail.result_start_ymd.blank?
            production_plan.ro2_start_ymd_edit_flag = false
            production_plan.ro2_start_ymd = production_detail.result_start_ymd
            production_plan.disp_ro2_start_ymd = production_detail.result_start_ymd
          end
          unless production_detail.result_end_ymd.blank?
            production_plan.ro2_end_ymd_edit_flag = false
            production_plan.ro2_end_ymd = production_detail.result_end_ymd
            production_plan.disp_ro2_end_ymd = production_detail.result_end_ymd
          end
        when PLAN_PROCESS_FLAG_RO2_ADDITION
          production_plan.ro2_addition_start_ymd_edit_flag = true
          production_plan.ro2_addition_start_ymd = production_detail.plan_start_ymd
          production_plan.ro2_addition_end_ymd_edit_flag = true
          production_plan.ro2_addition_end_ymd = production_detail.plan_end_ymd

          if (cond_process_category == PROCESS_CATEGORY_HD) || (cond_model_id != production_detail.model_id)
            production_plan.ro2_addition_start_ymd_edit_flag = false
            production_plan.disp_ro2_addition_start_ymd = production_detail.plan_start_ymd
            production_plan.ro2_addition_end_ymd_edit_flag = false
            production_plan.disp_ro2_addition_end_ymd = production_detail.plan_end_ymd
          end
          unless production_detail.result_start_ymd.blank?
            production_plan.ro2_addition_start_ymd_edit_flag = false
            production_plan.ro2_addition_start_ymd = production_detail.result_start_ymd
            production_plan.disp_ro2_addition_start_ymd = production_detail.result_start_ymd
          end
          unless production_detail.result_end_ymd.blank?
            production_plan.ro2_addition_end_ymd_edit_flag = false
            production_plan.ro2_addition_end_ymd = production_detail.result_end_ymd
            production_plan.disp_ro2_addition_end_ymd = production_detail.result_end_ymd
          end
        else
        # do nothing
        end
      }

      @production_plans << production_plan

      cnt += 1
    }
  end

  # 日程計画 put
  def multi_plan_update
    begin
    #絞込条件を復元
      if session[:prm]
        params[:cond_process_category] = session[:prm][:cond_process_category]
        params[:cond_model_id] = session[:prm][:cond_model_id]
      end

      create_plans_select_options

      @production_plans = []

      inputs = params[:production_plan]
      is_valid = true

      inputs.each {|no, input|
        production_plan = ProductionPlan.new
        production_plan.set_attributes(input)
        production_plan.no_in_list = no.to_i

        production = Production.find(input[:production_id])
        production.lock_version = input[:production_lock_version]

        production_plan.production = production

        result = production_plan.valid?
        is_valid &&= result

        @production_plans << production_plan
      }

      @production_plans.sort!{|a, b| a.no_in_list <=> b.no_in_list }

      if not is_valid
        return render :action => :multi_plan
      end
      cnt = 0
      ActiveRecord::Base::transaction do
        @production_plans.each {|production_plan|
        production = production_plan.production
        
        production.set_plan(production_plan)
          production.save!
          cnt += 1
        }
      end

      flash[:notice] = t(:success_updated, :id => (cnt.to_s  + I18n.t(:cases_unit)))
      redirect_to :action => :multi_plan, :params => session[:prm]

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :multi_plan
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :multi_plan
    end
  end


  # 日程計画表印刷
  def print_t040
    begin
      create_plans_select_options
      @production_plans = []
      
      process_category = PROCESS_CATEGORY_RO
      process_category = PROCESS_CATEGORY_HD if params[:print_t040]
      
      target_ymd_month = Summation.get_current_month
      year = target_ymd_month.year
      month = target_ymd_month.month
      
      # 検索対象年月のカレンダーマスタが存在しなければ、バリデーションエラー
      calendars = Calendar.where(["year = ? and month = ?", year, month]).order(["year, month, day"])
      
      if calendars.empty?
        flash[:error] = t(:error_valid_calendars, :ym => l(target_ymd_month, :format => "%Y/%m"))
        render :action => :multi_plan
        return
      end
      
      ActiveRecord::Base::transaction do
        report = AsynchroPrintProductionPlanList.prepare_report_with_process_category(@app.user, process_category)
        
        AsynchroPrintProductionPlanList.delay.report_with_process_category(report, @app.user, process_category, *target_ymd_month)
#        AsynchroPrintProductionPlanList.report_with_process_category(report, @app.user, process_category, *target_ymd_month)
      end

      success_id = AsynchroPrintProductionPlanList.create_print_message_print_all(["dummmy"])
      flash[:notice] = t(:success_report_all, :id => success_id)
      
      redirect_to :action => :multi_plan

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :multi_plan
    rescue => e
puts e.message
puts e.backtrace.join("\n")
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :multi_plan
    end
  end
  

  # 枝番発行 get
  def div_branch
    @production_div = ProductionDiv.new
    @production_div.vote_no = @production.vote_no
    @production_div.production_lock_version = @production.lock_version

    @all_branches = Production.find_by_vote_no(@production.vote_no)
  end

  # 枝番発行 put
  def div_branch_update
    begin
      @all_branches = Production.find_by_vote_no(@production.vote_no)

      @production_div = ProductionDiv.new
      @production_div.set_attributes(params)

      @production.lock_version = @production_div.production_lock_version

      if not @production_div.valid?
        return render :action => :div_branch
      end

      ActiveRecord::Base::transaction do
        new_production = @production.div_branch(@production_div)
        new_production.save!
        @production.save!
      end

      flash[:notice] = t(:success_updated, :id => notice_success)

      redirect_to :action => :div_branch, :id => @production.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :div_branch
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :div_branch
    end
  end

  # ロット分割 get
  def div_lot
    @lot_div = LotDiv.new
    @lot_div.vote_no = @production.vote_no
    @lot_div.production_lock_version = @production.lock_version
    
    @lot_div.lot_exist_flag = FLAG_ON unless @production.lot.nil?
    @lot_div.lot_exist_flag ||= FLAG_OFF

    @all_branches = Production.find_by_vote_no(@production.vote_no)
  end

  # ロット分割 put
  def div_lot_update
    begin
      @all_branches = Production.find_by_vote_no(@production.vote_no)

      @lot_div = LotDiv.new
      @lot_div.set_attributes(params)

      @production.lock_version = @lot_div.production_lock_version

      if not @lot_div.valid?
        return render :action => :div_lot
      end

      ActiveRecord::Base::transaction do
        new_production = @production.div_lot(@lot_div)
        new_production.save!
        @production.save!
      end

      flash[:notice] = t(:success_updated, :id => notice_success)

      redirect_to :action => :div_lot, :id => @production.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :div_lot
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :div_lot
    end
  end

  # 材料管理 get
  def edit_material
    @material_edit = MaterialEdit.new

    material1 = @production.materials.first
    @material_edit.material_id = material1.id unless material1.nil?

    @material_edit.production_lock_version = @production.lock_version

    material_stock_production_seqs = @production.material_stock_production_seqs.all.order(:seq)

    material_stock_production_seqs.each{ |material_stock_production_seq|
      case material_stock_production_seq.seq
      when 1
        @material_edit.material_stock_id1 = material_stock_production_seq.material_stock_id
      when 2
        @material_edit.material_stock_id2 = material_stock_production_seq.material_stock_id
      when 3
        @material_edit.material_stock_id3 = material_stock_production_seq.material_stock_id
      else
      #do nothing
      end
    }

    notice_force_submit
  end

  # 材料管理 put
  def edit_material_update
    begin
      @material_edit = MaterialEdit.new
      @material_edit.set_attributes(params)

      @production.lock_version = @material_edit.production_lock_version

      if not @material_edit.valid?
        return render :action => :edit_material
      end

      ActiveRecord::Base::transaction do
        @production.edit_material(@material_edit)
        @production.save!
      end

      flash[:notice] = t(:success_updated, :id => notice_success)

      redirect_to :action => :edit_material, :id => @production.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit_material
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit_material
    end
  end

  # 座金管理 get
  def edit_washer
    @washer_edit = WasherEdit.new
    washer1 = @production.washers.where(washer_production_seqs: { seq: 1 }).first
    @washer_edit.washer_id1 = washer1.id unless washer1.nil?
    washer2 = @production.washers.where(washer_production_seqs: { seq: 2 }).first
    @washer_edit.washer_id2 = washer2.id unless washer2.nil?

    @washer_edit.production_lock_version = @production.lock_version

    washer_stock_production_seqs = @production.washer_stock_production_seqs.all.order(:seq)

    washer_stock_production_seqs.each{ |washer_stock_production_seq|
      case washer_stock_production_seq.seq
      when 1
        @washer_edit.washer_stock_id1 = washer_stock_production_seq.washer_stock_id
      when 2
        @washer_edit.washer_stock_id2 = washer_stock_production_seq.washer_stock_id
      when 3
        @washer_edit.washer_stock_id3 = washer_stock_production_seq.washer_stock_id
      when 4
        @washer_edit.washer_stock_id4 = washer_stock_production_seq.washer_stock_id
      when 5
        @washer_edit.washer_stock_id5 = washer_stock_production_seq.washer_stock_id
      when 6
        @washer_edit.washer_stock_id6 = washer_stock_production_seq.washer_stock_id
      else
      #do nothing
      end
    }
    
    @washer_edit.washer_stock_rel_flag1 = FLAG_ON unless @production.washer_stocks1.empty?
    @washer_edit.washer_stock_rel_flag2 = FLAG_ON unless @production.washer_stocks2.empty?
    
    notice_force_submit
  end

  # 座金管理 put
  def edit_washer_update
    begin
      @washer_edit = WasherEdit.new
      @washer_edit.set_attributes(params)

      @production.lock_version = @washer_edit.production_lock_version

      @washer_edit.relate_auto(@production)
      
      if not @washer_edit.errors.empty?
        return render :action => :edit_washer
      end
      if not @washer_edit.valid?
        return render :action => :edit_washer
      end

      ActiveRecord::Base::transaction do
        @production.edit_washer(@washer_edit)
        @production.save!
      end

      flash[:notice] = t(:success_updated, :id => notice_success)

      redirect_to :action => :edit_washer, :id => @production.id

    rescue ActiveRecord::StaleObjectError => so
      flash[:rror] = t(:error_stale_object)
      render :action => :edit_washer
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit_washer
    end
  end

  # 生産高 get
  def yeild_index
    target_ymd_start = Summation.get_current_month.beginning_of_month
    target_ymd_end = Summation.get_current_month.end_of_month

    create_status_options

    productions = Production.filter_by_yeild(target_ymd_start, target_ymd_end, params[:cond_process_type_id])

    total_price = 0
    total_prices_by_keys = Hash.new {|h, k| h[k] = 0 }
    productions.each {|production|
      production_details = production.production_details.includes([:process_detail => :process_type]).order("process_types.seq desc")
      
      amount = 0
      production_details.each {|production_detail|
        amount += production_detail.result_amount_production unless production_detail.result_amount_production.blank?
        
        #計算するのは、HD、HD+、RO1、RO1+、RO2、RO2+だけ
        next if not ProcessType.plan_process_flags.include?(production_detail.process_type.plan_process_flag)
        
        #実績開始日と実績終了日が入力されていなければスキップ
        next if (production_detail.result_start_ymd.blank? || production_detail.result_end_ymd.blank?)
        #実績開始日 > 実績終了日もスキップ
        next if production_detail.result_start_ymd > production_detail.result_end_ymd
        #実績開始日 <= 計算期間開始日 かつ、計算期間終了日 <= 実績開始日だけが対象
        next if not (production_detail.result_start_ymd <= target_ymd_end and target_ymd_start <= production_detail.result_end_ymd)

        #可動日での日割計算
        all_working_days = Calendar.count_working_days(production_detail.result_start_ymd, production_detail.result_end_ymd)
        
        term_start_date = production_detail.result_start_ymd
        term_start_date = target_ymd_start if production_detail.result_start_ymd < target_ymd_start
        term_end_date = production_detail.result_end_ymd
        term_end_date = target_ymd_end if target_ymd_end < production_detail.result_end_ymd
        
        term_working_days = Calendar.count_working_days(term_start_date, term_end_date)
        
        # (期間内補正後の稼働日 / 元々の期間の稼働日)
        working_days_ratio = 0
        working_days_ratio = (term_working_days.to_d / all_working_days.to_d) unless all_working_days == 0

        # 工程日の取得
        process_expense = production_detail.calc_sum_process_expense_yeild
        
        #数量 * 工程費 * (期間内補正後の稼働日 / 元々の期間の稼働日)
        price = amount * process_expense * working_days_ratio
        
        if params[:cond_process_type_id].blank? or params[:cond_process_type_id].to_i == production_detail.process_type.id
          total_prices_by_keys[production_detail.process_type] += price
          total_price += price
        end
      }
    }
    
    @total_prices_by_keys = total_prices_by_keys.map {|k, v| [k, v / 1000] }.sort.to_h
    @total_price_k = total_price / 1000

    production_details = ProductionDetail.filter_by_productions(params[:cond_process_type_id], params[:cond_status_id], params[:cond_item_customer_code], params[:cond_item_code], params[:sort], params[:order], params[:cond_unprinted])

    @production_details = production_details.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE_PRODUCT)

    @production_details.each_with_index{ |production_detail, i|
      production_detail.no_in_list = i
    }

  end

  def pop_model_production_plan
    model_id = params[:model_id]
    
    unless model_id.blank?
      @model = Model.find(model_id)
      
      unless @model.nil?
        current_date = Date.today.beginning_of_week
        @plans = []
        POP_MODEL_PRODUCTION_PLAN_WEEKS.times { |i|
          7.times { |j|
            plan = {}
            
            plan[:date] = current_date
            plan[:date_class] = ('date-today' if current_date.today?) || ''

            plan_text = ""
            production_detail = ProductionDetail.where(["model_id = ? and plan_start_ymd <= ? and ? <= plan_end_ymd", model_id, current_date, current_date]).first
            
            if production_detail
              plan_text = I18n.t(:notice_plan_done)
            elsif Calendar.holiday?(current_date)
              plan_text = I18n.t(:notice_plan_holiday)
            end
            plan[:plan] = plan_text
            
            @plans << plan
            current_date = current_date.tomorrow
          }
        }
      end
    end
    
    render :layout => "popup"
  end

  private

  def notice_success
    return @production.disp_text
  end

  # 状態のプルダウンを生成
  def create_status_options
    @statuses = Status.all.order(:id).to_a
    @items = Item.all.order(:id).to_a
    @process_types = ProcessType.where(["search_flag IS NOT NULL"]).order(:seq).to_a

    @statuses.insert 0, Status.new(name: t(:notice_select_all))
    @items.insert 0, Item.new(name: t(:notice_select_all))
    @process_types.insert 0, ProcessType.new(name: t(:notice_select_all))
  end

  #工程と機種のプルダウンを生成
  def create_plans_select_options
    @process_category_options = []
    @process_category_options << [t(:notice_select), nil]
    @process_category_options << [t(:options_hd), PROCESS_CATEGORY_HD]
    @process_category_options << [t(:options_ro), PROCESS_CATEGORY_RO]

    result = {}
    {
       PROCESS_CATEGORY_RO => [PLAN_PROCESS_FLAG_RO1, PLAN_PROCESS_FLAG_RO1_ADDITION, PLAN_PROCESS_FLAG_RO2, PLAN_PROCESS_FLAG_RO2_ADDITION],
       PROCESS_CATEGORY_HD => [PLAN_PROCESS_FLAG_HD, PLAN_PROCESS_FLAG_HD_ADDITION],
    }.each do |key, process_flags|
      result[key] = Model.includes([:process_types]).where(["process_types.plan_process_flag in (?)", process_flags]).order("models.name asc, models.code asc").references(:process_types).map {|model| [model.disp_text, model.id]}
    end
    @standard_material_json = result.to_json

    @model_id_options = create_model_list_by_category

    @model_id_options << [t(:notice_select), nil] if @model_id_options.empty?
  end

  def create_model_list_by_category
    cond_process_category = nil
    cond_process_category = params[:cond_process_category].to_i if params[:cond_process_category]

    process_flags = case cond_process_category
    when PROCESS_CATEGORY_RO
       [PLAN_PROCESS_FLAG_RO1, PLAN_PROCESS_FLAG_RO1_ADDITION, PLAN_PROCESS_FLAG_RO2, PLAN_PROCESS_FLAG_RO2_ADDITION]
    when PROCESS_CATEGORY_HD
       [PLAN_PROCESS_FLAG_HD, PLAN_PROCESS_FLAG_HD_ADDITION]
    end

    models = Model.includes([:process_types]).where(["process_types.plan_process_flag in (?)", process_flags]).order("models.name asc, models.code asc").references(:process_types)

    return models.map {|model| [model.disp_text, model.id]}
  end

  def sum_result_amount
    unless @production_details.empty?
      order = nil
      prev_order_id = nil
      @production_details.each {|production_detail|
        if prev_order_id != production_detail.production.order_id
        order = production_detail.production.order
        order.sum_result_amount = 0
        end

        order.sum_result_amount += production_detail.result_amount_production.to_i
        prev_order_id = order.id
      }
    end
  end

  def notice_force_submit
    flash[:alert] = t(:confirm_force_submit, :act => t(:summate_month, :scope =>  [:actions])) unless @production.summation_id.nil?
  end
  
  private
    def set_production
      @production = Production.find(params[:id])
    end

    def production_params
      params.require(:production).permit(:status_id, { :production_details_attributes => [ :id, :model_id, :plan_start_ymd, :plan_end_ymd, :result_start_ymd, :result_end_ymd, :result_amount_production, :defectiveness_amount, :lock_version ] }, { :lot_attributes => [ :id, :weight, :lock_version, :case ] })
    end

    def production_detail_params
      params.permit(:production_detail => [:id, :select_print])[:production_detail].to_h
    end
end
