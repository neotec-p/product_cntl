class CalendarsController < ApplicationController
  def index
    @search_cond_date_from_to = SearchCondDateFromTo.new
    @search_cond_date_from_to.set_attributes(params)

    conds = "1 = 1"
    cond_params = []

    unless @search_cond_date_from_to.cond_date_from.nil?
      conds += " and" unless conds.empty?
      conds += " ? <= CONCAT(calendars.year, LPAD(calendars.month, 2, '0'), LPAD(calendars.day, 2, '0'))"
      
      pram  = @search_cond_date_from_to.cond_date_from.year.to_s.rjust(4, "0")
      pram += @search_cond_date_from_to.cond_date_from.month.to_s.rjust(2, "0")
      pram += @search_cond_date_from_to.cond_date_from.day.to_s.rjust(2, "0")
      cond_params << pram
    end
    unless @search_cond_date_from_to.cond_date_to.nil?
      conds += " and" unless conds.empty?
      conds += " CONCAT(calendars.year, LPAD(calendars.month, 2, '0'), LPAD(calendars.day, 2, '0')) <= ?"

      pram  = @search_cond_date_from_to.cond_date_to.year.to_s.rjust(4, "0")
      pram += @search_cond_date_from_to.cond_date_to.month.to_s.rjust(2, "0")
      pram += @search_cond_date_from_to.cond_date_to.day.to_s.rjust(2, "0")
      cond_params << pram
    end

    calendars = Calendar.where([conds] + cond_params).order("year desc, month desc, day desc")

    @calendars = calendars.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
    
    session_set_prm
  end
	
  # 注文CSV登録 get
  def multi_import
    @import_calendars = []
  end

  def multi_import_update
    begin
      upload_file = CalendarUpload.new(params[:file])
      
      @import_calendars = []
      result = upload_file.import(@import_calendars)

      if not result
        return render :action => :multi_import
      end

      cnt = 0
      ActiveRecord::Base::transaction do
        @import_calendars.each {|calendar|
          calendar.save!

          cnt += 1
        }
      end
      
      flash[:notice] = t(:success_imported, :msg => (cnt.to_s + t(:cases_unit)))
      
      redirect_to :action => :multi_import
      
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      logger.error(e.message)
      render :action => :multi_import
    end
  end

end
