include ActionView::Helpers::NumberHelper

class AsynchroPrintMaterialStock
  def self.create_pdf(report, user, *targets)
    company = Company.first

    t150 = nil
    begin
      is_first = true
      page_in_cnt = 0

      targets.sort!{ |a, b| a.id <=> b.id }

      t150 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T150 + ".tlf")

      page = nil

      prev_trader_id = nil
      targets.each{ |material_stock|
        if (is_first || page_in_cnt > 6)
          is_first = false

          t150.start_new_page
          page = t150.page

          page_in_cnt = 1

          page.item(:company_short_name).value(company.short_name)

          page.item(:t150_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t150]))
          page.item(:t_id).value(I18n.t(:t_id, :scope => [:activerecord, :attributes, :t150]))
          page.item(:t_inspection_no).value(I18n.t(:t_inspection_no, :scope => [:activerecord, :attributes, :t150]))
          page.item(:t_accept_weight).value(I18n.t(:t_accept_weight, :scope => [:activerecord, :attributes, :t150]))
          page.item(:t_accept_ymd).value(I18n.t(:t_accept_ymd, :scope => [:activerecord, :attributes, :t150]))
          page.item(:t_iso_id).value(I18n.t(:t_iso_id, :scope => [:activerecord, :attributes, :t150]))
          
          page.item(:t_unit_weight).value(I18n.t(:t_unit_weight, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_material_standard).value(I18n.t(:t_material_standard, :scope => [:activerecord, :attributes, :report_common]))
          page.item(:t_material_diameter).value(I18n.t(:t_material_diameter, :scope => [:activerecord, :attributes, :report_common]))
        end
        
        material = material_stock.material
        
        page.item("id#".to_s + (page_in_cnt).to_s).value(material_stock.id)
        page.item("standard#".to_s + (page_in_cnt).to_s).value(material.standard)
        page.item("diameter#".to_s + (page_in_cnt).to_s).value(material.diameter)
        page.item("inspection_no#".to_s + (page_in_cnt).to_s).value(material_stock.inspection_no)
        #page.item("accept_weight#".to_s + (page_in_cnt).to_s).value(material_stock.accept_weight)
        page.item("accept_weight#".to_s + (page_in_cnt).to_s).value(number_with_precision(material_stock.accept_weight, :delimiter => ",", :precision => 1))
        page.item("accept_ymd#".to_s + (page_in_cnt).to_s).value(I18n.l(material_stock.accept_ymd, {}))
        
        page_in_cnt += 1
      }

    end

    return t150
  end

  #### class AsynchroPrintBase < AsynchroBase ####

  #=============================================================================
  
  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T150)
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

      targets.each{ |material_stock|
        material_stock.reports << report
        material_stock.collect_flag = FLAG_OFF
        material_stock.print_flag = FLAG_ON
        material_stock.save!
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
    ReportType.report_name(REPORT_TYPE_T150) + " " + (targets.size.to_s + I18n.t(:cases_unit))
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + datetime.strftime(report_type.dt_format) + ".pdf"
  end

end
