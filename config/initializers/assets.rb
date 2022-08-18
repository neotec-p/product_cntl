# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.precompile += %w( scaffold.css )
Rails.application.config.assets.precompile += %w( jquery-ui-1.8.10.custom.css )
Rails.application.config.assets.precompile += %w( prototype.js )
Rails.application.config.assets.precompile += %w( jquery-1.4.4.min.js )
Rails.application.config.assets.precompile += %w( jquery-ui-1.8.10.custom.min.js )
Rails.application.config.assets.precompile += %w( jquery.ui.datepicker-ja.js )
Rails.application.config.assets.precompile += %w( scriptaculous.js )
Rails.application.config.assets.precompile += %w( import.css )
#Rails.application.config.assets.precompile += %w( dhtmlxgantt.css )
#Rails.application.config.assets.precompile += %w( dhtmlxgantt.js )
#Rails.application.config.assets.precompile += %w( locale/locale_jp.js )
Rails.application.config.assets.precompile += %w( dhtmlxscheduler.css )
Rails.application.config.assets.precompile += %w( dhtmlxscheduler.js )
Rails.application.config.assets.precompile += %w( dhtmlxscheduler/locale/locale_jp.js )
