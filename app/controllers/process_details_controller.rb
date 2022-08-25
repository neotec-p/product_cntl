class ProcessDetailsController < ApplicationController
  before_action :create_options
  before_action :set_item, only: %i[multi_create multi_update multi_new multi_edit] 

  def multi_new
    processe_types = ProcessType.all.order('seq asc')
    processe_types.each {|process_type|
      @item.process_details.build(process_type: process_type)
    }
  end

  def multi_edit
    @process_details = @item.process_details unless @item.process_details.empty?
  end

  def multi_create
    begin
      save_process_details!
      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :multi_edit, :item_id => @item.id
    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :multi_new
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      logger.error(e.message)
      render :action => :multi_new
    end
  end

  def multi_update
    begin
      save_process_details!
      flash[:notice] = t(:success_updated, :id => notice_success)
      redirect_to :action => :multi_edit, :item_id => @item.id
    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :multi_edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      logger.error(e.message)
      render :action => :multi_edit
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def save_process_details!
    ActiveRecord::Base::transaction do
      @item.update!(item_params)
    end
  end

  def notice_success(options = {})
    return @item.disp_text
  end

  def create_options
    @tanaka_options = []
    
    @tanaka_options << [I18n.t(:tanaka_0SHARP, :scope => [:activerecord, :attributes, :process_detail]), TANAKA_FLAG_0SHARP]
    @tanaka_options << [I18n.t(:tanaka_TP, :scope => [:activerecord, :attributes, :process_detail]), TANAKA_FLAG_TP]
    
    @hexavalent_options = []
    
    @hexavalent_options << [I18n.t(:hexavalent, :scope => [:activerecord, :attributes, :process_detail]), FLAG_ON]
    
    @processor_options = []
    @processor_options += InternalProcessor.all
    @processor_options += HeatProcessor.all
    @processor_options += SurfaceProcessor.all
    @processor_options += AdditionProcessor.all
  end

  def item_params
    params.require(:item).permit(
      process_details_attributes: [
        :id, :lock_version, :name, :condition, :trader_id, :hexavalent_flag, :process_type_id, :tanaka_flag
      ]
    )
  end

end
