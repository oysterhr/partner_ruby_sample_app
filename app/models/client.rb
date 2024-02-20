# frozen_string_literal: true

class Client < ApplicationRecord
  validates :client_id, uniqueness: true
end
