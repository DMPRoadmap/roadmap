# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_notifications.html.erb' do
  before do
    controller.prepend_view_path 'app/views/branded'
  end

  context 'flash notifications' do
    it 'renders correctly when there is no flash[:alert] or flash[:notice]' do
      render
      expect(rendered.include?('class="c-notificationgroup"')).to be(true)
      expect(rendered.include?('class="c-notification--info"')).to be(false)
      expect(rendered.include?('class="c-notification--warning"')).to be(false)
      expect(rendered.include?('class="c-notification--danger"')).to be(false)
    end

    it 'renders correctly when there is a flash[:notice]' do
      flash[:notice] = Faker::Lorem.sentence
      render
      expect(rendered.include?('class="c-notificationgroup"')).to be(true)
      expect(rendered.include?('class="c-notification--info"')).to be(true)
      expect(rendered.include?('class="c-notification--warning"')).to be(false)
      expect(rendered.include?('class="c-notification--danger"')).to be(false)
    end

    it 'renders correctly when there is an flash[:alert]' do
      flash[:alert] = Faker::Lorem.sentence
      render
      expect(rendered.include?('class="c-notificationgroup"')).to be(true)
      expect(rendered.include?('class="c-notification--info"')).to be(false)
      expect(rendered.include?('class="c-notification--warning"')).to be(false)
      expect(rendered.include?('class="c-notification--danger"')).to be(true)
    end

    it 'renders correctly when there is an active Notification' do
      create(:notification, :active, level: 'warning', dismissable: false)
      render
      expect(rendered.include?('class="c-notificationgroup"')).to be(true)
      expect(rendered.include?('class="c-notification--info"')).to be(false)
      expect(rendered.include?('class="c-notification--warning"')).to be(true)
      expect(rendered.include?('class="c-notification--danger"')).to be(false)
    end
  end
end
