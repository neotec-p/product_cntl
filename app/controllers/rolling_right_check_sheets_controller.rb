class RollingRightCheckSheetsController < ApplicationController
  before_action :set_check_sheet, :only => [:edit, :update]
  
  # GET /%%controller_name%%/new
  def new
    @check_sheet = RollingRightCheckSheet.new
    
    @item = Item.find(params[:item_id])
    @check_sheet.item = @item
  end
  
  # GET /%%controller_name%%/1/edit
  def edit
    @item = Item.find(@check_sheet.item_id)
  end
  
  # POST /%%controller_name%%
  def create
    begin
      @check_sheet = RollingRightCheckSheet.new
      @check_sheet.attributes = rolling_right_check_sheet_params
      
      @item = Item.find(@check_sheet.item_id)
      
      if not @check_sheet.valid?
        return render :action => :new
      end
      
      ActiveRecord::Base::transaction do
        @check_sheet.save!()
      end
      
      flash[:notice] = t(:success_created, :id => @item.disp_text + ' : ' + t(:rolling_right_check_sheet, :scope => [:activerecord, :models]))
      redirect_to :action => :edit, :id => @check_sheet.id
      
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end
  
  # PUT /%%controller_name%%/1
  def update
    begin
      @item = Item.find(@check_sheet.item_id)
      
      @check_sheet.attributes = rolling_right_check_sheet_params
      
      if params['delete.x']
        ActiveRecord::Base::transaction do
          @check_sheet.destroy
        end
        
        flash[:notice] = t(:success_deleted, :id => @item.disp_text + ' : ' + t(:rolling_right_check_sheet, :scope => [:activerecord, :models]))
        redirect_to(:controller => :items, :action => :edit, :id => @item)
        
      else
        if not @check_sheet.valid?
          return render :action => :edit
        end
        
        ActiveRecord::Base::transaction do
          @check_sheet.save!
        end
        
        flash[:notice] = t(:success_updated, :id => @item.disp_text + ' : ' + t(:rolling_right_check_sheet, :scope => [:activerecord, :models]))
        redirect_to :action => :edit
      end
      
    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :edit
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :edit
    end
  end

  private
    def set_check_sheet
      @check_sheet = RollingRightCheckSheet.find(params[:id])
    end

    def rolling_right_check_sheet_params
      params.require(:rolling_right_check_sheet).permit(:column1, :standard1_top, :standard1_bottom, :column2, :standard2_top, :standard2_bottom, :column3, :standard3_top, :standard3_bottom, :column4, :standard4_top, :standard4_bottom, :column5, :standard5_top, :standard5_bottom, :column6, :standard6_top, :standard6_bottom, :column7, :standard7_top, :standard7_bottom, :column8, :standard8_top, :standard8_bottom, :column9, :standard9_top, :standard9_bottom, :column10, :standard10_top, :standard10_bottom, :lock_version, :item_id)
    end
  
end
