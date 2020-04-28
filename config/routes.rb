TwoODunkbonds::Application.routes.draw do

  get "about/index"
  get "about/credits"
  get "about/rules"
  get "about/howitworks"
  get "about/faq"
  get "about/contact"
  get "about/why_set_a_goal"
  get "about/why_trade_dunkbonds"

  get "story/story1"
  get "story/story2"
  get "story/story3"
  get "story/story4"
  get "story/story5"
  get "story/story6"
  get "story/story7"
  get "story/storyend"
  get "story/kill_story_notice"
  
  get "outside/landing"

  get "home/index"


  authenticated :user do
    root :to => 'home#index', as: :authenticated_root
  end

  devise_for :users do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  
  resources :carts, :only => :show
  resources :orders, :except => [:edit, :update, :destroy]

  resources :goals do
    resources :accounts, :except => [:edit, :update] do
      resources :tradewizard, :only => [:new, :create] 
    end
    resources :posts
  end

  resources :accounts do
    resources :line_items       
  end 

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  namespace :admin do
    resources :users, :only => [:index, :show]
    resources :accounts, :only => [:index, :show]
  end

  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "outside#landing"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
