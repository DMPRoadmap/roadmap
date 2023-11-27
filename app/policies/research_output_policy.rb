# frozen_string_literal: true

# Security policies for research outputs
class ResearchOutputPolicy < ApplicationPolicy
  attr_reader :user, :research_output

  def initialize(user, research_output)
    raise Pundit::NotAuthorizedError, _('must be logged in') unless user

    raise Pundit::NotAuthorizedError, _('are not authorized to view that plan') if research_output.blank?

    @user = user
    @research_output = research_output
    super
  end

  def index?
    @research_output.plan.readable_by?(@user.id)
  end

  def new?
    @research_output.plan.administerable_by?(@user.id)
  end

  def show?
    @research_output.plan.readable_by?(@user.id)
  end

  def edit?
    @research_output.plan.administerable_by?(@user.id)
  end

  def create?
    @research_output.plan.administerable_by?(@user.id)
  end

  def update?
    @research_output.plan.administerable_by?(@user.id)
  end

  def destroy?
    @research_output.plan.administerable_by?(@user.id)
  end

  def select_output_type?
    @research_output.plan.administerable_by?(@user.id)
  end

  def select_license?
    @research_output.plan.administerable_by?(@user.id)
  end

  def repository_search?
    @research_output.plan.administerable_by?(@user.id)
  end

  def metadata_standard_search?
    @research_output.plan.administerable_by?(@user.id)
  end
end
