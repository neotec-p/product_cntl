Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :customers, :except => [:show]

  resources :models, :except => [:show] do
    member do
      get 'pop_model_production_plan'
    end
  end
  
  resources :materials, :except => [:show] do
    collection do
      get 'stock_index' #, :as => :stock
      get 'pop_material_for_text'
      get 'pop_material_for_link'
    end
    member do
      get 'stock'
      put 'collect_print'
    end
  end
  
  resources :washers, :except => [:show] do
    collection do 
      get 'stock_index'
      get 'pop_washer_for_text'
      get 'pop_washer_for_link'
    end
    member do 
      get 'stock'
      put 'collect_print'
    end
  end

  resources :items, :except => [:show, :destroy] do
    member do 
      get 'set_parts'
      put 'set_parts_update'
    end
  end

  resources :process_expenses, :except => [:index, :show, :destroy]

  resources :header_right_check_sheets, :except => [:index, :show, :destroy]

  resources :header_left_check_sheets, :except => [:index, :show, :destroy]

  resources :rolling_right_check_sheets, :except => [:index, :show, :destroy]

  resources :rolling_left_check_sheets, :except => [:index, :show, :destroy]

  resources :process_details, :only => [:multi_new, :multi_edit, :multi_create, :multi_update] do
    collection do
      get 'multi_new'
      get 'multi_edit'
      post 'multi_create'
      put 'multi_update'
    end
  end

  resources :heat_processors, :except => [:show]

  resources :surface_processors, :except => [:show]

  resources :addition_processors, :except => [:show]

  resources :internal_processors, :except => [:show]

  resources :material_suppliers, :except => [:show]

  resources :washer_suppliers, :except => [:show]

  resources :users, :except => [:show] do
    member do
      get 'passwd'
      put 'passwd_update'
    end
  end

  resources :orders, :except => [:show, :new, :create] do
    collection do 
      get 'multi_new'
      post 'multi_create'
      get 'multi_import'
      post 'import'
      post 'multi_import_create'
      get 'fix_parts'
      put 'fix_parts_update'
    end
    member do
      get 'fix_production'
      put 'fix_production_update'
    end
  end

  resources :productions, :except => [:show, :destroy] do
    collection do 
      put 'print_all'
      get 'vote_no_index'
      get 'item_code_index'
      get 'material_index'
      get 'multi_plan'
      put 'multi_plan_update'
      post 'print_t040'
      get 'multi_model'
      put 'multi_model_update'
      get 'yeild_index'
    end
    member do
      post 'report'
      get 'div_branch'
      put 'div_branch_update'
      get 'div_lot'
      put 'div_lot'
      get 'edit_material'
      put 'edit_material_update'
      get 'edit_washer'
      put 'edit_washer_update'
    end
  end

  resources :memos, :only => [:index, :new, :create]

  resources :material_stocks, :except => [:show]
  resources :washer_stocks, :except => [:show]

  resources :material_orders, :except => [:show, :destroy] do
    collection do
      put 'print_all'
      get 'cond_print_t140'
      put 'print_t140'
    end
    member do 
      put 'print_t150'
    end
  end

  resources :washer_orders, :except => [:show, :destroy] do
    collection do 
      put 'print_all'
      get 'cond_print_t141'
      put 'print_t141'
    end
    member do
      put 'collect_print'
    end
  end


  resources :lots, :only => [:index]
  
  resources :process_orders, :only => [:index, :treated_index, :print_all] do
    collection do 
      get 'treated_index'
      put 'print_all'
    end
  end
  
  resources :heat_process_orders, :except => [:show, :destroy, :index]

  resources :surface_process_orders, :except => [:show, :index]

  resources :addition_process_orders, :except => [:show, :index]

  resources :defectives, :except => [:show] do
    collection do
      get 'cond_print'
      put 'print'
    end
  end

  resources :reports, :only => [:index, :download] do
    member do
      get 'download'
    end
  end

  resources :summations, :except => [:show, :destroy] do
    collection do 
      post 'summate_month'
      post 'summate_month_report'
    end
  end

  resources :heat_process_prices, :except => [:show]

  resources :surface_process_prices, :except => [:show]

  resources :notices, :except => [:show]

  resources :calendars, :only => [:index] do
    collection do 
      get 'multi_import'
      post 'multi_import_update'
    end
  end

  #map.top       'top', :controller => :top, :action => :index
  #map.error     'error', :controller => :top, :action => :error

  root :to => 'auth#login', :via => [:get, :post]
  match '/top' => 'top#index', :as => :top, :via => [:get, :post]

  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  get '/error', :to => 'top#error', :as => :error

  get '/auth/logout', :to => 'auth#logout', :as => :logout

  resources :schedule do
    member do
      get 'data'
    end
  end
  resources :gantt do
    member do
      get 'data'
    end
  end
end
