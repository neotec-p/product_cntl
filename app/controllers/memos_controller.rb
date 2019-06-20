class MemosController < ApplicationController
  layout "popup"

  before_action :find_list

  def index
    # do nothing
  end
  
  def new
    @memo = Memo.new
  end
  
  def create
    begin
      @memo = Memo.new(memo_params)
      
      @memo.user = @app.user
      @memo.production = @production
      
      @memo.seq = Memo.where(production_id: @memo.production_id).maximum(:seq).to_i + 1

      if not @memo.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        @memo.save!
      end

      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :new, :production_id => @production.id
      
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  private
  
  def find_list
    @production = Production.find(params[:production_id])
    
    @memos = Memo.where(production_id: @production.id).order("seq asc")
  end
  
  def notice_success
    return @memo.seq
  end
  
    def memo_params
      params.require(:memo).permit(:contents, :lock_version)
    end
end
