class AsynchroCsvBase < AsynchroPrintBase
  def self.create_pdf(report, user, *targets)
#    raise "need overwride!!"
    # do nothing.
  end

  def self.create_csv(report, user, file_path, *targets)
    raise "need overwride!!"
  end

  def self.report(report, user, *targets)
    begin
      report.asynchro_status = AsynchroStatus.find(ASYNCHRO_STATUS_WAIT)
      report.save!

      report_type = report.report_type

#      csv = self.create_csv(report, user, *targets)

      t = DateTime.now

      file_path = File.join(Rails.root, REPORT_OUTPUT_DIR, t.strftime("%Y%m"))
      Dir.mkdir(file_path) unless File.exist?(file_path)

      file_name = report_type.code + "_" + t.strftime("%Y%m%d%H%M%S") + "_" + user.login_id + ".csv"

      self.create_csv(report, user, File.join(file_path, file_name), *targets)
#      output = csv.generate_file(File.join(file_path, file_name))

      fstat = File.stat(File.join(file_path, file_name))

      report.file_name = file_name
      report.file_path = file_path
      report.size = fstat.size
      report.content_type = "text/csv"
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

  def self.create_disp_name(report, user, datetime, *targets)
    report_type = report.report_type
    
    return report_type.name + "_" + datetime.strftime(report_type.dt_format) + ".csv"
  end

end
