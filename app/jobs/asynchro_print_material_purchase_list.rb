class AsynchroPrintMaterialPurchaseList
  def self.prepare_report_with_term(user, from, to)
    @from = from
    @to = to
  
    self.prepare_report(user)
  end
  
  def self.report_with_term(report, user, from, to, *targets)
    @from = from
    @to = to
  
    self.report(report, user, *targets)
  end
  
  def self.create_pdf(report, user, *targets)
    report_type = report.report_type
    company = Company.first

    t140 = nil
    begin
      targets.sort!{ |a, b|
        (a.material_order.trader_id <=> b.material_order.trader_id).nonzero? || (a.accept_ymd <=> b.accept_ymd)
      }
      
      #全体合計金額を先行して算出
      total_price = 0
      targets.each{ |material_stock|
        material_stock.price = material_stock.material_order.purchase_price * material_stock.accept_weight
        total_price += material_stock.price
      }

      #帳票出力
      t140 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, REPORT_TYPE_T140 + ".tlf")

      t140.list(:list) do |list|
        # Dispatched at list-footer insertion.
        list.on_footer_insert do |footer|
          footer.item(:t_total_price).value(I18n.t(:t_total_price, :scope => [:activerecord, :attributes, :t140]))
          footer.item(:total_price).value(total_price)
        end
      end
      
      #t140.start_new_page
      page = t140.page

      page.list(:list).header do |header|
        t_purchase_price = I18n.t(:t_material, :scope => [:activerecord, :attributes, :report_common]) + I18n.t(:t_purchase_price, :scope => [:activerecord, :attributes, :report_common]) + " " + I18n.t(:t_sub_total_price, :scope => [:activerecord, :attributes, :t140])
        header.item(:t_material_purchase_price).value(t_purchase_price)
        header.item(:t_full_delivery_ymd).value(I18n.t(:t_full_delivery_ymd, :scope => [:activerecord, :attributes, :t140]))
        header.item(:t_purchase_price).value(I18n.t(:t_purchase_price, :scope => [:activerecord, :attributes, :t140]))
#        header.item(:t_order_weight).value(I18n.t(:t_order_weight, :scope => [:activerecord, :attributes, :t140]))
        header.item(:t_order_weight).value(I18n.t(:t_order_weight, :scope => [:activerecord, :attributes, :t140]))
        header.item(:t_price).value(I18n.t(:t_price, :scope => [:activerecord, :attributes, :t140]))

        header.item(:t_rel).value(I18n.t(:t_rel, :scope => [:activerecord, :attributes, :report_common]))
        header.item(:t_material).value(I18n.t(:t_material, :scope => [:activerecord, :attributes, :report_common]))
        header.item(:t_trader_name).value(I18n.t(:t_trader_name, :scope => [:activerecord, :attributes, :report_common]))
        header.item(:t_material_standard).value(I18n.t(:t_material_standard, :scope => [:activerecord, :attributes, :report_common]))

        header.item(:t_material_diameter).value(I18n.t(:t_material_diameter, :scope => [:activerecord, :attributes, :report_common]))
        header.item(:t_material_surface).value(I18n.t(:t_material_surface, :scope => [:activerecord, :attributes, :report_common]))

        header.item(:print_ymd).value(I18n.l(Date.today, {}))
        header.item(:from).value(I18n.l(@from, {}))
        header.item(:to).value(I18n.l(@to, {}))
        header.item(:total_price).value(total_price)
      end
        
      prev_trader_id = nil
      sub_total_price = 0
      targets.each{ |material_stock|
        material_order = material_stock.material_order
        material = material_order.material
        trader_name = material_order.trader.name
        
        if prev_trader_id.nil?
          # do nothing
        elsif prev_trader_id != material_order.trader_id
          self.put_sub_total(page, sub_total_price)
          
          sub_total_price = 0
        else 
          trader_name = DISP_NONE
        end

        page.list(:list).add_row do |row|
          row.item(:trader_name).value(trader_name)
          row.item(:full_delivery_ymd).value(I18n.l(material_order.delivery_ymd, {}))
          row.item(:standard).value(material.standard)
          row.item(:diameter).value(material.diameter)
          row.item(:surface).value(material.surface)
          row.item(:purchase_price).value(material_order.purchase_price)
          row.item(:order_weight).value(material_stock.accept_weight)
          row.item(:price).value(material_stock.price)
        end
        
        prev_trader_id = material_order.trader_id
        sub_total_price += material_stock.price
      }

      self.put_sub_total(page, sub_total_price)
    end

    return t140
  end


  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + @from.strftime("%Y%m%d") + "-" + @to.strftime("%Y%m%d") + ".pdf"
  end


  private
  
  def self.put_sub_total(page, sub_total_price)
    page.list(:list).add_row do |row|
      row.item(:order_weight).value(I18n.t(:t_sub_total_price, :scope => [:activerecord, :attributes, :t140]))
      row.item(:price).value(sub_total_price)

      row.item(:trader_name).value(DISP_NONE)
      row.item(:full_delivery_ymd).value(DISP_NONE)
      row.item(:standard).value(DISP_NONE)
      row.item(:diameter).value(DISP_NONE)
      row.item(:surface).value(DISP_NONE)
      row.item(:purchase_price).value(DISP_NONE)
    end
  end

  #### class AsynchroPrintBase < AsynchroBase ####


  #=============================================================================

  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(REPORT_TYPE_T140)
    report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_YET)
    report.user = user
    
    report.note = I18n.l(@from, {}) + I18n.t(:t_rel, :scope => [:activerecord, :attributes, :report_common]) + I18n.l(@to, {})
    
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
    ReportType.report_name(REPORT_TYPE_T140) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

end
