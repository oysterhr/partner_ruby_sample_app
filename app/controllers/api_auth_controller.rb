# frozen_string_literal: true

require 'net/http'

class ApiAuthController < ApplicationController
  # Route to handle the callback after OAuth authorization
  def callback
    # Make a request to authenticate using the received authorization code
    response = make_auth_req(auth_data.merge(
                               grant_type: 'authorization_code',
                               code: params['code'],
                               redirect_uri: ENV['OYSTER_REDIRECT_URL']
                             ))
    body = JSON.parse(response.body)

    case response
    when Net::HTTPSuccess
      # Find or initialize a client with the given client_id
      client = Client.find_or_initialize_by(client_id: auth_data[:client_id])
      # Update the client's access and refresh tokens
      client.access_token = body['access_token']
      client.refresh_token = body['refresh_token']
      client.save

      # Redirect to the root URL upon successful token exchange
      redirect_to root_url
    else
      # Render the error response as JSON if failure
      render json: body
    end
  end

  # Action to refresh the access token using the refresh token
  def refresh_token
    # Find the client by the client_id
    client = Client.find_by(client_id: auth_data[:client_id])

    # Return an error if the client is not found
    render inline: 'Client not found' and return if client.nil?

    response = make_auth_req(auth_data.merge(
                               grant_type: 'refresh_token',
                               refresh_token: client.refresh_token
                             ))
    body = JSON.parse(response.body)

    case response
    when Net::HTTPSuccess
      # Update the client's access and refresh tokens
      client.access_token = body['access_token']
      client.refresh_token = body['refresh_token']
      client.save

      # Redirect to the root URL upon successful token refresh
      redirect_to root_url
    else
      render json: body
    end
  end

  private

  # Helper method to provide the authorization data required for the requests
  def auth_data
    {
      client_id: ENV['OYSTER_CLIENT_ID'],
      client_secret: ENV['OYSTER_CLIENT_SECRET'],
      authorization_url: ENV['OYSTER_AUTHORIZATION_URL']
    }
  end

  # Helper method to make the authorization request to the server
  def make_auth_req(data)
    Net::HTTP.post_form(
      URI('https://api.oysterhr.com/oauth2/token'),
      data
    )
  end
end
