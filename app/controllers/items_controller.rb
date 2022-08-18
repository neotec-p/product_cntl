class ItemsController < ApplicationController
  before_action :create_options
  before_action :create_parts_options, :only => [ :set_parts, :set_parts_update ]

  before_action :set_item, :only => [:edit, :update, :set_parts, :set_parts_update]
  
  # GET /items
  def index
    @hide_tabmenu = true

    session_set_prm

    items = Item.available(params[:cond_customer_code], params[:cond_code], params[:cond_drawing_no], params[:cond_name]).order("customer_code asc, code asc")

    @items = items.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

  # GET /items/new
  def new
    @hide_tabmenu = true

    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  def create
    begin
      @hide_tabmenu = true

      @item = Item.new(item_params)

      if not @item.valid?
        return render :action => :new
      end

      ActiveRecord::Base::transaction do
        customer = Customer.find_by_code(@item.customer_code)
        @item.customer = customer

        @item.save!()
      end

      flash[:notice] = t(:success_created, :id => notice_success)
      redirect_to :action => :edit, :id => @item.id

    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :new
    end
  end

  # PUT /items/1
  def update
    begin
      @item.attributes = item_params

      if params['delete.x']
        ActiveRecord::Base::transaction do
          @item.destroy
        end

        flash[:notice] = t(:success_deleted, :id => notice_success)
        redirect_to(:action => :index)

      else
        if not @item.valid?
          return render :action => :edit
        end

        ActiveRecord::Base::transaction do
          customer = Customer.find_by_code(@item.customer_code)
          @item.customer = customer

          @item.save!
        end

        flash[:notice] = t(:success_updated, :id => notice_success)
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

  # 材料選択 GET
  def set_parts
    @parts = Parts.new

    material = @item.materials.first
    unless material.nil?
      @parts.material_id = material.id
      @parts.material = material
    end
    item_washer_seq1 = @item.item_washer_seqs.where(seq: 1).first
    unless item_washer_seq1.nil?
      @parts.washer_id1 = item_washer_seq1.washer.id
      @parts.washer1 = item_washer_seq1.washer
    end
    item_washer_seq2 = @item.item_washer_seqs.where(seq: 2).first
    unless item_washer_seq2.nil?
      @parts.washer_id2 = item_washer_seq2.washer.id
      @parts.washer2 = item_washer_seq2.washer
    end
  end

  # 材料選択 PUT
  def set_parts_update
    begin
      @parts = Parts.new
      input = params[:parts]
      @parts.set_attributes(input)

      @item.lock_version = input[:item_lock_version]

      if not @parts.valid?
        return render :action => :set_parts
      end

      ActiveRecord::Base::transaction do
        @item.set_parts(@parts)
        @item.save!
      end

      flash[:notice] = t(:success_updated, :id => notice_success)
      redirect_to :action => :set_parts

    rescue ActiveRecord::StaleObjectError => so
      flash[:error] = t(:error_stale_object)
      render :action => :set_parts
    rescue => e
      flash[:error] = t(:error_default, :message => e.message)
      render :action => :set_parts
    end
  end

  private

  def create_options
    @hd_model_options = Model.find_by_plan_process_flag(PLAN_PROCESS_FLAG_HD)
    @hd_addition_model_options = Model.find_by_plan_process_flag(PLAN_PROCESS_FLAG_HD_ADDITION)
    @ro1_model_options = Model.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO1)
    @ro1_addition_model_options = Model.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO1_ADDITION)
    @ro2_model_options = Model.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO2)
    @ro2_addition_model_options = Model.find_by_plan_process_flag(PLAN_PROCESS_FLAG_RO2_ADDITION)
  end

  def notice_success
    return @item.disp_text
  end

  def create_parts_options
    @materials_options = Material.select_options
    @washers_options = Washer.select_options
  end
  

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:customer_code, :code, :logical_weight_flag, :drawing_no, :name, :price, :weight, :punch, :surface_note, :vote_note, :hd_model_name1, :ro1_model_name1, :ro2_model_name1, :hd_model_name2, :ro1_model_name2, :ro2_model_name2, :hd_model_name3, :ro1_model_name3, :ro2_model_name3, :hd_addition_model_name, :ro1_addition_model_name, :ro2_addition_model_name, :lock_version)
    end
end
