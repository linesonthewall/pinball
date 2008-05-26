ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'static', :action => 'welcome'
  
  map.with_options(:controller => 'static', :conditions => { :method => :get }) do |m|
    m.connect 'docs/terms_of_service', :action => 'terms_of_service'
    m.connect 'docs/privacy_policy', :action => 'privacy_policy'
    m.connect 'docs/about_us', :action => 'about_us'
  end
  
  map.with_options(:controller => 'accounts') do |m|
    m.connect 'accounts/login', :action => 'login', :conditions => { :method => :get }
    m.connect 'accounts/login/password', :action => 'password_login', :conditions => { :method => :post }
    
    m.connect 'accounts/signup', :action => 'signup', :conditions => { :method => :get }
    m.connect 'accounts/signup/password', :action => 'password_signup', :conditions => { :method => :post }
    
    m.connect 'accounts/logout', :action => 'logout', :conditions => { :method => :get }
  end
  
  map.with_options(:controller => 'profiles') do |m|
    m.connect 'people/:profile_id', :action => 'show', :conditions => { :method => :get }
    
    m.connect 'people/:profile_id/edit', :action => 'edit', :conditions => { :method => :get }
    m.connect 'people/:profile_id/update', :action => 'update', :conditions => { :method => :post }
  end
  
  map.with_options(:controller => 'friends') do |m|
    m.connect 'people/:profile_id/following', :action => 'following', :conditions => { :method => :get }
    m.connect 'people/:profile_id/following/tier/:tier', :action => 'following_by_tier', :conditions => { :method => :get }, :requirements => { :tier => /[123]/ }
    m.connect 'people/:profile_id/followers', :action => 'followers', :conditions => { :method => :get }
    m.connect 'people/:profile_id/friends', :action => 'friends', :conditions => { :method => :get }
    m.connect 'people/:profile_id/follow', :action => 'follow', :conditions => { :method => :post }
    m.connect 'people/:profile_id/unfollow', :action => 'unfollow', :conditions => { :method => :post }
    m.connect 'people/:profile_id/move_to_tier', :action => 'move_to_tier', :conditions => { :method => :post }
  end
end
