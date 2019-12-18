# frozen_string_literal: true

require 'base64'
require 'sinatra/activerecord'
require 'uuid'

class Client
  attr_reader :client_id

  class Client < ActiveRecord::Base
    validates_presence_of :name, :secret
  end

  def initialize(client_name, client_id)
    @client_name = client_name
    @client_id = client_id
  end

  def self.resolve_from_request(env, params)
    client_id, client_secret = get_credentials_from_request env, params

    return nil if UUID.validate(client_id).nil?

    client = self::Client.find(client_id)

    new client[:name], client[:id] if client[:secret] == client_secret
  rescue ActiveRecordError::RecordNotFound
    nil
  end

  def self.get_credentials_from_request(env, params)
    auth_token = env.fetch('HTTP_AUTHORIZATION', '')

    if auth_token.include? 'Basic'
      auth_token = auth_token.slice(6..-1)

      auth_token = Base64.decode64(auth_token)

      return auth_token.split(':')
    end

    [params[:client_id], params[:client_secret]]
  end
end
