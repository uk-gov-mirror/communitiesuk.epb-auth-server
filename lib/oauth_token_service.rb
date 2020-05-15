# frozen_string_literal: true

class OAuthTokenService < BaseService
  post '' do
    content_type :json
    auth_token = env.fetch('HTTP_AUTHORIZATION', '')

    if auth_token.include? 'Basic'
      client_id, client_secret =
        Base64.decode64(auth_token.slice(6..-1)).split(':', 2)
    else
      client_id = params[:client_id]
      client_secret = params[:client_secret]
    end

    client =
      UseCase::GetClientFromIdAndSecret.new(Container.new).execute(
        client_id,
        client_secret
      )

    unless client
      halt 401, { error: 'Could not resolve client from request' }.to_json
    end

    token =
      Auth::Token.new(
        iss: ENV['JWT_ISSUER'],
        sub: client.id,
        iat: Time.now.to_i,
        scopes: client.scopes,
        sup: client.supplemental
      )

    status 200
    {
      access_token: token.encode(ENV['JWT_SECRET']),
      expires_in: 3_600,
      token_type: 'bearer'
    }.to_json
  end
end
