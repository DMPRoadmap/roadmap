# frozen_string_literal: true

json.partial! 'api/v3/standard_response'

if current_user.present?
  json.items [current_user] do |user|
    json.name [user.surname, user.firstname].join(', ')
    json.givenname user.firstname
    json.surname user.surname
    json.mbox user.email

    if user.org.present? && ['No funder', 'Non Partner Institution'].exclude?(user.org.name)
      json.affiliation do
        json.partial! 'api/v2/orgs/show', org: user.org
      end
    end

    orcid = user.identifier_for_scheme(scheme: 'orcid')
    if orcid.present?
      json.user_id do
        json.partial! 'api/v2/identifiers/show', identifier: orcid
      end
    end
  end

else
  json.items []
end
