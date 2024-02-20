# frozen_string_literal: true

require 'net/http'

class PartnerController < ApplicationController
  # Route handler for GET request to '/session'.
  # This route demonstrates how to request for a Session Token
  def session
    # Finds the client by client_id from the environment variables
    client = Client.find_by(client_id: ENV['OYSTER_CLIENT_ID'])

    # If the client is not found, render an inline message and return
    render inline: 'Client not found' and return if client.nil?

    # Sends a POST request to the OysterHR API to create a new session
    response =
      Net::HTTP.post(
        URI('https://api.oysterhr.com/v0.1/embedded/sessions'),
        # Data required for POST request to generate new Session Token
        {
          userName: 'un',
          userEmail: 'u@e.com',
          companyName: 'cn',
          companyEmailDomain: 'c.com',
          companyTaxId: 'txid',
          userReference: 'ur',
          companyReference: 'cr',
          context: 'START_HIRE'
        }.to_json,
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{client.access_token}"
        }
      )
    body = JSON.parse(response.body)

    # Redirect to `.../embedded/transfer?token={generate_token}` after receiving new session token
    session_token = body['data']['token']
    redirect_to "https://app.oysterhr.com/embedded/transfer?token=#{session_token}",
                status: :moved_permanently,
                allow_other_host: true
  end
end
