# frozen_string_literal: true

require "uc3-ssm"
require "logger"
require "anyway"
require "anyway/utils/deep_merge"

class SsmConfigLoader < Anyway::Loaders::Base

  @logger = Logger.new($stdout)

  # rubocop:disable Metrics/AbcSize
  def call(name:, **_opts)
    logger = Logger.new($stdout)
    ssm = Uc3Ssm::ConfigResolver.new
    parameters = ssm.parameters_for_path(path: name)
    config = {}
    # reverse processing order to ensure correct precidence based on ssm_root_path
    parameters.reverse_each do |param|
      # strip off ssm_root_path
      sub_path = name + param[:name].partition(name)[-1]
      new_hash = hashify_param_path({}, sub_path, param[:value])
      Anyway::Utils.deep_merge!(config, new_hash)
    end
    # require "pp"
    # pp config

    trace!(:ssm_parameter_store, ssm_root_path: ENV["SSM_ROOT_PATH"].to_s) do
      config[name].to_h || {}
    end

    config[name].to_h || {}
  rescue Uc3Ssm::ConfigResolverError => e
    logger.warn(e.message.to_s)
    {}
  rescue Aws::SSM::Errors::ServiceError => e
    logger.warn("Aws::SSM::Errors::#{e.code}: #{e.message}")
    {}
  end
  # rubocop:enable Metrics/AbcSize

  # convert elements of sub_path into hash keys recursively
  def hashify_param_path(new_hash, path, value)
    key, _x, sub_path = path.partition("/")
    new_hash[key] = sub_path.empty? ? value : hashify_param_path({}, sub_path, value)
    new_hash
  end

end
