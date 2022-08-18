include ActionView::Helpers::NumberHelper

class AsynchroPrintProduction
  def self.create_pdf(report, user, *targets)
    report_type = report.report_type
    company = Company.first

    t010 = nil
    begin
      t010 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T010 + ".tlf")

      targets.each{ |production|
        t010.start_new_page
        page = t010.page

        order = production.order
        item = production.item
        customer = item.customer
        material = production.material

        page.item(:print_ymd).value(I18n.l(Date.today, {}))

        page.item(:company_short_name).value(company.short_name)

        page.item(:vote_no).value(production.disp_text)
        page.item(:delivery_ymd).value(I18n.l(production.order.delivery_ymd, {}))

        page.item(:order_no).value(order.order_no)
        page.item(:item_code).value(item.disp_text)
        page.item(:item_name).value(item.name)
        page.item(:item_drawing_no).value(item.drawing_no)
        page.item(:material).value(material.disp_text_with_pai)
        page.item(:customer_code).value(customer.code)

        page.item(:order_necessary_amount).value(order.necessary_amount)
        page.item(:item_vote_note).value(item.vote_note)

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
        page.item(:t_creator).value(I18n.t(:t_creator, :scope => [:activerecord, :attributes, :report_common]))
        page.item(:t_approver).value(I18n.t(:t_approver, :scope => [:activerecord, :attributes, :report_common]))

        page.item(:t_customer_code).value(I18n.t(:t_customer_code, :scope => [:activerecord, :attributes, :report_common]))

        page.item(:t010_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_delivery_ymd).value(I18n.t(:t_delivery_ymd, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_barrel).value(I18n.t(:t_barrel, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_lot_amount).value(I18n.t(:t_lot_amount, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_order_necessary_amount).value(I18n.t(:t_order_necessary_amount, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_heat_process).value(I18n.t(:t_heat_process, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_surface_process).value(I18n.t(:t_surface_process, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_print_out).value(I18n.t(:t_print_out, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_case).value(I18n.t(:t_case, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_material_stock).value(I18n.t(:t_material_stock, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_material_lot).value(I18n.t(:t_material_lot, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_defectiveness_amount).value(I18n.t(:t_defectiveness_amount, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_d_no).value(I18n.t(:t_d_no, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_d_process).value(I18n.t(:t_d_process, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_d_processor).value(I18n.t(:t_d_processor, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_d_plan).value(I18n.t(:t_d_plan, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_d_person).value(I18n.t(:t_d_person, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_d_amount).value(I18n.t(:t_d_amount, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_d_weight).value(I18n.t(:t_d_weight, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_note_detail).value(I18n.t(:t_note_detail, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_iso_id).value(I18n.t(:t_iso_id, :scope => [:activerecord, :attributes, :t010]))
        page.item(:t_rel_dept).value(I18n.t(:t_rel_dept, :scope => [:activerecord, :attributes, :t010]))

        page.item(:t030_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t030]))
        page.item(:t031_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t031]))
        page.item(:t_thickness).value(I18n.t(:t_thickness, :scope => [:activerecord, :attributes, :t031]))
        page.item(:t_out_test).value(I18n.t(:t_out_test, :scope => [:activerecord, :attributes, :t031]))
        page.item(:t_test_result).value(I18n.t(:t_test_result, :scope => [:activerecord, :attributes, :t031]))
        page.item(:t_person).value(I18n.t(:t_person, :scope => [:activerecord, :attributes, :t031]))
        page.item(:t_stamp).value(I18n.t(:t_stamp, :scope => [:activerecord, :attributes, :t031]))

        #output_production_details = production.production_details.includes([:process_detail => :process_type]).where(["process_types.protected_flag IS NULL"]).order(:seq)
        output_production_details = production.production_details.includes([:process_detail => :process_type]).where(process_types: { protected_flag: nil }).order("process_types.seq")

        barrel = []

        cnt = 1
        for i in 0...PROCESS_DETAIL_MAX_COUNT
          name = DISP_NONE
          model = DISP_NONE

          if output_production_details.size > i
            production_detail = output_production_details[i]
            process_detail = production_detail.process_detail

            name = process_detail.name
            model = process_detail.model

            case process_detail.process_type.processor_flag
            when PROCESSOR_FLAG_HEAT
              page.item(:heat_process).value(process_detail.name + process_detail.condition)
              page.item(:heat_processor).value(process_detail.model)
            when PROCESSOR_FLAG_SURFACE
              page.item(:surface_process).value(process_detail.name)
              page.item(:thickness).value(process_detail.condition)
              page.item(:surface_processor).value(process_detail.model)
            else
            # do nothing
            end

            tanaka_val = ___tanaka_val(process_detail.tanaka_flag)
            unless tanaka_val.blank?
              page.item(:t_tanaka).value(I18n.t(:t_tanaka, :scope => [:activerecord, :attributes, :t030]))
              page.item(:tanaka_val).value(tanaka_val)
            end

            barrel << name if (process_detail.process_type.barrel_flag == FLAG_ON && !name.blank?)
          end

          page.item("process#".to_s + cnt.to_s).value(name)
          page.item("processor#".to_s + cnt.to_s).value(model)
          page.item("t_plan#".to_s + cnt.to_s).value(I18n.t(:t_plan, :scope => [:activerecord, :attributes, :t010]))

          cnt += 1
        end

        unless barrel.empty?
          page.item(:barrel).value(barrel.join(","))
        end

        self.output_t020(t010, production)
      }
    end

    return t010
  end

  def self.output_t020(t010, production)

    order = production.order
    item = production.item
    customer = item.customer
    company = Company.first

    page = nil

    t010.start_new_page layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T020 + ".tlf")
    page = t010.page

    page.item(:t020_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_vote_no).value(I18n.t(:t_vote_no, :scope => [:activerecord, :attributes, :report_common]))
    page.item(:t_order_no).value(I18n.t(:t_order_no, :scope => [:activerecord, :attributes, :report_common]))
    page.item(:t_item_name).value(I18n.t(:t_item_name, :scope => [:activerecord, :attributes, :report_common]))
    page.item(:t_stamp).value(I18n.t(:t_stamp, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_customer_code).value(I18n.t(:t_customer_code, :scope => [:activerecord, :attributes, :report_common]))
    page.item(:t_item_code).value(I18n.t(:t_item_code, :scope => [:activerecord, :attributes, :report_common]))
    page.item(:t_item_drawing_no).value(I18n.t(:t_item_drawing_no, :scope => [:activerecord, :attributes, :report_common]))
    page.item(:t_machine_no).value(I18n.t(:t_machine_no, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_check).value(I18n.t(:t_check, :scope => [:activerecord, :attributes, :t020]))
    
    page.item(:t_hd).value(I18n.t(:t_hd, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_hd_check).value(I18n.t(:t_hd_check, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_ro).value(I18n.t(:t_ro, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_ro_check).value(I18n.t(:t_ro_check, :scope => [:activerecord, :attributes, :t020]))

    page.item(:t_column).value(I18n.t(:t_column, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_standard).value(I18n.t(:t_standard, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_center).value(I18n.t(:t_center, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_set_up).value(I18n.t(:t_set_up, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_sra).value(I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common]))
    page.item(:t_last_check).value(I18n.t(:t_last_check, :scope => [:activerecord, :attributes, :t020]))

    page.item(:vote_no).value(production.disp_text)
    page.item(:order_no).value(order.order_no)
    page.item(:item_name).value(item.name)

    page.item(:customer_code).value(customer.code)
    page.item(:item_code).value(item.disp_text)
    page.item(:item_drawing_no).value(item.drawing_no)

    hd_models = []
    hd_models << item.hd_model_name1 unless item.hd_model_name1.blank?
    hd_models << item.hd_model_name2 unless item.hd_model_name2.blank?
    hd_models << item.hd_model_name3 unless item.hd_model_name3.blank?
    hd_models << item.hd_addition_model_name unless item.hd_addition_model_name.blank?
    page.item(:hd_model_name).value(hd_models.join("/"))

    ro1_models = []
    ro1_models << item.ro1_model_name1 unless item.ro1_model_name1.blank?
    ro1_models << item.ro1_model_name2 unless item.ro1_model_name2.blank?
    ro1_models << item.ro1_model_name3 unless item.ro1_model_name3.blank?
    ro1_models << item.ro1_addition_model_name unless item.ro1_addition_model_name.blank?
    ro1_models << item.ro2_model_name1 unless item.ro2_model_name1.blank?
    ro1_models << item.ro2_model_name2 unless item.ro2_model_name2.blank?
    ro1_models << item.ro2_model_name3 unless item.ro2_model_name3.blank?
    ro1_models << item.ro2_addition_model_name unless item.ro2_addition_model_name.blank?
    page.item(:ro_model_name).value(ro1_models.join("/"))
    
    hl = item.header_left_check_sheet
    hl ||= HeaderLeftCheckSheet.new
    hr = item.header_right_check_sheet
    hr ||= HeaderRightCheckSheet.new
    rl = item.rolling_left_check_sheet
    rl ||= RollingLeftCheckSheet.new
    rr = item.rolling_right_check_sheet
    rr ||= RollingRightCheckSheet.new

    for cnt in 1..10
      self.set_check_sheet_val(page, "hl_", cnt, hl)
      self.set_check_sheet_val(page, "hr_", cnt, hr)
      self.set_check_sheet_val(page, "rl_", cnt, rl)
      self.set_check_sheet_val(page, "rr_", cnt, rr)
      
      if cnt == 10
        t_hl_col9 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_hr_col1 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_hr_col2 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_hr_col3 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_hr_col4 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_rl_col9 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_rr_col1 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_rr_col2 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_rr_col3 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        t_rr_col4 = I18n.t(:t_sra, :scope => [:activerecord, :attributes, :report_common])
        
        column = "column" + cnt.to_s
        unless hr[column].blank?
          t_hl_col9 = I18n.t(:t_last_check, :scope => [:activerecord, :attributes, :t020])
          t_hr_col1 = I18n.t(:t_column, :scope => [:activerecord, :attributes, :t020])
          t_hr_col2 = I18n.t(:t_standard, :scope => [:activerecord, :attributes, :t020])
          t_hr_col3 = I18n.t(:t_center, :scope => [:activerecord, :attributes, :t020])
          t_hr_col4 = I18n.t(:t_set_up, :scope => [:activerecord, :attributes, :t020])
        end
        unless rr[column].blank?
          t_rl_col9 = I18n.t(:t_last_check, :scope => [:activerecord, :attributes, :t020])
          t_rr_col1 = I18n.t(:t_column, :scope => [:activerecord, :attributes, :t020])
          t_rr_col2 = I18n.t(:t_standard, :scope => [:activerecord, :attributes, :t020])
          t_rr_col3 = I18n.t(:t_center, :scope => [:activerecord, :attributes, :t020])
          t_rr_col4 = I18n.t(:t_set_up, :scope => [:activerecord, :attributes, :t020])
        end
      end
      
      page.item(:t_hl_col9).value(t_hl_col9)
      page.item(:t_hr_col1).value(t_hr_col1)
      page.item(:t_hr_col2).value(t_hr_col2)
      page.item(:t_hr_col3).value(t_hr_col3)
      page.item(:t_hr_col4).value(t_hr_col4)
      page.item(:t_rl_col9).value(t_rl_col9)
      page.item(:t_rr_col1).value(t_rr_col1)
      page.item(:t_rr_col2).value(t_rr_col2)
      page.item(:t_rr_col3).value(t_rr_col3)
      page.item(:t_rr_col4).value(t_rr_col4)
    end
    
    page.item(:t_iso_id).value(I18n.t(:t_iso_id, :scope => [:activerecord, :attributes, :t020]))
    page.item(:t_comment).value(I18n.t(:t_comment, :scope => [:activerecord, :attributes, :t020]))
    page.item(:company_short_name).value(company.short_name)

    return
  end

  def self.set_check_sheet_val(page, type, cnt, check_sheet)
    column = "column" + cnt.to_s
    name = "standard" + cnt.to_s
    item_name = type + name

    page.item(item_name + "_top").value("               |")
    page.item(item_name + "_center").value("               |")
    page.item(item_name + "_bottom").value("               |")

    top_val = check_sheet[name + "_top"]
    top_val = number_with_precision(top_val, :precision => 3) if top_val.is_a? Numeric

    bottom_val = check_sheet[name + "_bottom"]
    bottom_val = number_with_precision(bottom_val, :precision => 3) if bottom_val.is_a? Numeric

    page.item(type + column).value(check_sheet[column])
    
    page.item(item_name + "_top").value(top_val) unless top_val.blank?
    page.item(item_name + "_bottom").value(bottom_val) unless top_val.blank?

    #両方共数値の場合だけ設定する
    return if (top_val.blank? && bottom_val.blank?)
    
    page.item(item_name + "_center").value("")
    
    return unless (top_val.is_a?(Numeric) && bottom_val.is_a?(Numeric))

    #(top + bottom) / 2
    center = ((BigDecimal(top_val) + BigDecimal(bottom_val)) / 2)

    page.item(item_name + "_center").value("     ～      |  " + number_with_precision(center, :precision => 3))
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
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T010)
    report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_YET)
    report.user = user
    
    report.save!

    return report
  end
  
  def self.report(report, user, *targets)
    begin
# masa
# require 'byebug'; byebug
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

      targets.each{ |production|
        production.reports << report
        production.print_flag = FLAG_ON
        production.save!
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
    ReportType.report_name(REPORT_TYPE_T010) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + datetime.strftime(report_type.dt_format) + ".pdf"
  end

end
