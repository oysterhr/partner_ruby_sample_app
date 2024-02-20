# frozen_string_literal: true

class RootController < ApplicationController
  def index
    # Set an instance variable to the authorization URL from the environment variables
    @authorization_url = ENV['OYSTER_AUTHORIZATION_URL']
    # Set an instance variable to check if a client exists with the given client_id from the environment variables
    @has_client = Client.find_by(client_id: ENV['OYSTER_CLIENT_ID'])
  end
end
