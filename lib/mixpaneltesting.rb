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

end
