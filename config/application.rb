require File.expand_path('../boot', __FILE__)
require 'rails/all'
require 'yaml'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module AI
  class Application < Rails::Application
    config.serve_static_files = true
    # onfig.eager_load_paths += ["#{Rails.root}/lib/Processing"]

    # FIXME it should not work lol
    # because i using ai-project-folder
    # TODO move ai-project folder (aka module) to the top level
    simulator_root = Rails.root.join('lib').join('Processing')
    simulator_libs_paths = ['GameObjects', 'Helpers', 'Simulator', 'World']

    simulator_libs_paths.each do |lib_path|
      config.autoload_paths << simulator_root.join(lib_path)
    end

    # to use own 404 page
    config.exceptions_app = self.routes
    # config.consider_all_requests_local = true

    #config.encoding = "utf-8"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # Do not swallow errors in after_commit/after_rollback callbacks.
  end
end