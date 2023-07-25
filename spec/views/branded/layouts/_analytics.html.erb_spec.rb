# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_analytics.html.erb' do
  before do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders nothing if not the Stage or Production environments' do
    Rails.env.stubs(:stage?).returns(false)
    Rails.env.stubs(:production?).returns(false)
    render
    expect(rendered).to eql("\n")
  end

  describe 'UserSnap' do
    it 'does not display if we are in Production' do
      Rails.env.stubs(:stage?).returns(false)
      Rails.env.stubs(:production?).returns(true)
      render
      expect(rendered.include?('window.onUsersnapCXLoad')).to be(false)
    end

    it 'does not display if no UserSnap key is defined' do
      Rails.env.stubs(:stage?).returns(true)
      Rails.env.stubs(:production?).returns(false)
      Rails.configuration.x.dmproadmap.usersnap_key = nil
      render
      expect(rendered.include?('window.onUsersnapCXLoad')).to be(false)
    end

    it 'displays if it is Stage and the UserSnap key is defined' do
      Rails.env.stubs(:stage?).returns(true)
      Rails.env.stubs(:production?).returns(false)
      Rails.configuration.x.dmproadmap.usersnap_key = SecureRandom.uuid
      render
      expect(rendered.include?('window.onUsersnapCXLoad')).to be(true)
    end
  end

  context 'Matomo' do
    describe 'Stage environment' do
      before do
        Rails.env.stubs(:stage?).returns(true)
        Rails.env.stubs(:production?).returns(false)
      end

      it 'does not display the Matomo Analytics script' do
        Rails.configuration.x.dmproadmap.enable_matomo = true
        render
        expect(rendered.include?('MatomoAnalytics')).to be(false)
      end
    end

    describe 'Production environment' do
      before do
        Rails.env.stubs(:stage?).returns(false)
        Rails.env.stubs(:production?).returns(true)
      end

      it 'does not display the Matomo Analytics script when not enabled' do
        Rails.configuration.x.dmproadmap.enable_matomo = false
        render
        expect(rendered.include?('MatomoAnalytics')).to be(false)
      end

      it 'includes the Matomo Analytics script when enabled' do
        Rails.configuration.x.dmproadmap.enable_matomo = true
        render
        expect(rendered.include?('MatomoAnalytics')).to be(true)
      end
    end
  end
end
