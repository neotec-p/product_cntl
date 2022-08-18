class AsynchroPrintMaterialStockList
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
    material_stocks = targets[0]
    washer_stocks = targets[1]
    
    report_type = report.report_type

    t121 = nil
    begin
      current_material_stocks = []
      current_washer_stocks = []
      
      material_stocks.sort!{ |a, b|
      (a.material.standard <=> b.material.standard).nonzero? || (a.material.diameter <=> b.material.diameter).nonzero? || (a.material.surface.to_s <=> b.material.surface.to_s).nonzero? || (a.id <=> b.id)
      }

      material_total_price = 0
      material_stocks.each{ |material_stock|
        material_stock.calc_amount!
        
        next if material_stock.excess_amount < 0
        current_material_stocks << material_stock

        material_total_price += material_stock.stock_price
      }

      washer_stocks.sort!{ |a, b|
      (a.washer.steel_class <=> b.washer.steel_class).nonzero? || (a.washer.diameter <=> b.washer.diameter).nonzero? || (a.id <=> b.id)
      }

      washer_total_price = 0
      washer_stocks.each{ |washer_stock|
        washer_stock.calc_amount!

        next if washer_stock.excess_amount < 0
        current_washer_stocks << washer_stock

        washer_total_price += washer_stock.stock_price
      }

      total_price = material_total_price + washer_total_price

      #帳票出力
      t121 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T121 + ".tlf")

      t121.start_new_page
      page = t121.page

      page.item(:t121_title).value(I18n.t("title", :scope => [:activerecord, :attributes, :t121]))
      page.item(:t_total_price).value(I18n.t(:t_total_price, :scope => [:activerecord, :attributes, :t121]))

      page.item(:t_creator).value(I18n.t(:t_creator, :scope => [:activerecord, :attributes, :report_common]))
      page.item(:t_approver).value(I18n.t(:t_approver, :scope => [:activerecord, :attributes, :report_common]))
      page.item(:t_material).value(I18n.t(:t_material, :scope => [:activerecord, :attributes, :report_common]))
      page.item(:t_washer).value(I18n.t(:t_washer, :scope => [:activerecord, :attributes, :report_common]))

      page.item(:target_ymd).value(I18n.l(@target_ymd, :format => :year_month))
      page.item(:material_total_price).value(material_total_price)
      page.item(:washer_total_price).value(washer_total_price)
      page.item(:total_price).value(total_price)

      #材料詳細の出力
      self.output_detail(t121, material_total_price, true, current_material_stocks)

      #座金詳細の出力
      self.output_detail(t121, washer_total_price, false, current_washer_stocks)
    end

    return t121
  end

  def self.output_detail(t121, total_price, material_flag, stocks)

    page = nil

    t121.start_new_page layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, (material_flag ? REPORT_TYPE_T121_DETAIL_M : REPORT_TYPE_T121_DETAIL_W) + ".tlf")
    
    page = t121.page

    page.list(:list) do |list|
      # Dispatched at list-footer insertion.
      list.on_footer_insert do |footer|
        footer.item(:t_total_price).value(I18n.t(:t_material_total_price, :scope => [:activerecord, :attributes, :t121]))
        footer.item(:total_price).value(total_price)
      end
    end

    page.list(:list).header do |header|
      header.item(:t_material_name).value(I18n.t(:t_material_name, :scope => [:activerecord, :attributes, :t121]))
      header.item(:t_unit_price).value(I18n.t(:t_unit_price, :scope => [:activerecord, :attributes, :t121]))
      header.item(:t_price).value(I18n.t(:t_price, :scope => [:activerecord, :attributes, :t121]))
      
      header.item(:t_material).value(I18n.t(material_flag ? :t_material : :t_washer, :scope => [:activerecord, :attributes, :report_common]))
      header.item(:t_material_stock_id).value(I18n.t(material_flag ? :t_material_stock_id : :t_washer_stock_id, :scope => [:activerecord, :attributes, :t121]))
      header.item(:t_stock_amount).value(I18n.t(material_flag ? :t_stock_weight : :t_stock_quantity, :scope => [:activerecord, :attributes, :t121]))
    end

    prev_material_id = nil
    sub_total_price = 0
    stocks.each{ |material_stock|
      material = nil
      if material_flag
        material = material_stock.material
      else
        material = material_stock.washer
      end

      material_name = material.disp_text
      unit_price = material.unit_price
      
      if prev_material_id.nil?
        # do nothing
      elsif prev_material_id == material.id
        material_name = DISP_NONE
        unit_price = DISP_NONE
      end

      page.list(:list).add_row do |row|
        row.item(:material_name).value(material_name)
        row.item(:unit_price).value(unit_price)
        row.item(:material_stock_id).value(material_stock.id)
        row.item(:stock_amount).value(material_stock.excess_amount)

        row.item(:stock_price).value(material_stock.stock_price)
      end
      
      prev_material_id = material.id
    }

    return
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    file_name = @file_name unless @file_name.blank?
    file_name ||= @target_ymd.strftime("%Y%m")
    
    return report_type.name + "_" + file_name + ".pdf"
  end

  #### class AsynchroPrintBase < AsynchroBase ####

  #=============================================================================
  
  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T121)
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
    ReportType.report_name(REPORT_TYPE_T121) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

end
