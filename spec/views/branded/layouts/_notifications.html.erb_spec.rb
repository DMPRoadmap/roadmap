# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_notifications.html.erb' do
  before(:each) do
    controller.prepend_view_path 'app/views/branded'
  end

  context 'flash notifications' do
    it 'renders correctly when there is no flash[:alert] or flash[:notice]' do
      render
      expect(rendered.include?('class="c-notificationgroup"')).to eql(true)
      expect(rendered.include?('class="c-notification--info"')).to eql(false)
      expect(rendered.include?('class="c-notification--warning"')).to eql(false)
      expect(rendered.include?('class="c-notification--danger"')).to eql(false)
      expect(rendered.include?('class="c-notification__close"')).to eql(false)
    end

    it 'renders correctly when there is a flash[:notice]' do
      flash[:notice] = Faker::Lorem.sentence
      render
      expect(rendered.include?('class="c-notificationgroup"')).to eql(true)
      expect(rendered.include?('class="c-notification--info"')).to eql(true)
      expect(rendered.include?('class="c-notification--warning"')).to eql(false)
      expect(rendered.include?('class="c-notification--danger"')).to eql(false)
      expect(rendered.include?('class="c-notification__close"')).to eql(true)
    end

    it 'renders correctly when there is an flash[:alert]' do
      flash[:alert] = Faker::Lorem.sentence
      render
      expect(rendered.include?('class="c-notificationgroup"')).to eql(true)
      expect(rendered.include?('class="c-notification--info"')).to eql(false)
      expect(rendered.include?('class="c-notification--warning"')).to eql(false)
      expect(rendered.include?('class="c-notification--danger"')).to eql(true)
      expect(rendered.include?('class="c-notification__close"')).to eql(true)
    end

    it 'renders correctly when there is an active Notification' do
      notification = create(:notification, dismissable: false, enabled: true)
      render
      expect(rendered.include?('class="c-notificationgroup"')).to eql(true)
      expect(rendered.include?('class="c-notification--info"')).to eql(false)
      expect(rendered.include?('class="c-notification--warning"')).to eql(true)
      expect(rendered.include?('class="c-notification--danger"')).to eql(false)
      expect(rendered.include?('class="c-notification__close"')).to eql(true)
    end
  end
end
