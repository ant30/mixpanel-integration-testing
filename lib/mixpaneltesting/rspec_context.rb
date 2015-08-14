require 'rspec'
require 'rspec/expectations'


RSpec.configure do |config|

  [
    :mixpanelsettings,
    :mixpanelfilesettings,
    :docker,
    :selenium,
    :mixpanel,
    :localsite,
    :appurl
  ].each do |item|
    config.add_setting item
  end

  config.before(:suite) do
    # Crazy yaml/erb/file reader
    log = Logger.new(STDOUT)
    settings = MixpanelTesting::Settings.load_settings(
      RSpec.configuration.mixpanelfilesettings
    )

    if settings['execute_mode'] == 'docker'
      docker = MixpanelTesting::DockerProvider.new(
        settings['docker']['browser'],
        settings['docker']['selenium_version'] || '2.46.0',
        settings['docker']['debug'] || false
      )
      docker.start
    end

    appurl = settings['app']['url']
    log.info "LOCAL URL #{appurl}"
    if settings['app']['run_local']
      localsite = MixpanelTesting::LocalSiteProvider.new(
        settings['app']['run_local'], appurl)
      localsite.start
      log.info "site started"
    end

    RSpec.configuration.mixpanelsettings = settings
    RSpec.configuration.docker = docker
    RSpec.configuration.localsite = localsite
    RSpec.configuration.appurl = appurl
  end

  config.before(:example) do
    puts "selenium connection"
    if RSpec.configuration.docker
      selenium_browser = (
        RSpec.configuration.mixpanelsettings['docker']['browser'] == 'firefox' ?
        :firefox : :chrome
      )
      selenium = MixpanelTesting::SeleniumProvider.new(
        RSpec.configuration.docker.selenium_uri, selenium_browser
        )
    else
      selector = (RSpec.configuration.mixpanelsettings['execute_mode'] ==
                      'browserstack' ?
                  'browserstack' : 'selenium')
      selenium_settings = RSpec.configuration.mixpanelsettings[selector]
      puts selenium_settings
      selenium = MixpanelTesting::SeleniumProvider.new(
        selenium_settings['selenium_uri'],
        selenium_settings['capabilities'])
    end

    selenium.connect!
    selenium.start_session RSpec.configuration.appurl
    mixpanel = MixpanelTesting::MixpanelProvider.new selenium.session_id

    RSpec.configuration.selenium = selenium
    RSpec.configuration.mixpanel = mixpanel
  end

  config.after(:example) do
    # We don't need this using selenium session cache per example
    # RSpec.configuration.selenium.end_session
    RSpec.configuration.selenium.quit
  end

  config.after(:suite) do
    RSpec.configuration.docker.kill if !RSpec.configuration.docker.nil?
    RSpec.configuration.localsite.kill if !RSpec.configuration.localsite.nil?
  end

end

RSpec.shared_context "mixpaneltesting" do
  before(:each) do
    @log = Logger.new(STDOUT)
    @selenium = RSpec.configuration.selenium
    @docker = RSpec.configuration.docker
    @localsite = RSpec.configuration.localsite
    @appurl = RSpec.configuration.appurl
    @mixpanel = RSpec.configuration.mixpanel
    @mixpanelsettings = RSpec.configuration.mixpanelsettings
  end
end
