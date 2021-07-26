# frozen_string_literal: true

module Api

  module V1

    module Deserialization

      class Dataset

        class << self

          # Convert incoming JSON into a Dataset
          #    {
          #      "title": "Cerebral cortex imaging series",
          #      "personal_data": "unknown",
          #      "sensitive_data": "unknown",
          #      "dataset_id": {
          #        "type": "doi",
          #        "identifier": "https://doix.org/10.1234.123abc/y3"
          #      }
          #    },
          #      "distribution": [
          #        {
          #          "title": "PDF - Testing our maDMP JSON export",
          #          "data_access": "open",
          #          "download_url": "http://dmproadmap.org/plans/44247/export.pdf",
          #          "format": ["application/pdf"]
          #        }
          #      ]
          #    }
          def deserialize!(json: {})
            return nil unless json.present? && json[:title].present?

            # TODO: Implement once we have determined the Dataset model
            nil
          end

        end

      end

    end

  end

end
