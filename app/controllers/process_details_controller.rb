class ProcessDetailsController < ApplicationController
  before_action :create_options

  def multi_new
    @item = Item.find(params[:item_id])

    @process_details = []
    processe_types = ProcessType.all.order('seq asc')

    processe_types.each {|process_type|
      process_detail = ProcessDetail.new
      process_detail.process_type = process_type
      process_detail.item_id = @item.id

      @process_details << process_detail
    }
  end

  def multi_edit
    @item = Item.find(params[:item_id])

    if not @item.process_details.empty?
      return @process_details = @item.process_details
    end
  end

  def multi_create
    begin
      @process_details = []

      @item = Item.find(params[:item_id])

      inputs = params[:process_detail]

      isValid = true

      inputs.each {|id, input|
        process_detail = ProcessDetail.find_all_by_item_id_and_process_type_id(@item.id, id).first

        process_detail = ProcessDetail.new if process_detail.nil?

        process_detail.attributes = input
        process_detail.item = @item
        process_detail.process_type = ProcessType.find(id)

        result = process_detail.valid?
        isValid &&= result

        @process_details << process_detail
      }

      @process_details.sort!{|a, b| a.process_type_id <=> b.process_type_id }

      if not isValid
        return render :action => :multi_new
      end

      ActiveRecord::Base::transaction do
        @process_details.each {|process_detail|
          process_detail.save!
        }
      end

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
      @process_details = []

      @item = Item.find(params[:item_id])

      inputs = params[:process_detail]

      if params['delete.x']
        ActiveRecord::Base::transaction do
          inputs.each {|id, input|
            process_detail = ProcessDetail.find_all_by_item_id_and_process_type_id(@item.id, id).first
            process_detail.attributes = input
            process_detail.destroy
          }
        end

        flash[:notice] = t(:success_deleted, :id => create_notice_success(:item_text => @item.disp_text))
        redirect_to(:controller => :items, :action => :edit, :id => @item)

      else
        isValid = true
        process_detail_count_without_procected = 0

        inputs.each {|id, input|
          process_detail = ProcessDetail.find_all_by_item_id_and_process_type_id(@item.id, id).first

          process_detail = ProcessDetail.new if process_detail.nil?

          process_detail.attributes = input
          process_detail.item = @item
          process_detail.process_type = ProcessType.find(id)

          result = process_detail.valid?
          isValid &&= result
          
          if process_detail.process_type.protected_flag.blank?
            process_detail_count_without_procected += 1 unless process_detail.name.blank?
          end

          @process_details << process_detail
        }
        
        if process_detail_count_without_procected > PROCESS_DETAIL_MAX_COUNT
          @process_details[0].errors[:base] << I18n.t(:error_process_detail_max_count, :max => PROCESS_DETAIL_MAX_COUNT)
          isValid = false
        end

        @process_details.sort!{|a, b| a.process_type_id <=> b.process_type_id }

        if not isValid
          return render :action => :multi_edit
        end

        ActiveRecord::Base::transaction do
          @process_details.each {|process_detail|
            process_detail.save!
          }
        end

        flash[:notice] = t(:success_updated, :id => notice_success)

        redirect_to :action => :multi_edit, :item_id => @item.id
      end

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

end
