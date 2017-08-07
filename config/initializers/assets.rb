# Be sure to restart your server when you modify this file.

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

    Rails.application.config.assets.version = '1.0'
    Rails.application.config.assets.unknown_asset_fallback = false  # An error will be raised when an asset cannot be found
    Rails.application.config.assets.paths << Rails.root.join("vendor","node_modules")
    Rails.application.config.assets.paths << Rails.root.join("app", "assets", "images")
    Rails.application.config.assets.paths << Rails.root.join("app", "assets", "videos")
    Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *ico)
    Rails.application.config.assets.precompile += %w(*mp4 *webm *ogg *ogv *swf)
    Rails.application.config.assets.precompile += %w(admin.js)  # TODO, remove when file is refactored into the adequate view or views
    Rails.application.config.assets.precompile += %w(dmproadmap.js) # TODO, remove when file is refactored into the adequate view or views
    Rails.application.config.assets.precompile += %w(views/answers/status.js
                                   views/contacts/new_contact.js
                                   views/devise/passwords/new.js
                                   views/devise/registrations/edit.js
                                   views/contacts/new_contact.js
                                   views/guidances/admin_edit.js
                                   views/home/index.js
                                   views/notes/index.js
                                   views/orgs/admin_edit.js
                                   views/orgs/shibboleth_ds.js
                                   views/plans/export_configure.js
                                   views/plans/index.js 
                                   views/plans/new.js 
                                   views/plans/share.js
                                   views/plans/show.js 
                                   views/shared/login_form.js
                                   views/shared/register_form.js
                                   views/static_pages/utils.js)
                             
    

    