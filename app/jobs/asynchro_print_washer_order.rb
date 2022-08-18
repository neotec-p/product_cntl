class AsynchroPrintWasherOrder
  LIST_CNT = 5
  
  def self.create_pdf(report, user, *targets)
    report_type = report.report_type
    company = Company.first

    t050 = nil
    begin
      page_in_cnt = 0

      targets.sort!{ |a, b|
      (a.trader_id <=> b.trader_id).nonzero? || (a.delivery_ymd <=> b.delivery_ymd)
      }

      t050 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T050 + ".tlf")

      page = nil

      prev_trader_id = nil
      targets.each{ |material_order|
        if (prev_trader_id != material_order.trader_id) || (page_in_cnt > LIST_CNT)
          t050.start_new_page
          page = t050.page

          page_in_cnt = 1

          page.item(:print_ymd).value(I18n.l(Date.today, {}))

          page.item(:company_name).value(company.name + "  " + company.product_dept)
          page.item(:company_address).value(company.address)
          page.item(:company_tel).value(company.tel)
          page.item(:company_fax).value(company.fax)

          page.item(:trader_name).value(material_order.trader.name)
          
          page.item(:t050_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_order_date).value(I18n.t(:t_order_date, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_to).value(I18n.t(:t_to, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_from).value(I18n.t(:t_from, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_messrs).value(I18n.t(:t_messrs, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_esq).value(I18n.t(:t_esq, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_comment1).value(I18n.t(:t_comment1, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_reply_delivery_ymd).value(I18n.t(:t_reply_delivery_ymd, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_accept_ymd).value(I18n.t(:t_accept_ymd, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_comment2).value(I18n.t(:t_comment2, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_supplier_stamp).value(I18n.t(:t_supplier_stamp, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_company_stamp).value(I18n.t(:t_company_stamp, :scope => [:activerecord, :attributes, :t050]))
          page.item(:t_stamp).value(I18n.t(:t_stamp, :scope => [:activerecord, :attributes, :t050]))
          
          page.item(:t_creator).value(I18n.t(:t_creator, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_approver).value(I18n.t(:t_approver, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_tel).value(I18n.t(:t_tel, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_fax).value(I18n.t(:t_fax, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_material_title).value(I18n.t(:t_material_title, :scope => [:activerecord, :attributes, :report_common]))
#          page.item(:t_quantity).value(I18n.t(:t_quantity, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_quantity).value(I18n.t(:t_quantity, :scope => [:activerecord, :attributes, :t050]))

          page.item(:t_unit_price).value(I18n.t(:t_unit_price, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_delivery_date).value(I18n.t(:t_delivery_date, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_note).value(I18n.t(:t_note, :scope => [:activerecord, :attributes, :report_common]))
        end
        
        self.set_detail_data(material_order, page, page_in_cnt)
                
        page_in_cnt += 1
        prev_trader_id = material_order.trader_id
      }

    end

    return t050
  end
  
  #座金注文
  def self.set_detail_data(washer_order, page, page_in_cnt)
    washer = washer_order.washer
    
    page.item("order#".to_s + (page_in_cnt).to_s).value(washer.disp_text_with_pai)
    page.item("order_amount#".to_s + (page_in_cnt).to_s).value(washer_order.order_quantity)
    page.item("unit_price#".to_s + (page_in_cnt).to_s).value(washer.unit_price)
    page.item("delivery_ymd#".to_s + (page_in_cnt).to_s).value(I18n.l(washer_order.delivery_ymd, :format => :short))
  end

  #### class AsynchroPrintBase < AsynchroBase ####

  #=============================================================================
  
  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T050)
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

      targets.each{ |material_order|
        material_order.reports << report
        material_order.print_flag = FLAG_ON
        material_order.save!
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
    ReportType.report_name(REPORT_TYPE_T050) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + datetime.strftime(report_type.dt_format) + ".pdf"
  end

end
