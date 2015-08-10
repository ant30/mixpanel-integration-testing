require 'mixpaneltesting/version'
require 'mixpaneltesting/selenium'
require 'mixpaneltesting/mixpanel'
require 'mixpaneltesting/docker'
require 'mixpaneltesting/localsite'

module MixpanelTesting

  class MixpanelTesting

    def self.version
      puts MixpanelTesting::VERSION
    end

  end

end
