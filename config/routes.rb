ActionController::Routing::Routes.draw do |map|
  map.resources :participations

  map.resources :places

  # Open trips
  map.resources :trips
  map.connect 'trip/:trip_id/:action', :controller => :participations, :action => [:join]


  Clearance::Routes.draw(map)
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  map.root :controller => :profiles

  # nested resources
  map.resources :profiles 
  map.resources :users,:only  =>[:new , :show, :index, :edit ]  do |users|
    users.resources :profiles, :only =>[:new , :show, :index, :edit ]
  # trips associated with user
    users.resources :trips, :only =>[:new , :show, :index, :edit ] do |trip|
      trip.resource :participations, :only => [:new, :show, :index, :edit ]
    end
  end

  map.resources :tags do |tag|
    tag.resources :tags
  end


  map.resources :locations,:only => [:show, :index] 
  map.connect 'locations/:geonameid', :controller => :locations, :action => [:show]
  map.connect 'locations/:action/:geonameid', :controller => :locations, :action => [:show, :index]
  map.connect 'locations/:action/:geonameid.:format', :controller => :locations, :action => [:show, :index]

  map.resources :features
  map.connect 'features/:action/:class.:code', :controller => :features, :action => [:show, :index]
  map.connect 'features/:action/:class.:code.:format', :controller => :features, :action => [:show, :index]

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  
  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
