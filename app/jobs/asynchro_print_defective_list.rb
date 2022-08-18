class AsynchroPrintDefectiveList
  def self.create_print_message_print_all(targets)
    ReportType.report_name(REPORT_TYPE_T080) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

  def self.prepare_report_with_term(user, from, to)
    @from = from
    @to = to
  
    self.prepare_report(user)
  end
  
  def self.prepare_report_addition(report, user)
    report.note = I18n.l(@from, {}) + I18n.t(:t_rel, :scope => [:activerecord, :attributes, :report_common]) + I18n.l(@to, {})
  end

  def self.report_with_term(report, user, from, to, *targets)
    @from = from
    @to = to
  
    self.report(report, user, *targets)
  end
  
  def self.create_pdf(report, user, *targets)
    report_type = report.report_type
    company = Company.first

    t080 = nil
    begin
      targets.sort!{ |a, b|
      (a.outbreak_ymd <=> b.outbreak_ymd).nonzero? || (a.id <=> b.id)
      }

      #全体合計金額を先行して算出
      total_expense = 0
      total_material_expense = 0
      targets.each{ |defective|
        defective.calc_amount!

        total_expense += defective.expense
        total_material_expense += defective.material_expense
      }

      #帳票出力
      t080 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T080 + ".tlf")

      t080.list(:list) do |list|
        list.on_footer_insert do |footer|
          footer.item(:t_total_expense).value(I18n.t(:t_total_expense, :scope => [:activerecord, :attributes, :t080]))
          footer.item(:t_expense).value(I18n.t(:t_expense, :scope => [:activerecord, :attributes, :t080]))
          footer.item(:total_expense).value(total_expense)
          footer.item(:t_material_expense).value(I18n.t(:t_material_expense, :scope => [:activerecord, :attributes, :t080]))
          footer.item(:total_material_expense).value(total_material_expense)
        end
      end
      
      #t080.start_new_page
      page = t080.page

      page.list(:list).header do |header|
        header.item("t080_title").value(I18n.t("title", :scope => [:activerecord, :attributes, :t080]))
        
        header.item(:t_outbreak_ymd).value(I18n.t(:t_outbreak_ymd, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_defective_process_type).value(I18n.t(:t_defective_process_type, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_model_code).value(I18n.t(:t_model_code, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_contents).value(I18n.t(:t_contents, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_amount).value(I18n.t(:t_amount, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_weight).value(I18n.t(:t_weight, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_material_stock_id).value(I18n.t(:t_material_stock_id, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_washer_stock_id1).value(I18n.t(:t_washer_stock_id1, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_washer_stock_id2).value(I18n.t(:t_washer_stock_id2, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_process_expense).value(I18n.t(:t_process_expense, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_expense).value(I18n.t(:t_expense, :scope => [:activerecord, :attributes, :t080]))
        header.item(:t_material_expense).value(I18n.t(:t_material_expense, :scope => [:activerecord, :attributes, :t080]))

        header.item(:t_rel).value(I18n.t(:t_rel, :scope => [:activerecord, :attributes, :report_common]))
        header.item(:t_item_code).value(I18n.t(:t_item_code, :scope => [:activerecord, :attributes, :report_common]))
        header.item(:t_drawing_no).value(I18n.t(:t_drawing_no, :scope => [:activerecord, :attributes, :report_common]))

        header.item(:t_material_standard).value(I18n.t(:t_material_standard, :scope => [:activerecord, :attributes, :report_common]))
        header.item(:t_material_diameter).value(I18n.t(:t_material_diameter, :scope => [:activerecord, :attributes, :report_common]))

        header.item(:print_ymd).value(I18n.l(Date.today, {}))
        header.item(:from).value(I18n.l(@from, {}))
        header.item(:to).value(I18n.l(@to, {}))
      end
        
      targets.each{ |defective|

        material_stock = defective.material_stocks.first
        material = material_stock.material
        washer_stock1 = defective.washer_stocks.where("defective_washer_stock_seqs.seq = 1").first
        washer_stock2 = defective.washer_stocks.where("defective_washer_stock_seqs.seq = 2").first
        item = defective.item
        defective_process_type = defective.defective_process_type
        model = defective.model

        page.list(:list).add_row do |row|
          row.item(:outbreak_ymd).value(I18n.l(defective.outbreak_ymd, {}))

          row.item(:defective_process_type).value(defective_process_type.name)
          row.item(:model_code).value(model.code)
          row.item(:contents).value(defective.contents)
          row.item(:amount).value(defective.amount)
          row.item(:weight).value(defective.weight)
          row.item(:material_stock_id).value(material_stock.id)
          row.item(:washer_stock_id1).value(washer_stock1.id) unless washer_stock1.nil?
          row.item(:washer_stock_id2).value(washer_stock2.id) unless washer_stock2.nil?
          row.item(:process_expense).value(defective.process_expense)
          row.item(:expense).value(defective.expense)
          row.item(:material_expense).value(defective.material_expense)
  
          row.item(:item_code).value(item.disp_text)
          row.item(:drawing_no).value(item.drawing_no)
  
          row.item(:material_standard).value(material.standard)
          row.item(:material_diameter).value(material.diameter)
        end
      }
    end

    return t080
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + @from.strftime("%Y%m%d") + "-" + @to.strftime("%Y%m%d") + ".pdf"
  end

  #=============================================================================
  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T080)
    report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_YET)
    report.user = user
    
    self.prepare_report_addition(report, user)
    
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


end
