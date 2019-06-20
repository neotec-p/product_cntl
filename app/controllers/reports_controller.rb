class ReportsController < ApplicationController
  def index
    cond_report_type_id = nil
    cond_report_type_id = params[:cond_report_type_id].to_i unless params[:cond_report_type_id].blank?
    cond_user_last_name = ''
    cond_user_last_name = params[:cond_user_last_name] unless params[:cond_user_last_name].blank?
    cond_user_first_name = ''
    cond_user_first_name = params[:cond_user_first_name] unless params[:cond_user_first_name].blank?

    @search_cond_date_from_to = SearchCondDateFromTo.new
    @search_cond_date_from_to.set_attributes(params)

    reports = Report.available_reports(cond_report_type_id, cond_user_first_name, cond_user_last_name, @search_cond_date_from_to.cond_date_from, @search_cond_date_from_to.cond_date_to).order("reports.id desc")

    session_set_prm

    @reports = reports.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
    
    @report_types = ReportType.all.order(:seq)
  end

  def download
    report = Report.find(params[:id])

    send_file(File.join(report.file_path, report.file_name),
    {:filename => report.disp_name,
             :type => report.content_type,
             :disposition => 'attachment'})
  end

end
