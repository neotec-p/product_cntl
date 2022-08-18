# encoding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # 凡例
  def note(text, options = {})
    " [ #{text} ] "
  end

  # 赤に着色
  def font_red(contents, options = {})
    font_color(contents, "red", options)
  end

  # 赤に着色
  def font_green(contents, options = {})
    font_color(contents, "green", options)
  end

  # 色で文字列を強調
  def font_color(contents, color, options = {})
    color = "red" if color.blank?

    style = options.fetch(:style, "")

    content_tag(:font, contents, { :color => color, :style => style }, false)
  end

  def disp_none(options = {})
    return DISP_NONE
  end

  def confirm_force_submit(options = {})
    
    act = t(:button_summate_month)
    act = options[:act] unless options[:act].blank?
    
    return t(:confirm_force_submit, :act => act)
  end

  # メインタイトル
  def main_title(options = {})
    controller = controller_name
    controller = options[:controller] unless options[:controller].blank?

    title_con = hlabel_model(get_model_by_controller(:controller => controller))

    act = action_name
    act = :edit if action_name == 'destroy'

    act = options[:action] unless options[:action].blank?

    title_act = I18n.t(act, :scope => [:actions])

    main_title_direct(title_con, title_act)
  end
  
  def main_title_direct(title_con, title_act)
    main_title_core(html_escape(title_con + ' >> ' + title_act))
  end
  
  def main_title_core(contents, options = {})
    "<div id='main-title'><h3>" + contents + "</h3></div>"
  end

  # フラッシュ
  def flash_tag
    output = ""
    if flash[:error].present?
      errors = flash[:error]
      errors = [errors] unless errors.is_a?(Array)
      output += "<div id=\"errorExplanation\" class=\"errorExplanation\"><h2><p>"
      errors.each {|error|
        output += simple_format(error, {}, :wrapper_tag => "div")
      }
      output += "</h2></div>"
    end
    if flash[:notice].present?
      output += "<div id=\"actionMessage\" class=\"actionMessage\">#{simple_format(flash[:notice], {}, :wrapper_tag => "div")}</div>"
    end
    if flash[:alert].present?
      alerts = flash[:alert]
      alerts = [alerts] unless alerts.is_a?(Array)
      output += "<div id=\"alertMessage\" class=\"alertMessage\">"
      alerts.each {|alert|
        output += simple_format(alert, {}, :wrapper_tag => "div")
      }
      output += "</div>"
    end
    flash.clear

    output
  end

  # ソート
  def sort_tag(key)
    asc  = ! (!@app_search.blank? && @app_search.tag_sort == key && @app_search.tag_order == 'asc' )
    desc = ! (!@app_search.blank? && @app_search.tag_sort == key && @app_search.tag_order == 'desc')
    sort_asc  = link_to_if asc,  "▲", "javascript:sort('#{key}','asc' );"
    sort_desc = link_to_if desc, "▼", "javascript:sort('#{key}','desc');"
    sort_asc + ' ' + sort_desc
  end

  # モデル名取得（コントローラー名経由）
  def get_model_by_controller(options = {})
    controller = controller_name
    controller = options[:controller] unless options[:controller].blank?

    controller.to_s.classify.underscore
  end

  # 日時表示
  def hdate(obj, options = {})
    format = :default
    format = options[:format] unless options[:format].blank?
    I18n.l obj, :format => format unless obj.blank?
  end

  # 数量表示
  def hnumber(obj, options = {})
    number_with_delimiter obj unless obj.blank?
  end
  
  # 符号付の数量表示
  def hnumber_with_sign(obj, options = {})
    return if obj.blank?
    
    zero_green = false
    zero_green = options[:zero_green] unless options[:zero_green].blank?

    if obj > 0
      return font_green("+" + hnumber(obj, options))
    elsif (obj == 0 && zero_green)
      return font_green(hnumber(obj, options))
    else
      return font_red(hnumber(obj, options))
    end
  end

  # 数量表示(小数点以下の指定可能)
  def hnumber_with_precision(obj, options = {})
    unless options[:delimiter]
      options[:delimiter] = ","
    end
    
    number_with_precision(obj, options) unless obj.blank?
  end

  # 符号付の数量表示
  def hnumber_with_precision_and_sign(obj, options = {})
    return if obj.blank?
    
    zero_green = false
    zero_green = options[:zero_green] unless options[:zero_green].blank?

    if obj > 0
      return font_green("+" + hnumber_with_precision(obj, options))
    elsif (obj == 0 && zero_green)
      return font_green(hnumber_with_precision(obj, options))
    else
      return font_red(hnumber_with_precision(obj, options))
    end
  end

  # 管理表発行表示 2012.10.31 N.Hanamura Add
  def print_flag_on(obj, options = {})
    return if obj.blank?

    if (obj == "未発行")
      return font_red(obj, options)
    else
      return font_green(obj, options)
    end
  end

  # ラベル表示
  def hlabel(obj, method)
    I18n.t(method, :scope => [:activerecord, :attributes, obj])
  end

  # ラベル表示 - model
  def hlabel_model(method)
    I18n.t(method, :scope => [:activerecord, :models])
  end

  # リンク用ボタン
  def link_button_tag(caption, options = {})
    controller = controller_name
    controller = options[:controller] unless options[:controller].blank?

    action = :index
    action = options[:action] unless options[:action].blank?

    id = nil
    id = options[:id] unless options[:id].blank?

    title = ""
    title = options[:title] unless options[:title].blank?

    button_class = ""
    button_class = options[:button_class] unless options[:button_class].blank?

    params = {}
    params = options[:params] unless options[:params].blank?

    url = ""
    if id
      url = url_for(:controller => controller, :action => action, :id => id, :params => params)
    else
      url = url_for(:controller => controller, :action => action, :params => params)
    end

    button_tag(caption, :onclick => "location.href='#{url}'", :class => button_class, :title => title, :type => "button")
  end

  # ポップアップ用ボタン
  def popup_button_tag(caption, options = {})
    controller = controller_name
    controller = options[:controller] unless options[:controller].blank?

    action = :index
    action = options[:action] unless options[:action].blank?

    id = nil
    id = options[:id] unless options[:id].blank?

    title = ""
    title = options[:title] unless options[:title].blank?

    button_class = ""
    button_class = options[:button_class] unless options[:button_class].blank?
    
    height = "300"
    height = options[:height] unless options[:height].blank?

    params = {}
    params = options[:params] unless options[:params].blank?

    url = ""
    if id
      url = url_for(:controller => controller, :action => action, :id => id, :params => params)
    else
      url = url_for(:controller => controller, :action => action, :params => params)
    end

    button_tag(caption, :onclick => "javascript:pop('#{url}', #{height}, '#{title}')", :class => button_class, :title => title, :type => "button")
  end
  
  # ポップアップwindowのcloseボタン
  def close_button_tag(options = {})
    caption = h(t(:button_close))
    caption = options[:caption] unless options[:caption].blank?
    
    title = ""
    title = options[:title] unless options[:title].blank?

    button_class = ""
    button_class = options[:button_class] unless options[:button_class].blank?

    button_tag(caption, :onclick => "javascript:window.close()", :class => button_class, :title => title, :type => "button")
  end

  # カレンダー選択値クリアボタン
  def clear_cal_button_tag(options = {})
    button_tag(t(:button_clear), :onclick => "showCalClearBtn(this)", :class => "clearCalBtn", :type => :button)
  end

  # カレンダー選択値クリアボタン short
  def clear_cal_button_short_tag(options = {})
    button_tag(t(:button_clear), :onclick => "showCalClearBtn(this)", :class => "clearCalBtnShort", :type => :button)
  end

  # menu
  def menu(obj, options = {})
    link_to(t(obj, :scope => :controllers), :controller => obj)
  end

  # 新規作成ボタン
  def new_button_tag(options = {})
    controller = controller_name
    controller = options[:controller] unless options[:controller].blank?

    action = :new
    action = options[:action] unless options[:action].blank?

    alt = t(:new, :scope => [:actions])
    link_to image_tag(image_path_locale("btn_blue_new"), :alt => alt), {:controller => controller, :action => action}
  end

  # 取消ボタン
  def cancel_button_tag(options = {})
    if session[:prm]
      params = session[:prm]
      params.delete(:controller)
      params.delete(:action)
    end

    controller = controller_name
    controller = options[:controller] unless options[:controller].blank?

    action = :index
    action = options[:action] unless options[:action].blank?

    alt = t(:cancel, :scope => :actions)
    alt = options[:alt] unless options[:alt].blank?

    link_to image_tag(image_path_locale("btn_gray_back"), :alt => alt), {:controller => controller, :action => action, :params => params}, {:confirm => options[:confirm]}
  end

  # sessionの戻り先へ移動するボタン
  def session_back_button_tag(options = {})
    controller = nil
    action = nil
    if session[:prm]
      params = session[:prm]
      controller = params.delete(:controller)
      action = params.delete(:action)
    end

    if controller.blank?
      unless options[:controller].blank?
        controller = options[:controller] 
      else
        controller = controller_name
      end
    end
    if action.blank?
      unless options[:action].blank?
        action = options[:action] 
      else
        action = :index
      end
    end

    alt = t(:cancel, :scope => :actions)
    alt = options[:alt] unless options[:alt].blank?

    link_to image_tag(image_path_locale("btn_gray_back"), :alt => alt), {:controller => controller, :action => action, :params => params}, {:confirm => options[:confirm]}
  end

  # 登録ボタン
  def submit_button_tag(options = {})
    conf = ''
    conf = options[:conf] unless options[:conf].blank?
    conf += t(:confirm_submit)

    image_submit_tag image_path_locale("btn_blue_save"), :confirm => conf
  end

  # 削除ボタン
  def delete_image_button_tag(url, options = {})
    conf = ''
    conf = options[:conf] unless options[:conf].blank?
    conf += t(:confirm_delete)

    alt = t(:delete, :scope => [:actions])
    alt = options[:alt] unless options[:alt].blank?

    #image_submit_tag image_path_locale("btn_red_del"), :confirm => conf, :style => "float: right;", :name => :delete, :alt => alt
    link_to image_tag(image_path_locale("btn_red_del"), alt: alt), url, { method: :delete, style: "float: right;", data: { confirm: conf } }
  end

  # 削除ボタン（イメージでなく、ボタン）
  def delete_button_tag(options = {})
    caption = t(:button_delete)
    caption = options[:caption] unless options[:caption].blank?

    options[:confirm] = t(:confirm_delete)

    submit_button_button_tag(caption, :delete, options)
  end

  # サブミットボタン（イメージでなく、ボタン）
  def submit_button_button_tag(caption, name, options = {})
    options[:name] = name

    submit_tag caption, options
  end

  # ロケールを考慮したイメージファイルパス
  def image_path_locale(name, options = {})
    locale = I18n.locale.to_s
    locale = options[:locale].to_s if options[:locale].present?

    extension = 'png'
    extension = options[:extension].to_s if options[:extension].present?

    #return image_path("#{name}_#{locale}.#{extension}")
    asset_path("#{name}_#{locale}.#{extension}")
  end

  # 品目マスタ関連の共通タブメニュー
  def tab_menu_for_item(options = {})
    return if @hide_tabmenu

    links = []
    
    item = link_to t("activerecord.models.item"), edit_item_path(@item)
    item_actions = ["new", "create", "edit", "update"]
    class_name = ""
    class_name = "act" if (controller_name == 'items') && (item_actions.include?(action_name))
    links << raw(content_tag(:li, item, { :class => class_name }, false))

    check_sheet = link_to(t("activerecord.models.check_sheet"), :controller => :header_left_check_sheets, :action => :new, :item_id => @item)
    check_sheet = link_to(t("activerecord.models.check_sheet"), edit_header_left_check_sheet_path(@item.header_left_check_sheet)) unless @item.header_left_check_sheet.nil?
    check_sheet_controllers = ['header_left_check_sheets', 'header_right_check_sheets', 'rolling_left_check_sheets', 'rolling_right_check_sheets']
    class_name = ""
    class_name = "act" if check_sheet_controllers.include?(controller_name)
    links << raw(content_tag(:li, check_sheet, { :class => class_name }, false))

    process_detail = link_to(t("activerecord.models.process_detail"), {:controller => :process_details, :action => :multi_new, :item_id => @item})
    process_detail = link_to(t("activerecord.models.process_detail"), {:controller => :process_details, :action => :multi_edit, :item_id => @item}) unless @item.process_details.empty?
    class_name = ""
    class_name = "act" if controller_name == "process_details"
    links << raw(content_tag(:li, process_detail, { :class => class_name }, false))

    parts = link_to t("actions.set_parts"), {:controller => :items, :action => :set_parts, :id => @item}
    parts_actions = ["set_parts", "set_parts_update"]
    class_name = ""
    class_name = "act" if (controller_name == 'items') && (parts_actions.include?(action_name))
    links << raw(content_tag(:li, parts, { :class => class_name }, false))

    process_expense = link_to t("activerecord.models.process_expense"), {:controller => :process_expenses, :action => :new, :item_id => @item}
    process_expense = link_to t("activerecord.models.process_expense"), edit_process_expense_path(@item.process_expense) unless @item.process_expense.nil?
    class_name = ""
    class_name = "act" if controller_name == "process_expenses"
    links << raw(content_tag(:li, process_expense, { :class => class_name }, false))
    
    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # チェックシート関連の共通タブメニュー
  def tab_menu_for_check_sheet(options = {})
    links = []
    
    header_left = link_to t("activerecord.models.header_left_check_sheet"), {:controller => :header_left_check_sheets, :action => :new, :item_id => @item}
    header_left = link_to t("activerecord.models.header_left_check_sheet"), edit_header_left_check_sheet_path(@item.header_left_check_sheet) unless @item.header_left_check_sheet.nil?
    class_name = ""
    class_name = "act" if controller_name == 'header_left_check_sheets'
    links << raw(content_tag(:li, header_left, { :class => class_name }, false))

    header_right = link_to t("activerecord.models.header_right_check_sheet"), {:controller => :header_right_check_sheets, :action => :new, :item_id => @item}
    header_right = link_to t("activerecord.models.header_right_check_sheet"), edit_header_right_check_sheet_path(@item.header_right_check_sheet) unless @item.header_right_check_sheet.nil?
    class_name = ""
    class_name = "act" if controller_name == 'header_right_check_sheets'
    links << raw(content_tag(:li, header_right, { :class => class_name }, false))

    rolling_left = link_to t("activerecord.models.rolling_left_check_sheet"), {:controller => :rolling_left_check_sheets, :action => :new, :item_id => @item}
    rolling_left = link_to t("activerecord.models.rolling_left_check_sheet"), edit_rolling_left_check_sheet_path(@item.rolling_left_check_sheet) unless @item.rolling_left_check_sheet.nil?
    class_name = ""
    class_name = "act" if controller_name == 'rolling_left_check_sheets'
    links << raw(content_tag(:li, rolling_left, { :class => class_name }, false))

    rolling_right = link_to t("activerecord.models.rolling_right_check_sheet"), {:controller => :rolling_right_check_sheets, :action => :new, :item_id => @item}
    rolling_right = link_to t("activerecord.models.rolling_right_check_sheet"), edit_rolling_right_check_sheet_path(@item.rolling_right_check_sheet) unless @item.rolling_right_check_sheet.nil?
    class_name = ""
    class_name = "act" if controller_name == 'rolling_right_check_sheets'
    links << raw(content_tag(:li, rolling_right, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 加工先関連の共通タブメニュー
  def tab_menu_for_processor(options = {})
    links = []
    
    heat_processor = link_to t("activerecord.models.heat_processor"), heat_processors_path
    class_name = ""
    class_name = "act" if controller_name == 'heat_processors'
    links << raw(content_tag(:li, heat_processor, { :class => class_name }, false))

    surface_processor = link_to t("activerecord.models.surface_processor"), surface_processors_path
    class_name = ""
    class_name = "act" if controller_name == 'surface_processors'
    links << raw(content_tag(:li, surface_processor, { :class => class_name }, false))

    addition_processor = link_to t("activerecord.models.addition_processor"), addition_processors_path
    class_name = ""
    class_name = "act" if controller_name == 'addition_processors'
    links << raw(content_tag(:li, addition_processor, { :class => class_name }, false))

    internal_processor = link_to t("activerecord.models.internal_processor"), internal_processors_path
    class_name = ""
    class_name = "act" if controller_name == 'internal_processors'
    links << raw(content_tag(:li, internal_processor, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 処理価格関連の共通タブメニュー
  def tab_menu_for_process_price(options = {})
    links = []
    
    heat_process_price = link_to t("activerecord.models.heat_process_price"), heat_process_prices_path
    class_name = ""
    class_name = "act" if controller_name == 'heat_process_prices'
    links << raw(content_tag(:li, heat_process_price, { :class => class_name }, false))

    surface_process_price = link_to t("activerecord.models.surface_process_price"), surface_process_prices_path
    class_name = ""
    class_name = "act" if controller_name == 'surface_process_prices'
    links << raw(content_tag(:li, surface_process_price, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 注文管理関連の共通タブメニュー
  def tab_menu_for_order(options = {})
    links = []
    
    list = link_to t("actions.un_treated_index"), orders_path
    list_actions  = ["index", "edit", "update"]
    list_actions += ["multi_new", "multi_create"]
    list_actions += ["multi_import", "import", "multi_import_create"]
    list_actions += ["fix_production", "fix_production_update"]

    class_name = ""
    class_name = "act" if list_actions.include?(action_name)
    links << raw(content_tag(:li, list, { :class => class_name }, false))

    fix_parts = link_to t("actions.fix_parts"), fix_parts_orders_path
    fix_parts_actions = ['fix_parts', 'fix_parts_update']

    class_name = ""
    class_name = "act" if fix_parts_actions.include?(action_name)
    links << raw(content_tag(:li, fix_parts, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 注文管理関連の共通サブタブメニュー
  def tab_submenu_for_order(options = {})
    links = []
    
    new_link = link_to(t("actions.hand"), multi_new_orders_path)
    new_actions = ["multi_new", "multi_create"]

    class_name = ""
    class_name = "act" if new_actions.include?(action_name)
    links << raw(content_tag(:li, new_link, { :class => class_name }, false))

    import_link = link_to(t("actions.csv_import"), multi_import_orders_path)
    import_actions = ["multi_import", "import", "multi_import_create"]

    class_name = ""
    class_name = "act" if import_actions.include?(action_name)
    links << raw(content_tag(:li, import_link, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 生産管理関連の共通タブメニュー
  def tab_menu_for_production(options = {})
    links = []
    
    list = link_to(t("actions.production_status"), vote_no_index_productions_path)
    list_actions = ['index', 'print_all', 'edit', 'update', 'material_index', 'vote_no_index', 'item_code_index', 'yeild_index']
    list_actions += ['div_branch', 'div_branch_update', 'div_lot', 'div_lot_update']
    list_actions += ['edit_material', 'edit_material_update', 'edit_washer', 'edit_washer_update']
    class_name = nil
    class_name = :act if(list_actions.include?(action_name) && controller_name == "productions")
    links << raw(content_tag(:li, list, { :class => class_name }, false))

    model = link_to(t("actions.multi_model"), multi_model_productions_path)
    model_actions = ['multi_model', 'multi_model_update']
    class_name = nil
    class_name = :act if model_actions.include?(action_name)
    links << raw(content_tag(:li, model, { :class => class_name }, false))

    plan = link_to(t("actions.multi_plan"), multi_plan_productions_path)
    plan_actions = ['multi_plan', 'multi_plan_update', 'print_t040']
    class_name = nil
    class_name = :act if plan_actions.include?(action_name)
    links << raw(content_tag(:li, plan, { :class => class_name }, false))

    lot = link_to(t("actions.lot_no_index"), lots_path)
    class_name = nil
    class_name = :act if(controller_name == "lots")
    links << raw(content_tag(:li, lot, { :class => class_name }, false))

    process_order = link_to(t("actions.process_order_index"), process_orders_path)
    process_order_controllers = ["process_orders", "heat_process_orders", "surface_process_orders", "addition_process_orders"]
    class_name = nil
    class_name = :act if process_order_controllers.include?(controller_name)
    links << raw(content_tag(:li, process_order, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 生産管理関連の共通サブタブメニュー
  def tab_submenu_for_production(production, options = {})
    links = []
    
    production_link = link_to(t("activerecord.models.production_detail"), edit_production_path(production))
    production_link_actions = ["edit", "update"]
    production_link_actions += ["div_branch", "div_branch_update", "div_lot", "div_lot_update"]
    
    material_link = link_to(t("actions.edit_material"), edit_material_production_path(production))
    material_link_actions = ["edit_material", "edit_material_update"]

    washer_link = link_to((t("actions.edit_washer")), edit_washer_production_path(production))
    washer_link_actions = ["edit_washer", "edit_washer_update"]

    class_name = ""
    class_name = "act" if production_link_actions.include?(action_name)
    links << raw(content_tag(:li, production_link, { :class => class_name }, false))

    class_name = ""
    class_name = "act" if material_link_actions.include?(action_name)
    links << raw(content_tag(:li, material_link, { :class => class_name }, false))

    class_name = ""
    class_name = "act" if washer_link_actions.include?(action_name)
    links << raw(content_tag(:li, washer_link, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 生産状況関連の共通サブタブメニュー
  def tab_submenu_for_production_status(options = {})
    links = []
    
    vote_no_link = link_to(t("actions.production_status_vote_no"), vote_no_index_productions_path)
    vote_no_actions = ["vote_no_index"]
    class_name = nil
    class_name = :act if vote_no_actions.include?(action_name)
    links << raw(content_tag(:li, vote_no_link, { :class => class_name }, false))

    process_type_link = link_to(t("actions.production_status_process_type"), productions_path)
    process_type_actions = ["index", "print_all"]
    class_name = nil
    class_name = :act if process_type_actions.include?(action_name)
    links << raw(content_tag(:li, process_type_link, { :class => class_name }, false))

    material_link = link_to(t("actions.production_status_material"), material_index_productions_path)
    material_actions = ["material_index"]
    class_name = nil
    class_name = :act if material_actions.include?(action_name)
    links << raw(content_tag(:li, material_link, { :class => class_name }, false))

    item_code_link = link_to(t("actions.production_status_item_code"), item_code_index_productions_path)
    item_code_actions = ["item_code_index"]
    class_name = nil
    class_name = :act if item_code_actions.include?(action_name)
    links << raw(content_tag(:li, item_code_link, { :class => class_name }, false))

    yeild_link = link_to(t("actions.production_status_yeild"), yeild_index_productions_path)
    yeild_actions = ["yeild_index"]
    class_name = nil
    class_name = :act if yeild_actions.include?(action_name)
    links << raw(content_tag(:li, yeild_link, { :class => class_name }, false))

    return content_tag(:ul, (links.join), { :class => :tabmenu }, false)
  end

  # 二次加工一覧関連の共通サブタブメニュー
  def tab_submenu_for_process_order(options = {})
    links = []
    
    index_link = link_to(t("actions.un_treated_index"), process_orders_path)
    index_link_actions = ["index", "print_all"]
    
    class_name = ""
    class_name = "act" if index_link_actions.include?(action_name)
    links << raw(content_tag(:li, index_link, { :class => class_name }, false))

    treated_index_link = link_to(t("actions.treated_index"), treated_index_process_orders_path)
    treated_index_link_actions = ["treated_index"]

    class_name = ""
    class_name = "act" if treated_index_link_actions.include?(action_name)
    links << raw(content_tag(:li, treated_index_link, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 座金管理関連の共通タブメニュー
  def tab_menu_for_washer_stock(options = {})
    links = []
    
    t141_actions = ["cond_print_t141", "print_t141"]
    
    list = link_to(t("actions.stock_index"), stock_index_washers_path)
    
    class_name = ""
    class_name = "act" if controller_name == "washers"
    links << raw(content_tag(:li, list, { :class => class_name }, false))

    order = link_to(t("actions.order_index"), washer_orders_path)

    class_name = ""
    class_name = "act" if (controller_name == "washer_stocks") || ((controller_name == "washer_orders") && !t141_actions.include?(action_name))
    links << raw(content_tag(:li, order, { :class => class_name }, false))

    t141 = link_to(t("actions.print_t141"), cond_print_t141_washer_orders_path)

    class_name = ""
    class_name = "act" if (controller_name == "washer_orders") && t141_actions.include?(action_name)
    links << raw(content_tag(:li, t141, { :class => class_name }, false))

    return content_tag(:ul, links.join, { :class => :tabmenu }, false)
  end

  # 座金管理関連の共通サブタブメニュー
  def tab_submenu_for_washer_stock(options = {})
    washer = @washer
    washer = @washer_order.washer unless @washer_order.nil?
    washer = @washer_stock.washer unless @washer_stock.nil?
    washer_order = @washer_order
    washer_order = @washer_stock.washer_order unless @washer_stock.nil?
    washer_stock = @washer_stock

    stock_link = link_to(t("actions.stock"), stock_washer_path(washer))

    washer_order_link = ""
    unless washer_order.nil?
      label = t("actions.order")
      if washer_order.new_record?
        washer_order_link = link_to(label, {:controller => :washer_orders, :action => :new, :washer_id => @washer})
      else
        washer_order_link = link_to(label, edit_washer_order_path(washer_order))
      end
    end

    washer_stock_link = ""
    unless washer_stock.nil?
      label = t("actions.stock_manage")
      if washer_stock.new_record?
        washer_stock_link = link_to(label, {:controller => :washer_stocks, :action => :new, :washer_order_id => @washer_order})
      else
        washer_stock_link = link_to(label, edit_washer_stock_path(washer_stock))
      end
    end

    class_name = ""
    class_name = "act" if controller_name == "washers"
    stock_link = raw(content_tag(:li, stock_link, { :class => class_name }, false))

    unless washer_order_link.blank?
      class_name = ""
      class_name = "act" if controller_name == "washer_orders"
      washer_order_link = raw(content_tag(:li, washer_order_link, { :class => class_name }, false))
    end

    unless washer_stock_link.blank?
      class_name = ""
      class_name = "act" if controller_name == "washer_stocks"
      washer_stock_link = raw(content_tag(:li, washer_stock_link, { :class => class_name }, false))
    end

    return content_tag(:ul, (stock_link + washer_order_link + washer_stock_link), { :class => :tabmenu }, false)
  end
  
  # 一括印刷用チェックボックスの属性を準備する
  def prepare_print_all_attr(report)
    asynchro_status = report.asynchro_status
    
    label = nil
    disabled = true
    if asynchro_status.nil?
      label = h(t(:status_print_yet))
      disabled = false
    elsif asynchro_status.id == ASYNCHRO_STATUS_DONE
      label = h(t(:status_print_done))
      disabled = false
    elsif asynchro_status.id == ASYNCHRO_STATUS_ERROR
      label = asynchro_status.name
      disabled = false
    else
      label = asynchro_status.name
      disabled = true
    end
    
    attr = {}
    
    attr[:label] = label
    attr[:disabled] = disabled
    
    return attr
  end
  
  def momo_button(production)
    action = :new
    action = :index if @app.user.role_purchase_or_sales?
    
    caption = t(:button_memo_none)
    caption = t(:button_memo) unless production.memos.empty?
    
    return popup_button_tag(h(caption), :controller => :memos, :action => action, :params => {:production_id => production.id}, :height => 450, :button_class => :formInBtn)
  end



      def error_messages_for(*params)
        options = params.extract_options!.symbolize_keys

        if object = options.delete(:object)
          objects = Array.wrap(object)
        else
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        end

        errors = Array.new
        for record in objects
          unless record.errors.empty?
            record.errors.full_messages { |msg| errors.push(msg) }
          end
        end
        errors = errors.uniq

        unless errors.empty?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end

          options = options.symbolize_keys

          I18n.with_options :locale => options[:locale], :scope => [:activerecord, :errors, :template] do |locale|
            header_message = locale.t :header, :count => errors.size
            message = locale.t(:body)
            error_messages = errors.collect {|msg| raw(content_tag(:li, ERB::Util.html_escape(msg), {}, false)) }.join

            contents = ''
            contents << raw(content_tag(options[:header_tag] || :h2, header_message, {}, false)) unless header_message.blank?
            contents << raw(content_tag(:p, message, {}, false)) unless message.blank?
            contents << raw(content_tag(:ul, error_messages, {}, false))

            content_tag(:div, contents, html, false)
          end
        end
      end


end
