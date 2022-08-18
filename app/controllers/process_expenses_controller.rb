class ProcessExpensesController < ApplicationController
  before_action :set_process_expense, :only => [:edit, :update]

  # GET /process_expenses/new
  def new
    @process_expense = ProcessExpense.new
    @item = Item.find(params[:item_id])
    @process_expense.item = @item
  end
  
  # GET /process_expenses/1/edit
  def edit
    @process_expense = ProcessExpense.find(params[:id])
    @item = Item.find(@process_expense.item_id)
  end
  
  # POST /process_expenses
  def create
    begin
      @item = Item.find(@process_expense.item_id)
      
      if not @process_expense.valid?
        return render :action => :new
      end
      
      ActiveRecord::Base::transaction do
        @process_expense.save!
      end
      
      flash[:notice] = t(:success_created, :id => @item.disp_text)
      redirect_to :action => :edit, :id => @process_expense.id
      
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end
  
  # PUT /process_expenses/1
  def update
    begin
      @item = Item.find(@process_expense.item_id)
      
      @process_expense.attributes = process_expense_params
      
      if params['delete.x']
        @process_expense.destroy
        
        flash[:notice] = t(:success_deleted, :id => @item.disp_text)
        redirect_to(:controller => :items, :action => :edit, :id => @item.id)
      else
        if not @process_expense.save
          return render :action => :edit
        end
        
        flash[:notice] = t(:success_updated, :id => @item.disp_text)
        redirect_to :action => :edit, :id => @process_expense.id
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
    def set_process_expense
      @process_expense = ProcessExpense.find(params[:id])
    end

    def process_expense_params
      params.require(:process_expense).permit
    end
end
