PresentationConverter::Application.routes.draw do
  resources :presentations, only: [:new, :show, :create] do
    collection do
      get 'test'
    end
  end

  mount Resque::Server.new, :at => "/resque"
end
