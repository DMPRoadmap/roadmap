# frozen_string_literal: true

module Api
  module V0
    module Madmp
      # Security rules for API V0 MadmpSchema endpoints
      class MadmpSchemaPolicy < ApplicationPolicy
        attr_reader :user, :madmp_schema

        def show?
          true
        end
      end
    end
  end
end
