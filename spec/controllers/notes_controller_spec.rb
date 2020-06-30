# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotesController, type: :controller do

  include RolesHelper

  before(:each) do
    @plan = build_plan(true, true, true)
    @user = @plan.owner
    @answer = @plan.answers.first
    @question = @answer.question
    Note.destroy_all

    ActionMailer::Base.deliveries = []
    @controller = described_class.new
    sign_in(@user)
  end

  after(:each) do
    ActionMailer::Base.deliveries = []
  end

  describe "POST /notes", js: true do
    before(:each) do
      @args = { text: Faker::Lorem.paragraph, user_id: @user.id,
                answer_id: @answer.id, plan_id: @plan.id, question_id: @question.id }
    end

    it "succeeds" do
      @controller.expects(:render_to_string).at_least(2)
      post :create, params: { note: @args }
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:notes].present?).to eql(true)
      expect(json[:title].present?).to eql(true)
      expect(json[:notes][:id]).to eql(@question.id.to_s)
      expect(json[:title][:id]).to eql(@question.id.to_s)
      note = Note.all.last
      expect(note.text).to eql(@args[:text])
      expect(note.user_id).to eql(@user.id)
      expect(note.answer_id).to eql(@answer.id)
      expect(note.archived).to eql(false)
    end
    it "fails" do
      Note.any_instance.stubs(:save).returns(false)
      post :create, params: { note: @args }
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:msg].present?).to eql(true)
    end
    it "raises a Pundit::NotAuthorizedError if not authorized" do
      Plan.any_instance.stubs(:readable_by?).returns(false)
      @controller.expects(:raise).at_least(1)
      post :create, params: { note: @args }
    end
    it "sends out emails" do
      commenter = create(:user)
      create(:role, :commenter, plan_id: @plan.id, user: commenter)
      sign_out(@user)
      sign_in(commenter)
      @controller.expects(:deliver_if).at_least(1)
      post :create, params: { note: @args }
    end
  end

  describe "PUT /notes/:id", js: true do
    before(:each) do
      @note = create(:note, user: @user, answer: @answer)
      @args = { text: Faker::Lorem.paragraph, user_id: @user.id, answer_id: @answer.id }
    end

    it "succeeds" do
      @controller.expects(:render_to_string).at_least(2)
      put :update, params: { id: @note.id, note: @args }
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:notes].present?).to eql(true)
      expect(json[:title].present?).to eql(true)
      expect(json[:notes][:id]).to eql(@question.id.to_s)
      expect(json[:title][:id]).to eql(@question.id.to_s)
      expect(@note.reload.text).to eql(@args[:text])
    end
    it "fails" do
      Note.any_instance.stubs(:update).returns(false)
      put :update, params: { id: @note.id, note: @args }
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:msg].present?).to eql(true)
    end
  end

  describe "PATCH /notes/:id/archive", js: true do
    before(:each) do
      @note = create(:note, user: @user, answer: @answer)
      @args = { archived_by: @user }
    end

    it "succeeds" do
      @controller.expects(:render_to_string).at_least(2)
      put :archive, params: { id: @note.id, note: @args }
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:notes].present?).to eql(true)
      expect(json[:title].present?).to eql(true)
      expect(json[:notes][:id]).to eql(@question.id.to_s)
      expect(json[:title][:id]).to eql(@question.id.to_s)
      expect(@note.reload.archived).to eql(true)
      expect(@note.reload.archived_by).to eql(@user.id)
    end
    it "fails" do
      Note.any_instance.stubs(:update).returns(false)
      put :archive, params: { id: @note.id, note: @args }
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:msg].present?).to eql(true)
    end
  end

end
