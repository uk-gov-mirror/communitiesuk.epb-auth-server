# frozen_string_literal: true

describe "Acceptance: Deleting a client" do
  context "as an authorised client" do
    describe "deleting a client" do
      let(:client) { create_client }
      let(:token) { create_token scopes: %w[client:delete client:fetch] }
      let(:delete_response) do
        make_request token do
          delete "/api/client/#{client.id}"
        end
      end

      it "the client is deleted" do
        expect(delete_response.status).to eq 200

        fetch_response = make_request token do
          get "/api/client/#{client.id}"
        end

        expect(fetch_response.status).to eq 404
      end
    end
  end

  context "as an unauthenticated client" do
    describe "deleting a client" do
      let(:response) { delete "/api/client/test" }

      it "fails with an appropriate code" do
        expect(response.status).to eq 401
      end

      it "fails with an appropriate error message" do
        expect(response.body).to include "Auth::Errors::TokenMissing"
      end
    end
  end

  context "as an unauthorised client" do
    describe "deleting a client" do
      let(:token) { create_token }
      let(:response) do
        make_request token do
          delete "/api/client/test"
        end
      end

      it "fails with an appropriate code" do
        expect(response.status).to eq 403
      end

      it "fails with an appropriate error message" do
        expect(response.get([:errors, 0, :code])).to eq "InsufficientPrivileges"
      end
    end
  end
end
