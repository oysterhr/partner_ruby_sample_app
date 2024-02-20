# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'auth/callback', to: 'api_auth#callback'
  get 'auth/refresh_token', to: 'api_auth#refresh_token'
  get 'partner/session', to: 'partner#session'

  root 'root#index'
end
