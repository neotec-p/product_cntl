class TopController < ApplicationController
  def index
    @notices = Notice.all.order("id desc").limit(10)
  end
end
