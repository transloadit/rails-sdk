Rails.application.routes.draw do
  RailsExample::Application.routes.draw do
    resources :uploads
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
