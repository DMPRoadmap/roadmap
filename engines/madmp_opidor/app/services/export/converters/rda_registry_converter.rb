# frozen_string_literal: true

module Export
  module Converters
    # Service used to convert registry values from Standard Format
    # to RDA DMP Commons Standars Format
    class RdaRegistryConverter
      class << self
        def convert_agent_id_system(val, is_person: false)
          return nil if val.nil?

          if is_person # personStandard only support 'ISNI' & 'ORCID' as a AgentIDSystem value
            case val.downcase
            when 'isni'
              'isni'
            when 'orcid id', 'orcid'
              'orcid'
            else
              'other'
            end
          else # Funder only support 'ISNI' & 'ORCID' as a AgentIDSystem value
            case val.downcase
            when 'crossref funder id'
              'fundref'
            when 'url'
              val.downcase
            else
              'other'
            end
          end
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def convert_bytes(val, unit)
          return nil if val.nil?
          return val if unit.nil?

          case unit.downcase
          when 'kb', 'ko'
            val * 1000
          when 'mb', 'mo'
            val * (1000**2)
          when 'gb', 'go'
            val * (1000**3)
          when 'tb', 'to'
            val * (1000**4)
          when 'pb', 'po'
            val * (1000**5)
          else
            val
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def convert_certification(val)
          return nil if val.blank?

          case val.first.downcase
          when 'dsa', 'wds', 'coretrustseal'
            val.first.downcase
          else
            ''
          end
        end

        def convert_date_to_iso8601(val)
          Date.parse(val).strftime('%Y-%m-%dT%H:%M:%S')
        rescue ArgumentError
          nil
        end

        def convert_data_access(val)
          return nil if val.nil?

          case val.downcase
          when 'ouvert', 'open'
            'open'
          when 'restreint', 'restricted'
            'shared'
          else
            'closed'
          end
        end

        def convert_funding_status(val)
          return nil if val.nil?

          case val.downcase
          when 'planifié', 'planned'
            'planned'
          when 'soumis', 'applied'
            'applied'
          when 'approuvé', 'granted'
            'granted'
          else
            'rejected'
          end
        end

        def convert_pid_system(val, is_metadata_standard: false)
          return nil if val.nil?

          if is_metadata_standard # MetadataStandard only support 'URL' as a PIDSysteù value
            val.casecmp('url').zero? ? 'url' : 'other'
          else
            case val.downcase
            when 'handle', 'doi', 'url', 'ark', 'igsn'
              val.downcase
            else
              'other'
            end
          end
        end

        def convert_yes_no(val)
          return nil if val.nil?

          case val.downcase
          when 'oui', 'yes'
            'yes'
          when 'non', 'no'
            'no'
          else
            'unknown'
          end
        end
      end
    end
  end
end
