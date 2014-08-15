Refinery::Core::Engine.routes.draw do

  # Frontend routes
  namespace :portfolio do
    root :to => "galleries#index"
    resources :galleries, :only => [:index, :show]
  end

  # Admin routes
  namespace :portfolio, :path => '' do
    namespace :admin, :path => 'refinery' do
      scope :path => 'portfolio' do
        resources :galleries, :except => :show do
          get :children, :on => :member
          post :update_positions, :on => :collection
          resources :items, :except => [:show] do
            collection do
              post :update_positions, :create_multiple, :multiply_description
              get :new_multiple, :sort_index
            end
          end
        end
        resources :items do
          post :update_positions, :on => :collection
        end
      end
    end
  end
end
