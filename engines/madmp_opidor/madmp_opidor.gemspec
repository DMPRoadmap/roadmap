# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'madmp_opidor/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'madmp_opidor'
  spec.version     = MadmpOpidor::VERSION
  spec.authors     = ['Benjamin FAURE']
  spec.email       = ['benjamin.faure@inist.fr']
  spec.homepage    = 'https://github.com/OPIDoR/'
  spec.summary     = 'Machine Actionable DMP features for DMP OPIDoR'
  spec.description = 'This gem contains all the controllers/models/helpers used by the maDMP features of DMP OPIDoR'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
    spec.metadata['rubygems_mfa_required'] = 'true'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 7.0'

  spec.add_dependency 'pundit', '~> 2.2.0'

  spec.add_dependency 'jsonpath', '~> 1.1.0'

  # Activerecord-Import is a library for bulk inserting data using ActiveRecord.
  # (https://github.com/zdennis/activerecord-import)
  spec.add_dependency 'activerecord-import', '~> 1.4.0'
end
