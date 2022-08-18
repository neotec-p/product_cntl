class AsynchroPrintProcessOrder 
  def self.create_pdf(report, user, *targets)
    report_type = report.report_type
    company = Company.first

    additions = []

    t060 = nil
    begin
      page_in_cnt = 0

      targets.sort!{ |a, b|
      (a.trader_id <=> b.trader_id).nonzero? || (a.delivery_ymd <=> b.delivery_ymd)
      }

      t060 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T060 + ".tlf")

      page = nil

      prev_trader_id = nil
      targets.each{ |process_order|
        additions << process_order if process_order.instance_of?(AdditionProcessOrder)

        if (prev_trader_id != process_order.trader_id) || (page_in_cnt > 5)
          t060.start_new_page
          page = t060.page

          page_in_cnt = 1

          page.item(:t060_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t060]))
          #2012.10.25 N.Hanamura Add
          page.item(:t060_title1).value(I18n.t("title1", :scope => [:activerecord, :attributes, :t060]))

          page.item(:t_messrs).value(I18n.t(:t_messrs, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_lot_no).value(I18n.t(:t_lot_no, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_item_name).value(I18n.t(:t_item_name, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_material).value(I18n.t(:t_material, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_amount).value(I18n.t(:t_amount, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_unit_price).value(I18n.t(:t_unit_price, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_delivery_ymd).value(I18n.t(:t_delivery_ymd, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_summary).value(I18n.t(:t_summary, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_notice).value(I18n.t(:t_notice, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_shonin).value(I18n.t(:t_shonin, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_tanto).value(I18n.t(:t_tanto, :scope => [:activerecord, :attributes, :t060]))

          #2012.10.25 N.Hanamura Add
          page.item(:t_messrs1).value(I18n.t(:t_messrs1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_lot_no1).value(I18n.t(:t_lot_no1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_item_name1).value(I18n.t(:t_item_name1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_material1).value(I18n.t(:t_material1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_amount1).value(I18n.t(:t_amount1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_unit_price1).value(I18n.t(:t_unit_price1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_delivery_ymd1).value(I18n.t(:t_delivery_ymd1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_summary1).value(I18n.t(:t_summary1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_notice1).value(I18n.t(:t_notice1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_shonin1).value(I18n.t(:t_shonin1, :scope => [:activerecord, :attributes, :t060]))
          page.item(:t_tanto1).value(I18n.t(:t_tanto1, :scope => [:activerecord, :attributes, :t060]))

          page.item(:print_ymd).value(Date.today)
          page.item(:company_name).value(company.name)
          page.item(:company_address).value(company.address)
          page.item(:company_tel).value(I18n.t(:t_tel, :scope => [:activerecord, :attributes, :report_common]) + company.tel)
          page.item(:company_fax).value(I18n.t(:t_fax, :scope => [:activerecord, :attributes, :report_common]) + company.fax)

          page.item(:trader_name).value(process_order.trader.name)

          #2012.10.25 N.Hanamura Add
          page.item(:print_ymd1).value(Date.today)
          page.item(:company_name1).value(company.name)
          page.item(:company_address1).value(company.address)
          page.item(:company_tel1).value(I18n.t(:t_tel, :scope => [:activerecord, :attributes, :report_common]) + company.tel)
          page.item(:company_fax1).value(I18n.t(:t_fax, :scope => [:activerecord, :attributes, :report_common]) + company.fax)

          page.item(:trader_name1).value(process_order.trader.name)

        end

        production = process_order.production
        process_detail = process_order.process_detail
        lot = process_order.lot
        item = process_order.item

        page.item("lot_no#".to_s + (page_in_cnt).to_s).value(lot.lot_no)
        #2012.10.25 N.Hanamura Add 
        page.item("lot_no#".to_s + (page_in_cnt+5).to_s).value(lot.lot_no)

        page.item("tanaka_val#".to_s + (page_in_cnt).to_s).value(___tanaka_val(process_detail.tanaka_flag))
        #2012.10.25 N.Hanamura Add 
        page.item("tanaka_val#".to_s + (page_in_cnt+5).to_s).value(___tanaka_val(process_detail.tanaka_flag))

        page.item("item_drawing_no#".to_s + (page_in_cnt).to_s).value(item.drawing_no)
        #2012.10.25 N.Hanamura Add 
        page.item("item_drawing_no#".to_s + (page_in_cnt+5).to_s).value(item.drawing_no)

        page.item("item_name#".to_s + (page_in_cnt).to_s).value(item.name)
        #2012.10.25 N.Hanamura Add 
        page.item("item_name#".to_s + (page_in_cnt+5).to_s).value(item.name)

        page.item("material#".to_s + (page_in_cnt).to_s).value(process_order.material)
        #2012.10.25 N.Hanamura Add 
        page.item("material#".to_s + (page_in_cnt+5).to_s).value(process_order.material)

        page.item("process#".to_s + (page_in_cnt).to_s).value(process_order.process)
        #2012.10.25 N.Hanamura Add 
        page.item("process#".to_s + (page_in_cnt+5).to_s).value(process_order.process)

        page.item("production_result_amount#".to_s + (page_in_cnt).to_s).value(production.result_amount)
        #2012.10.25 N.Hanamura Add 
        page.item("production_result_amount#".to_s + (page_in_cnt+5).to_s).value(production.result_amount)

        page.item("lot_weight#".to_s + (page_in_cnt).to_s).value(lot.weight)
        #2012.10.25 N.Hanamura Add 
        page.item("lot_weight#".to_s + (page_in_cnt+5).to_s).value(lot.weight)

        lot_case = "(" + lot.case.to_s + I18n.t(:t_unit_case, :scope => [:activerecord, :attributes, :report_common]) + ")"
        page.item("lot_case#".to_s + (page_in_cnt).to_s).value(lot_case)
        #2012.10.25 N.Hanamura Add 
        page.item("lot_case#".to_s + (page_in_cnt+5).to_s).value(lot_case)

        page.item("unit_price#".to_s + (page_in_cnt).to_s).value(process_order.price)
        #2012.10.25 N.Hanamura Add 
        page.item("unit_price#".to_s + (page_in_cnt+5).to_s).value(process_order.price)

        page.item("delivery_ymd#".to_s + (page_in_cnt).to_s).value(I18n.l(process_order.delivery_ymd, {}))
        #2012.10.25 N.Hanamura Add 
        page.item("delivery_ymd#".to_s + (page_in_cnt+5).to_s).value(I18n.l(process_order.delivery_ymd, {}))

        page.item("delivery_ymd_add#".to_s + (page_in_cnt).to_s).value(process_order.delivery_ymd_add)
        #2012.10.25 N.Hanamura Add 
        page.item("delivery_ymd_add#".to_s + (page_in_cnt+5).to_s).value(process_order.delivery_ymd_add)

        page.item("summary1#".to_s + (page_in_cnt).to_s).value(process_order.summary1)
        #2012.10.25 N.Hanamura Add 
        page.item("summary1#".to_s + (page_in_cnt+5).to_s).value(process_order.summary1)

        page.item("summary2#".to_s + (page_in_cnt).to_s).value(process_order.summary2)
        #2012.10.25 N.Hanamura Add 
        page.item("summary2#".to_s + (page_in_cnt+5).to_s).value(process_order.summary2)

        page.item("t_unit_weight#".to_s + (page_in_cnt).to_s).value(I18n.t(:t_unit_weight, :scope => [:activerecord, :attributes, :report_common]))
        #2012.10.25 N.Hanamura Add 
        page.item("t_unit_weight#".to_s + (page_in_cnt+5).to_s).value(I18n.t(:t_unit_weight, :scope => [:activerecord, :attributes, :report_common]))

        page.item("t_unit_amount#".to_s + (page_in_cnt).to_s).value(I18n.t(:t_unit_amount, :scope => [:activerecord, :attributes, :report_common]))
        #2012.10.25 N.Hanamura Add 
        page.item("t_unit_amount#".to_s + (page_in_cnt+5).to_s).value(I18n.t(:t_unit_amount, :scope => [:activerecord, :attributes, :report_common]))

        page_in_cnt += 1
        prev_trader_id = process_order.trader_id
      }

    self.output_t070(t060, *additions)
    end

    return t060
  end

  private

  def self.output_t070(t060, *additions)
    is_first = true
    page_in_cnt = 0
    page = nil
    company = Company.first

    additions.each{ |addition|
      if (is_first || page_in_cnt > 4)
        is_first = false
        page_in_cnt = 1

        t060.start_new_page :layout => File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T070 + ".tlf")
        page = t060.page

        page.item(:t070_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t070]))
        page.item(:t_month).value(I18n.t(:t_month, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_day).value(I18n.t(:t_day, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_model).value(I18n.t(:t_model, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_item_name).value(I18n.t(:t_item_name, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_item_drawing_no).value(I18n.t(:t_item_drawing_no, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_vote_no).value(I18n.t(:t_vote_no, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_item_code).value(I18n.t(:t_item_code, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_order_no).value(I18n.t(:t_order_no, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_lot_no).value(I18n.t(:t_lot_no, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_quantity).value(I18n.t(:t_quantity, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_unit_quantity).value(I18n.t(:t_unit_quantity, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_unit_weight).value(I18n.t(:t_unit_weight, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_unit_case).value(I18n.t(:t_unit_case, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_material).value(I18n.t(:t_material, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_process).value(I18n.t(:t_process, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_process_date).value(I18n.t(:t_process_date, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_send_date).value(I18n.t(:t_send_date, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_note).value(I18n.t(:t_note, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_test_report).value(I18n.t(:t_test_report, :scope => [:activerecord, :attributes, :report_common]))

        page.item(:print_ymd).value(I18n.l(Date.today, :format => :local_short))
        
        page.item(:company_short_name).value(company.short_name)
      end

      production = addition.production
      order = production.order
      item = production.item
      material = production.material
      lot = addition.lot

      page.item("addition_processor#".to_s + (page_in_cnt).to_s).value(addition.trader.name)
      page.item("item_name#".to_s + (page_in_cnt).to_s).value(item.name)
      page.item("item_drawing_no#".to_s + (page_in_cnt).to_s).value(item.drawing_no)

      page.item("vote_no#".to_s + (page_in_cnt).to_s).value(production.disp_text)
      page.item("item_code#".to_s + (page_in_cnt).to_s).value(item.disp_text)
      
      page.item("order_no#".to_s + (page_in_cnt).to_s).value(order.order_no)
      page.item("lot_no#".to_s + (page_in_cnt).to_s).value(lot.lot_no)

      page.item("quantity#".to_s + (page_in_cnt).to_s).value(production.result_amount)
      page.item("weight#".to_s + (page_in_cnt).to_s).value(lot.weight)
      page.item("case#".to_s + (page_in_cnt).to_s).value(lot.case)
      
      page.item("material#".to_s + (page_in_cnt).to_s).value(item.material.standard)
      page.item("addition_process#".to_s + (page_in_cnt).to_s).value(addition.process)
      
      page.item("delivery_ymd#".to_s + (page_in_cnt).to_s).value(I18n.l(addition.delivery_ymd, :format => :local_short))

      page_in_cnt += 1
    }
    
    return
  end

  #### class AsynchroPrintBase < AsynchroBase ####

  #=============================================================================
  
  def self.___tanaka_val(tanaka_flag)
    tanaka_val = nil
    case tanaka_flag
    when TANAKA_FLAG_0SHARP
      tanaka_val = I18n.t(:tanaka_0SHARP, :scope => [:activerecord, :attributes, :process_detail])
    when TANAKA_FLAG_TP
      tanaka_val = I18n.t(:tanaka_TP, :scope => [:activerecord, :attributes, :process_detail])
    else
    #do nothing
    end
  end
  
  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T060)
    report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_YET)
    report.user = user
    
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

      targets.each{ |process_order|
        process_order.reports << report
        process_order.print_flag = FLAG_ON
        process_order.save!
      }

      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_DONE)
      report.save!

    rescue => e
      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_ERROR)
      report.save!

      raise e
    end
  end

  def self.create_print_message_print_all(targets)
    ReportType.report_name(REPORT_TYPE_T060) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + datetime.strftime(report_type.dt_format) + ".pdf"
  end

end
