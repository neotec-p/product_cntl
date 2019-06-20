class ApplicationSearch # < ActiveRecord::Base

  def initialize(params, options = {})
    @param_sort    = params[:sort]
    @param_order   = params[:order]

    @sort          = 'id'
    @sort          = @param_sort unless @param_sort.blank?
    @order         = 'desc'
    @order         = 'asc' if @param_order == 'asc'

    @tag_sort      = @sort
    @tag_order     = @order
  end

  attr_accessor :param_sort
  attr_accessor :param_order

  attr_accessor :sort
  attr_accessor :order

  attr_accessor :tag_sort
  attr_accessor :tag_order

  def default_sort(val)
    @sort = @tag_sort = val if val
  end
  def default_order(val)
    @order = @tag_order = val if val
  end

  # id desc 以外を、明示的に初期条件とする
  def default(sort, order)
    self.default_sort(sort)
    self.default_order(order)
  end

  # 短縮名 -> DBの物理列名に変換する
  def resolvePhy(val, val2)
    self.sort = val2 if val == @sort
  end

  # order by 条件文字列
  def orderby
    @sort.to_s + ' ' + @order.to_s
  end

end
