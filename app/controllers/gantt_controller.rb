class GanttController < ApplicationController
  def data
    tasks = [
      { "id" => 1, "text" => "Project #2", "start_date": "2018-10-25", "duration": 18, "progress": 0.4, "open": true },
      { "id" => 2, "text" => "Task #1", "start_date": "2018-10-26", "duration": 8, "progress": 0.6, "parent": "1" },
      { "id" => 3, "text" => "Task #2", "start_date": "2018-10-30", "duration": 8, "progress": 0.6, "parent": "1" }
    ]
    links = [
      { "id" => 1, "source" => 1, "target" => 2, "type" => "1" },
      { "id" => 2, "source" => 2, "target" => 3, "type" => "0" },
      { "id" => 3, "source" => 3, "target" => 4, "type" => "0" },
      { "id" => 4, "source" => 2, "target" => 5, "type" => "2" }
    ]
    render :json => { data: tasks, links: links }
  end

  def show
  end
end
