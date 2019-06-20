class LotsController < ApplicationController
  # GET /%%controller_name%%/
  def index
    lots = Lot

    if params[:cond_lot_no].present?
      lots = lots.where(lot_no: params[:cond_lot_no])
    end
    if params[:cond_vote_no].present?
      lots = lots.includes([:production]).where(productions: { vote_no: params[:cond_vote_no] })
    end
    if params[:cond_item_customer_code].present? and params[:cond_item_code].present?
      lots = lots.includes([:production]).where(productions: { customer_code: params[:cond_item_customer_code], code: params[:cond_item_code] })
    end

    lots = lots.order("lot_no desc")
    
    session_set_prm

    @lots = lots.paginate(:page => params[:page], :per_page => PAGINATE_PER_PAGE);
  end

end
