require 'yaml'
require 'erb'

require 'mixpaneltesting/version'
require 'mixpaneltesting/selenium'
require 'mixpaneltesting/mixpanel'
require 'mixpaneltesting/docker'
require 'mixpaneltesting/localsite'
require 'mixpaneltesting/rspec_context'

module MixpanelTesting

  class MixpanelTesting

    def self.version
      puts MixpanelTesting::VERSION
    end

  end

  class Settings
    @@generic_timeout = 20
    @@generic_mixpanel_api_key = nil
    @@generic_mixpanel_api_secret = nil

    def self.timeout
      @@generic_timeout
    end

    def self.mixpanel_api_key
      @@generic_mixpanel_api_key
    end

    def self.mixpanel_api_secret
      @@generic_mixpanel_api_secret
    end


    def self.load_settings(file)

      settings = YAML.load(
        ERB.new(
          File.read(
            RSpec.configuration.mixpanelfilesettings
          )
        ).result
      )

      @@generic_mixpanel_api_key = settings['mixpanel']['api_key']
      @@generic_mixpanel_api_secret = settings['mixpanel']['api_secret']
      @@generic_timeout == settings['generic_timeout'] if
        settings['generic_timeout']

    return settings
    end
  end
end
