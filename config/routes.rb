Blinder::Application.routes.draw do
  root 'collect#home'
  get  'review/:event_slug/proposal/:proposal_id' => 'review#detailed', as: :review
  get  'review/:event_slug' => 'review#list', as: :list
  post 'scrubs'  => 'control/proposals#scrub', as: :scrubs
  patch 'scrubs' => 'control/proposals#scrub', as: :scrub

  # omniauth provider callback for github auth
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete 'signout', to: 'sessions#destroy', as: 'signout'

  controller :collect do
    get    '/new', action: :new
    post   '/new', action: :create
    get    '/thanks', action: :thanks, as: :thanks_no
    get    '/edit', action: :edit
    patch  '/edit', action: :update

    get    ':event_slug', action: :home, as: :event
    get    ':event_slug/new', action: :new, as: :proposals
    get    'thanks/:slug', action: :thanks, as: :thanks
    get    'edit/:slug', action: :edit, as: :proposal
    post   ':event_slug/new', action: :create
    patch  'edit/:id', action: :update
  end

  resources :notes, only: [:create, :update]

  namespace :control do
    resources :events, only: [:index, :edit, :update], param: :slug do
      resources :proposals, except: [:create]
    end
  end
end
