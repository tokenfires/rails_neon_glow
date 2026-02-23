Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
  get "tailwind", to: "pages#tailwind", as: :tailwind_kitchen_sink
  get "bootstrap", to: "pages#bootstrap", as: :bootstrap_kitchen_sink
end
