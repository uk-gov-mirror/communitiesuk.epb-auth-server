# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib/")
loader.inflector.inflect 'oauth_token_service' => 'OAuthTokenService'
loader.inflector.inflect 'oauth_token_test_service' => 'OAuthTokenTestService'

loader.setup

run Rack::URLMap.new(Router.generate_routes)
