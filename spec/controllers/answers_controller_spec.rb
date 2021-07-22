# frozen_string_literal: true

require "rails_helper"

RSpec.describe AnswersController, type: :controller do

  include RolesHelper

  before(:each) do
    template = create(:template, phases: 1, sections: 1, questions: 1)
    @section = template.sections.first
    @plan = create(:plan, :creator, template: template)
    @user = @plan.owner

    ActionMailer::Base.deliveries = []
    @controller = described_class.new
    sign_in(@user)
  end

  after(:each) do
    ActionMailer::Base.deliveries = []
  end

  describe "POST /answers/create_or_update", js: true do
    context "standard question type (no question_options and not RDA metadata)" do
      before(:each) do
        @question = create(:question, :textarea, section: @section)
        @args = { text: Faker::Lorem.paragraph, user_id: @user.id,
                  question_id: @question.id, plan_id: @plan.id }
      end

      it "succeeds in creating" do
        post :create_or_update, params: { answer: @args }
        answer = Answer.all.last
        expect(answer.present?).to eql(true)
        expect(answer.question).to eql(@question)
        expect(answer.plan).to eql(@plan)
        expect(answer.user).to eql(@user)

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:plan].present?).to eql(true)
        expect(json[:plan][:progress]).to eql("")
        expect(json[:plan][:id]).to eql(@plan.id)
        expect(json[:question].present?).to eql(true)
        expect(json[:question][:answer_lock_version]).to eql(answer.lock_version)
        expect(json[:question][:answer_status]).to eql("")
        expect(json[:question][:form]).to eql("")
        expect(json[:question][:id]).to eql(@question.id)
        expect(json[:question][:locking]).to eql(nil)
        expect(json[:section_data].present?).to eql(true)
        expect(json[:qn_data].present?).to eql(true)
        # TODO: add validations on content of qn_data and section_data
      end
      it "succeeds in updating" do
        answer = create(:answer, plan: @plan, question: @question)
        @args[:lock_version] = answer.lock_version
        post :create_or_update, params: { answer: @args }
        answer.reload
        expect(answer.text).to eql(@args[:text])
        expect(answer.user).to eql(@user)

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:plan].present?).to eql(true)
        expect(json[:plan][:progress]).to eql("")
        expect(json[:plan][:id]).to eql(@plan.id)
        expect(json[:question].present?).to eql(true)
        expect(json[:question][:answer_lock_version]).to eql(answer.lock_version)
        expect(json[:question][:answer_status]).to eql("")
        expect(json[:question][:form]).to eql("")
        expect(json[:question][:id]).to eql(@question.id)
        expect(json[:question][:locking]).to eql(nil)
        expect(json[:section_data].present?).to eql(true)
        expect(json[:qn_data].present?).to eql(true)
      end
      it "fails" do
        Answer.any_instance.stubs(:present?).returns(false)
        post :create_or_update, params: { answer: @args }
        expect(response.body).to eql("")
      end
    end

    context "RDA metadata question type" do
      before(:each) do
        @question = create(:question, :rda_metadata, section: @section)
        @args = { text: Faker::Lorem.paragraph, standards: { foo: "bar" },
                  user_id: @user.id, question_id: @question.id, plan_id: @plan.id }
      end

      it "succeeds in creating" do
        post :create_or_update, params: { answer: @args }
        answer = Answer.all.last
        expect(answer.present?).to eql(true)
        expect(answer.question).to eql(@question)
        expect(answer.plan).to eql(@plan)
        expect(answer.user).to eql(@user)

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:plan].present?).to eql(true)
        expect(json[:plan][:progress]).to eql("")
        expect(json[:plan][:id]).to eql(@plan.id)
        expect(json[:question].present?).to eql(true)
        expect(json[:question][:answer_lock_version]).to eql(answer.lock_version)
        expect(json[:question][:answer_status]).to eql("")
        expect(json[:question][:form]).to eql("")
        expect(json[:question][:id]).to eql(@question.id)
        expect(json[:question][:locking]).to eql(nil)
        expect(json[:section_data].present?).to eql(true)
        expect(json[:qn_data].present?).to eql(true)
      end
      it "succeeds in updating" do
        answer = create(:answer, plan: @plan, question: @question)
        @args[:lock_version] = answer.lock_version
        post :create_or_update, params: { answer: @args }
        answer.reload
        json = JSON.parse(answer.text).with_indifferent_access
        expect(json[:standards]).to eql(@args[:standards].with_indifferent_access)
        expect(json[:text]).to eql(@args[:text])
        expect(answer.user).to eql(@user)

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:plan].present?).to eql(true)
        expect(json[:plan][:progress]).to eql("")
        expect(json[:plan][:id]).to eql(@plan.id)
        expect(json[:question].present?).to eql(true)
        expect(json[:question][:answer_lock_version]).to eql(answer.lock_version)
        expect(json[:question][:answer_status]).to eql("")
        expect(json[:question][:form]).to eql("")
        expect(json[:question][:id]).to eql(@question.id)
        expect(json[:question][:locking]).to eql(nil)
        expect(json[:section_data].present?).to eql(true)
        expect(json[:qn_data].present?).to eql(true)
      end
      it "fails" do
        Answer.any_instance.stubs(:present?).returns(false)
        post :create_or_update, params: { answer: @args }
        expect(response.body).to eql("")
      end
    end

    context "question with question_options" do
      before(:each) do
        @question = create(:question, :radiobuttons, section: @section, options: 2)
        @args = { text: Faker::Lorem.paragraph, user_id: @user.id,
                  question_id: @question.id, plan_id: @plan.id,
                  question_option_ids: [@question.question_options.first.id] }
      end

      it "succeeds in creating" do
        post :create_or_update, params: { answer: @args }
        answer = Answer.all.last
        expect(answer.present?).to eql(true)
        expect(answer.question).to eql(@question)
        expect(answer.plan).to eql(@plan)
        expect(answer.user).to eql(@user)

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:plan].present?).to eql(true)
        expect(json[:plan][:progress]).to eql("")
        expect(json[:plan][:id]).to eql(@plan.id)
        expect(json[:question].present?).to eql(true)
        expect(json[:question][:answer_lock_version]).to eql(answer.lock_version)
        expect(json[:question][:answer_status]).to eql("")
        expect(json[:question][:form]).to eql("")
        expect(json[:question][:id]).to eql(@question.id)
        expect(json[:question][:locking]).to eql(nil)
        expect(json[:section_data].present?).to eql(true)
        expect(json[:qn_data].present?).to eql(true)
      end
      it "succeeds in updating" do
        answer = create(:answer, plan: @plan, question: @question)
        @args[:lock_version] = answer.lock_version
        post :create_or_update, params: { answer: @args }
        answer.reload
        expect(answer.text).to eql(@args[:text])
        expect(answer.question_options.length).to eql(1)
        expect(answer.question_options.first.id).to eql(@args[:question_option_ids].first)
        expect(answer.user).to eql(@user)

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:plan].present?).to eql(true)
        expect(json[:plan][:progress]).to eql("")
        expect(json[:plan][:id]).to eql(@plan.id)
        expect(json[:question].present?).to eql(true)
        expect(json[:question][:answer_lock_version]).to eql(answer.lock_version)
        expect(json[:question][:answer_status]).to eql("")
        expect(json[:question][:form]).to eql("")
        expect(json[:question][:id]).to eql(@question.id)
        expect(json[:question][:locking]).to eql(nil)
        expect(json[:section_data].present?).to eql(true)
        expect(json[:qn_data].present?).to eql(true)
      end
      it "fails" do
        Answer.any_instance.stubs(:present?).returns(false)
        post :create_or_update, params: { answer: @args }
        expect(response.body).to eql("")
      end
    end

    it "fails due to Plan not found" do
      @question = create(:question, :textarea, section: @section)
      @args = { text: Faker::Lorem.paragraph, user_id: @user.id,
                question_id: @question.id }
      post :create_or_update, params: { answer: @args }
      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:msg].present?).to eql(true)
    end
  end

end
