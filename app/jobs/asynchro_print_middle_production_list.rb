class AsynchroPrintMiddleProductionList
  def self.prepare_report_with_target_ymd(user, target_ymd, file_name)
    @target_ymd = target_ymd
    @file_name = file_name
  
    self.prepare_report(user)
  end

  def self.report_with_target_ymd(report, user, target_ymd, file_name, *targets)
    @target_ymd = target_ymd
    @file_name = file_name
  
    self.report(report, user, *targets)
  end
  
  def self.create_pdf(report, user, *targets)
    report_type = report.report_type

    t120 = nil
    begin
      targets.sort!{ |a, b|
      (b.process_type.id <=> a.process_type.id).nonzero? || (a.production.item.disp_text <=> b.production.item.disp_text).nonzero? || (a.id <=> b.id)
      }

      production_detail_finishs = []
      production_detail_process_orders = []
      production_detail_rollings = []
      production_detail_headers = []

      total_finish = 0
      total_process_order = 0
      total_rolling = 0
      total_header = 0
      
      targets.each{ |production_detail|
        production = production_detail.production
        process_type = production_detail.process_type
        item = production.item
        
        sum_expense = production_detail.calc_sum_process_expense
        result_amount = production_detail.result_amount_production
        price = sum_expense * result_amount
        
        case process_type.process_category
        when PROCESS_CATEGORY_FINISH #梱包待ち
          total_finish += price
          production_detail_finishs << production_detail
        when PROCESS_CATEGORY_PROCESS_ORDER #外注処理中
          total_process_order += price
          production_detail_process_orders << production_detail
        when PROCESS_CATEGORY_ROLLING #半製品（転造後）
          total_rolling += price
          production_detail_rollings << production_detail
        when PROCESS_CATEGORY_HEADER #半製品（転造前）
          total_header += price
          production_detail_headers << production_detail
        else
          # do nothing
        end
      }

      total_price = total_finish + total_process_order + total_rolling + total_header

      #帳票出力
      t120 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T120 + ".tlf")

      t120.start_new_page
      page = t120.page

      page.item(:t120_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t120]))
      page.item(:t_total_finish).value(I18n.t(:t_total_finish, :scope => [:activerecord, :attributes, :t120]))
      page.item(:t_total_process_order).value(I18n.t(:t_total_process_order, :scope => [:activerecord, :attributes, :t120]))
      page.item(:t_total_rolling).value(I18n.t(:t_total_rolling, :scope => [:activerecord, :attributes, :t120]))
      page.item(:t_total_header).value(I18n.t(:t_total_header, :scope => [:activerecord, :attributes, :t120]))
      page.item(:t_total_price).value(I18n.t(:t_total_price, :scope => [:activerecord, :attributes, :t120]))

      page.item(:t_creator).value(I18n.t(:t_creator, :scope => [:activerecord, :attributes, :report_common]))
      page.item(:t_approver).value(I18n.t(:t_approver, :scope => [:activerecord, :attributes, :report_common]))

      page.item(:target_ymd).value(I18n.l(@target_ymd, :format => :year_month))
      page.item(:total_finish).value(total_finish)
      page.item(:total_process_order).value(total_process_order)
      page.item(:total_rolling).value(total_rolling)
      page.item(:total_header).value(total_header)
      page.item(:total_price).value(total_price)

      #材料詳細の出力
      self.output_detail(t120, total_finish, PROCESS_CATEGORY_FINISH, production_detail_finishs)
      self.output_detail(t120, total_process_order, PROCESS_CATEGORY_PROCESS_ORDER, production_detail_process_orders)
      self.output_detail(t120, total_rolling, PROCESS_CATEGORY_ROLLING, production_detail_rollings)
      self.output_detail(t120, total_header, PROCESS_CATEGORY_HEADER, production_detail_headers)
    end

    return t120
  end

  def self.output_detail(t120, total_price, process_type_flag, targets)
    
    return if targets.length == 0

    page = nil

    t120.start_new_page layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T120_DETAIL + ".tlf")
    page = t120.page

    page.list(:list) do |list|
      # Dispatched at list-footer insertion.
      list.on_footer_insert do |footer|
        footer.item(:t_process_total_price).value(I18n.t(:t_process_total_price, :scope => [:activerecord, :attributes, :t120]))
        footer.item(:total_price).value(total_price)
      end
    end

    page.list(:list).header do |header|
      header.item(:t_item_code).value(I18n.t(:t_item_code, :scope => [:activerecord, :attributes, :report_common]))
      header.item(:t_item_name).value(I18n.t(:t_item_name, :scope => [:activerecord, :attributes, :report_common]))
      header.item(:t_process_name).value(I18n.t(:t_process_name, :scope => [:activerecord, :attributes, :t120]))
      header.item(:t_unit_price).value(I18n.t(:t_unit_price, :scope => [:activerecord, :attributes, :t120]))
      header.item(:t_result_amount_production).value(I18n.t(:t_result_amount_production, :scope => [:activerecord, :attributes, :t120]))
      header.item(:t_price).value(I18n.t(:t_price, :scope => [:activerecord, :attributes, :t120]))
      
      process_type_sym = :t_total_header
      case process_type_flag
      when PROCESS_CATEGORY_FINISH
        process_type_sym = :t_total_finish 
      when PROCESS_CATEGORY_PROCESS_ORDER
        process_type_sym = :t_total_process_order
      when PROCESS_CATEGORY_ROLLING
        process_type_sym = :t_total_rolling
      end
      
      process_type = I18n.t(process_type_sym, :scope => [:activerecord, :attributes, :t120])
      header.item(:t_process_type).value(process_type)
    end

    prev_process_name = nil
    sub_total_price = 0
    targets.each{ |production_detail|
      production = production_detail.production
      process_type = production_detail.process_type
      item = production.item
      
      sum_expense = production_detail.calc_sum_process_expense
      result_amount = production_detail.result_amount_production
      price = sum_expense * result_amount

      process_name = process_type.name
      
      if prev_process_name.nil?
        # do nothing
      elsif prev_process_name == process_name
        process_name = DISP_NONE
      end

      page.list(:list).add_row do |row|
        row.item(:process_name).value(process_name)
        row.item(:item_code).value(item.disp_text)
        row.item(:item_name).value(item.name)
        row.item(:unit_price).value(sum_expense)
        row.item(:result_amount_production).value(result_amount)
        row.item(:price).value(price)
      end
      
      prev_process_name = process_type.name
    }

    return
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    file_name = @file_name unless @file_name.blank?
    file_name ||= @target_ymd.strftime("%Y%m")
    
    return report_type.name + "_" + file_name + ".pdf"
  end

  def self.calc_price(production_detail)
    sum_expense = production_detail.calc_sum_process_expense
    result_amount = production_detail.result_amount_production
    return sum_expense * result_amount
  end

  #### class AsynchroPrintBase < AsynchroBase ####

  #=============================================================================
  
  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T120)
    report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_YET)
    report.user = user
    
    report.note = I18n.l(@target_ymd, :format => :year_month)
    
    report.save!

    return report
  end
  
  def self.report(report, user, *targets)
    begin
      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_WAIT)
      report.save!

      report_type = report.report_type

      pdf = self.create_pdf(report, user, *targets)

      t = DateTime.now

      file_path = File.join(Rails.root, REPORT_OUTPUT_DIR, t.strftime("%Y%m"))
      Dir.mkdir(file_path) unless File.exist?(file_path)

      file_name = report_type.code + "_" + t.strftime("%Y%m%d%H%M%S") + "_" + user.login_id + ".pdf"

      output = pdf.generate filename: File.join(file_path, file_name)
      fstat = File.stat(File.join(file_path, file_name))

      report.file_name = file_name
      report.file_path = file_path
      report.size = fstat.size
      report.content_type = "application/pdf"
      report.disp_name = self.create_disp_name(report, user, t, *targets)
      report.user = user
      report.asynchro_status_id = ASYNCHRO_STATUS_DONE
      report.report_type = report_type

      report.save!

      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_DONE)
      report.save!

    rescue => e
      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_ERROR)
      report.save!

      raise e
    end
  end

  def self.create_print_message_print_all(targets)
    ReportType.report_name(REPORT_TYPE_T120) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

end
