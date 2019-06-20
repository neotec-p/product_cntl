class SummationsController < ApplicationController
  # GET /customers
  def index
    get_all
    set_target_month
  end

  # 月締め
  def summate_month
    @summation = Summation.new
    unless valid_production? && valid_material_stock? && valid_washer_stock?
      return redirect_to(summations_path, flash: { alert: @summation.errors.full_messages })
    end

    summate_month_core true
  end

  # 月次集計帳票の出力
  def summate_month_report
    # 帳票出力のみ
    summate_month_core false
  end

  private

  def get_all
    summations = Summation.all.order("id desc")

    session_set_prm

    @summations = summations.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  def set_target_month
    @target_ymd_month = Summation.get_current_month
  end
  
  def summate_month_core(finish_flag = false)
    set_target_month
    summation = Summation.new

    ActiveRecord::Base::transaction do
      summation.summation_type = SummationType.find(finish_flag ? SUMMATION_TYPE_MONTH : SUMMATION_TYPE_MONTH_REPORT)
      summation.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_YET)
      summation.user = @app.user
      summation.target_ymd = @target_ymd_month
      summation.save!

      file_name = params[:file_name] if params[:file_name]

      AsynchroSummate.delay.summate_month(@app.user, summation, finish_flag, file_name)
    end

    redirect_to :action => :index, flash: { notice: t(:success_summate, :msg => summation.summation_type.name) }
  end
  
  private
  
  def valid_production?
    errors_not_rel_lots = []
    errors_not_rel_material_stocks = []
    errors_not_rel_washer_stocks = []
    errors_multi_details = []
    
    result = true
    
    target_productions = Production.find_summation_targets(true)
    
    target_productions.each{ |production|
      disp_text = production.disp_text
      
      #-- 支給品以外で材料在庫・座金在庫と紐づいていないとNG --
      # 材料在庫と紐づいてない
      material = production.material
      if (material && material.provide_flag == FLAG_OFF)
        if production.material_stock.nil?
          errors_not_rel_material_stocks << disp_text
        end
      end
      
      # 座金在庫と紐づいていない
      # 正常データだけが対象（不良は除外）
      # ヘッダー工程で不良になることも考慮する
      if production.status.id == STATUS_ID_NORMAL
        # 座金１
        washer1 = production.washer1
        # 座金２
        washer2 = production.washer2
        if (washer1 && washer1.provide_flag == FLAG_OFF && production.washer_stocks1.empty?) ||
           (washer2 && washer2.provide_flag == FLAG_OFF && production.washer_stocks2.empty?)
          errors_not_rel_washer_stocks << disp_text
        end
      end
      
      #-- ロットと紐づいていないとNG --
      if !production.lot
        errors_not_rel_lots << disp_text
      else
        #-- ロットと紐づいていて、倉入れ以外の工程が生きていればNG
        # 正常データだけが対象（不良は除外）
        if production.status.id == STATUS_ID_NORMAL
          cnt = production.production_details.includes(:process_detail => :process_type).where(["(process_types.protected_flag IS NULL || process_types.protected_flag != ?) AND result_amount_production IS NOT NULL", PROTECTED_FLAG_FINISH]).references(:process_details, :process_types).count
          errors_multi_details << disp_text if cnt > 0
        end
      end
    }

    unless errors_not_rel_material_stocks.empty?
      target_type = t(:material, :scope => [:activerecord, :attributes, :commons])
      @summation.errors[:base] << t(:error_summation_valid_productions_not_rel_stocks, :material_type => target_type, :targets => errors_not_rel_material_stocks.join(", "))
      result = false
    end
    unless errors_not_rel_washer_stocks.empty?
      target_type = t(:washer, :scope => [:activerecord, :attributes, :commons])
      @summation.errors[:base] << t(:error_summation_valid_productions_not_rel_stocks, :material_type => target_type, :targets => errors_not_rel_washer_stocks.join(", "))
      result = false
    end
    unless errors_not_rel_lots.empty?
      @summation.errors[:base] << t(:error_summation_valid_productions_not_rel_lots, :targets => errors_not_rel_lots.join(", "))
      result = false
    end
    unless errors_multi_details.empty?
      @summation.errors[:base] << t(:error_summation_valid_productions_multi_details, :targets => errors_multi_details.join(", "))
      result = false
    end
    
    return result
  end

  def valid_material_stock?
    error_targets = []
    
    target_material_orders = MaterialOrder.joins(:material_stocks).where(delivery_flag: FLAG_OFF).group(:id)
    target_material_orders.each {|material_order|
      error_targets << material_order.id
    }

    unless error_targets.empty?
      target_type = t(:material, :scope => [:activerecord, :attributes, :commons])
      @summation.errors[:base] << t(:error_summation_valid_material_orders, :material_type => target_type,:targets => error_targets.join(", "))
      return false
    end
    
    true
  end

  def valid_washer_stock?
    error_targets = []
    
    target_washer_orders = WasherOrder.joins(:washer_stocks).where(delivery_flag: FLAG_OFF).group(:id)
    target_washer_orders.each {|washer_order|
      error_targets << washer_order.id
    }

    unless error_targets.empty?
      target_type = t(:washer, :scope => [:activerecord, :attributes, :commons])
      @summation.errors[:base] << t(:error_summation_valid_material_orders, :material_type => target_type,:targets => error_targets.join(", "))
      return false
    end
    
    true
  end

end
