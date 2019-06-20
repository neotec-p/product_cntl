class AsynchroPrintProductionPlanList

  def self.prepare_report_with_process_category(user, process_category)
    @process_category = process_category

    return self.prepare_report(user)
  end
  
  def self.report_with_process_category(report, user, process_category, *targets)
    @process_category = process_category

    self.report(report, user, *targets)
  end
  
  def self.hd?
    return @process_category == PROCESS_CATEGORY_HD
  end

#===============================================================================

  def self.get_report_type_id
    return hd? ? REPORT_TYPE_T040 : REPORT_TYPE_T041
  end

  def self.get_template_id
    return REPORT_TYPE_T040
  end

  def self.create_pdf(report, user, *targets)
    report_type = report.report_type
    company = Company.first

    t040 = nil
    begin

      target_date = targets[0]
      today = Date.today
      
      #帳票出力
      t040 = Thinreports::Report.new layout: File.join(Rails.root, REPORT_TEMPLATE_DIR, get_template_id + ".tlf")

      #calendars_div1 = [] #1～16日まで
      #calendars_div2 = [] #17～31日まで

      calendars = Calendar.where(["year = ? and month = ?", target_date.year, target_date.month]).order(
        ["year, month, day"]
      )

      #31.times{ |i|
      #  calendar = calendars[i]
      #  break if calendar.nil?
      #  
      #  if i < 16
      #    calendars_div1 << calendar
      #  else
      #    calendars_div2 << calendar
      #  end
      #}
      
      self.print_detail(t040, calendars[0..15], target_date, today)
      self.print_detail(t040, calendars[16..-1], target_date, today)
    end

    return t040
  end

  private

  def self.get_target_plan_process_flag
    return hd? ? ProcessType.plan_process_flags_hd : ProcessType.plan_process_flags_ro
  end

  def self.print_detail(t040, calendars, target_date, today)
      t040.start_new_page
      page = t040.page

      page.list(:list).header do |header|
        header.item(:t040_title).value(I18n.t(:title, :scope => [:activerecord, :attributes, (hd? ? :t040 : :t041)]))

        header.item(:target_ymd).value(I18n.l(target_date, :format => "%Y/%m"))
        header.item(:print_ymd).value(I18n.l(today, {}))
        
        calendars.each_with_index{ |calendar, i|
          next if calendar.nil?
          
          date = calendar.conv_date
          
          header.item("day#" + (i+1).to_s).value(I18n.l(date, :format => "%m/%d"))
          day_of_week = I18n.l(date, :format => "%a")
          day_of_week += (" - " + I18n.t(:t_holiday, :scope => [:activerecord, :attributes, :t040])) if calendar.holiday?
          
          header.item("day_of_week#" + (i+1).to_s).value(day_of_week)
        }
      end

      models = Model.includes(:process_types).where(
        process_types: { plan_process_flag: self.get_target_plan_process_flag}).order( #ProcessType.plan_process_flags_hd],
        "models.code"
      )
      
      models.each_with_index{ |model, i|
        
        page.list(:list).add_row do |row|
          row.item(:t_plan_top).value(I18n.t(:t_plan_top, :scope => [:activerecord, :attributes, :t040]))
          row.item(:t_item_code_top).value(I18n.t(:t_item_code, :scope => [:activerecord, :attributes, :report_common]))
          row.item(:t_item_drawing_no_top).value(I18n.t(:t_item_drawing_no, :scope => [:activerecord, :attributes, :report_common]))
          row.item(:t_item_name_top).value(I18n.t(:t_item_name, :scope => [:activerecord, :attributes, :report_common]))
          row.item(:t_material_standard_top).value(I18n.t(:t_material_standard_top, :scope => [:activerecord, :attributes, :t040]))
          row.item(:t_amount_top).value(I18n.t(:t_amount_top, :scope => [:activerecord, :attributes, :t040]))
#          row.item(:t_price_top).value(I18n.t(:t_price_top, :scope => [:activerecord, :attributes, :t040]))

          row.item(:model_code_top).value(model.code)
          row.item(:model_name_top).value(model.name)

          plan_top = Array.new(calendars.length)
          plan_bottom = Array.new(calendars.length)
          
          calendars.each_with_index{ |calendar, j|
            date = calendar.conv_date
            
            conds  = " production_details.model_id = ?"
            conds += " and production_details.plan_start_ymd <= ?"
            conds += " and ? <= production_details.plan_end_ymd"
            conds += " and productions.summation_id IS NULL"
            
            params = []
            params << model.id
            params << date
            params << date

            production_details = ProductionDetail.includes([:production => :order]).where([conds] + params).order(
              "orders.delivery_ymd asc, productions.vote_no asc, production_details.id asc").limit(2)
            
            pd_1 = production_details[0]
            pd_2 = production_details[1]

            unless pd_1.nil?
              if ((!plan_top[j].nil? and plan_top[j][:production_detail].id == pd_1.id) || (!plan_bottom[j].nil? and plan_bottom[j][:production_detail].id == pd_1.id))
                pd_1 = nil 
              end
            end

            unless pd_2.nil?
              if ((!plan_top[j].nil? and plan_top[j][:production_detail].id == pd_2.id) || (!plan_bottom[j].nil? and plan_bottom[j][:production_detail].id == pd_2.id))
                pd_2 = nil
              end
            end

            if plan_top[j].nil?
              production_detail = pd_1
              production_detail ||= pd_2

              unless production_detail.nil?
                plan_top[j] = self.set_plan_detail_start(production_detail)
                if production_detail.plan_end_ymd > date
                  cnt = j + 1
                  while (!calendars[cnt].nil? && production_detail.plan_end_ymd >= calendars[cnt].conv_date)
                    plan_top[cnt] = self.set_plan_detail_other(production_detail, production_detail.plan_end_ymd == calendars[cnt].conv_date)
                    cnt += 1
                  end
                end
              end
              
              #出力済みのはずなので、初期化
              pd_1 = nil
            end
              
            if plan_bottom[j].nil?
              production_detail = pd_1
              production_detail ||= pd_2

              unless production_detail.nil?
                plan_bottom[j] = self.set_plan_detail_start(production_detail)
                if production_detail.plan_end_ymd > date
                  cnt = j + 1
                  while (!calendars[cnt].nil? && production_detail.plan_end_ymd >= calendars[cnt].conv_date)
                    plan_bottom[cnt] = self.set_plan_detail_other(production_detail, production_detail.plan_end_ymd == calendars[cnt].conv_date)
                    cnt += 1
                  end
                end
                
                production_detail = nil
              end
            end

            unless plan_top[j].nil?
              row.item("item_code_top#" + (j+1).to_s).value(plan_top[j][:item_code])
              row.item("item_drawing_no_top#" + (j+1).to_s).value(plan_top[j][:item_drawing_no])
              row.item("item_name_top#" + (j+1).to_s).value(plan_top[j][:item_name])
              row.item("material_standard_top#" + (j+1).to_s).value(plan_top[j][:material_standard])
              row.item("amount_top#" + (j+1).to_s).value(plan_top[j][:amount])
#              row.item("price_top#" + (j+1).to_s).value(plan_top[j][:price])
            end

            unless plan_bottom[j].nil?
              row.item("item_code_bottom#" + (j+1).to_s).value(plan_bottom[j][:item_code])
              row.item("item_drawing_no_bottom#" + (j+1).to_s).value(plan_bottom[j][:item_drawing_no])
              row.item("item_name_bottom#" + (j+1).to_s).value(plan_bottom[j][:item_name])
              row.item("material_standard_bottom#" + (j+1).to_s).value(plan_bottom[j][:material_standard])
              row.item("amount_bottom#" + (j+1).to_s).value(plan_bottom[j][:amount])
#              row.item("price_bottom#" + (j+1).to_s).value(plan_bottom[j][:price])
            end
          }
        end
      }

      return t040
  end

  def self.set_plan_detail_start(production_detail)
    production = production_detail.production
    item = production.item
    material = production.materials.first
    order = production.order
    
    {
      :production_detail => production_detail,
      :item_code => item.disp_text,
      :item_drawing_no => item.drawing_no,
      :item_name => item.name,
      :material_standard => material.standard,
      :amount => order.necessary_amount,
      :price => order.necessary_amount.to_i * production_detail.process_expense
    }
  end
  
  def self.set_plan_detail_other(production_detail, end_flag)
    {
      :production_detail => production_detail,
      :item_code => (end_flag ? "=>|" : "=>"),
      :item_drawing_no => "",
      :item_name => "",
      :material_standard => "",
      :amount => nil,
      :price => nil
    }
  end

  #### class AsynchroPrintBase < AsynchroBase ####

  #=============================================================================
  
  def self.prepare_report(user)
    report = Report.new
    report.report_type = ReportType.find_by_code(get_report_type_id)
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

      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_DONE)
      report.save!

    rescue => e
      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_ERROR)
      report.save!

      raise e
    end
  end

  def self.create_print_message_print_all(targets)
    ReportType.report_name(get_report_type_id) + " " + (targets.size.to_s  + I18n.t(:cases_unit))
  end

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + datetime.strftime(report_type.dt_format) + ".pdf"
  end

end
