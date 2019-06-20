class ScheduleController < ApplicationController
  def data
    production_details = ProductionDetail.filter_by_productions(nil, nil, nil, nil, nil, nil, nil)
    events = []

    production_details.each {|production_detail|
      start_date = production_detail.plan_start_ymd&.to_formatted_s(:db)
      #start_date += " 10:00" if start_date
      end_date = production_detail.plan_end_ymd&.to_formatted_s(:db)
      #end_date += " 19:00" if end_date
      if start_date and end_date
        events << { "id" => production_detail.id, "text" => "[%s] %s" % [production_detail.current_status_or_process_name, production_detail.production.item.name], "start_date": start_date, "end_date": end_date }
      end
    }
    render :json => events 
  end

  def show
  end
end
