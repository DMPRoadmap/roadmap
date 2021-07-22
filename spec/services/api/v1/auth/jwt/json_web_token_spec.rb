# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Auth::Jwt::JsonWebToken do

  before(:each) do
    @payload = {
      "foo": Faker::Lorem.sentence,
      "bar": Faker::Number.number
    }
  end

  context "#encode(payload:, exp:)" do
    it "encodes the payload into a JWT" do
      token = described_class.encode(payload: @payload,
                                     exp: 2.hours.from_now)
      expect(token.is_a?(String)).to eql(true)
      expect(token.length > 1).to eql(true)
    end
    it "allows for a default expiration time" do
      token = described_class.encode(payload: @payload)
      expect(token.is_a?(String)).to eql(true)
      expect(token.length > 1).to eql(true)
    end
  end

  context "#decode(token:)" do
    before(:each) do
      @token = described_class.encode(payload: @payload)
    end

    it "decodes the token and returns the payload" do
      hash = described_class.decode(token: @token)
      expect(hash[:foo]).to eql(@payload[:foo])
      expect(hash[:bar]).to eql(@payload[:bar])
    end
    it "includes the expiration time" do
      hash = described_class.decode(token: @token)
      expect(hash[:exp]).to eql(@payload[:exp])
    end
    it "throws JWT::ExpiredSignature when a token has expired" do
      err = JWT::ExpiredSignature
      JWT.stubs(:decode).raises(err)
      expect { described_class.decode(token: @token) }.to raise_error(err)
    end
    it "returns nil when other JWT::DecodeError happens" do
      JWT.stubs(:decode).raises(JWT::VerificationError)
      expect(described_class.decode(token: @token)).to eql(nil)
    end
  end

end
