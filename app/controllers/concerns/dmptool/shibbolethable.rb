# frozen_string_literal: true

module Dmptool
  # DMPTool specific helpers that ensure we bypass the standard Shibboleth federated
  # discovery service and instead send the user directly to their institution's IdP
  # using the Shibbeoleth entityID stored in the identifiers table for the Org
  module Shibbolethable

  end
end
