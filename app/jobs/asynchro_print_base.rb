class AsynchroPrintBase < AsynchroBase
  NONE_VAL = DISP_NONE

  def self.get_report_type_id
    raise "need overwride!!"
  end

  def self.create_pdf(report, user, *targets)
    raise "need overwride!!"
  end

  def self.disorganize_report(report, user, *targets)
    raise "need overwride!!"
  end

  #=============================================================================
  def self.get_tlf_path(tlf_name)
    return File.join(Rails.root, REPORT_TEMPLATE_DIR, tlf_name + ".tlf")
  end
  
  def self.company
    return Company.first
  end
  
  def self.put_data(page, name, val)
    page.item(name).value(val)
    return
  end
  
  def self.put_data_cnt(page, name, cnt, val)
    self.put_data(page, name.to_s + cnt.to_s, val)
    return 
  end
  
  def self.put_report_title(page, obj)
    self.put_data(page, (obj.to_s + "_title"), self.get_label(obj, "title"))
    return
  end
  
  #2012.10.25 N.Hanamura Add タイトル（控）用
  def self.put_report_title1(page, obj)
    self.put_data(page, (obj.to_s + "_title1"), self.get_label(obj, "title1"))
    return
  end
  
  def self.put_title(page, obj, method)
    self.put_data(page, method, self.get_label(obj, method))
    return
  end
  
  def self.get_label(obj, method)
    return I18n.t(method, :scope => [:activerecord, :attributes, obj])
  end

  def self.l(date, options = {})
    I18n.l(date, options)
  end

  def self.float?(val)
    begin
      Float(val)
      return true
    rescue ArgumentError, TypeError
      return false
    end
  end

  def self.tanaka_val(tanaka_flag)
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
    report.report_type = ReportType.find_by_code(get_report_type_id)
    report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_YET)
    report.user = user
    
    self.prepare_report_addition(report, user)
    
    report.save!

    return report
  end
  
  def self.prepare_report_addition(report, user)
    # do nothing
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

      self.disorganize_report(report, user, *targets)

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
