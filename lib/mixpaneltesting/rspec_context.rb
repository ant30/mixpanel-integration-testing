require 'rspec'
require 'rspec/expectations'


RSpec.configure do |config|


  [:docker, :selenium, :mixpanel, :localsite, :localurl].each do |item|
    config.add_setting item
  end

  config.before(:suite) do
    log = Logger.new(STDOUT)
    log.info "Starting docker, if you don't see started message, try to remove mixpaneltesting docker with docker rm -rf mixpaneltesting"

    docker = MixpanelTesting::DockerProvider.new('firefox', '2.46.0', true)
    docker.start
    (1..20).each { |i|
      sleep 1
      log.info "Waiting to docker ready: #{i}"
      break if docker.ready?
    }
    log.info "Docker started"

    docker.open_vnc

    localurl = ENV["LOCAL_URL"]

    localsite = MixpanelTesting::LocalSiteProvider.new('PORT=3000 ./start', localurl)
    localsite.start

    log.info "site started"
    RSpec.configuration.docker = docker
    RSpec.configuration.localsite = localsite
    RSpec.configuration.localurl = localurl
  end

  config.before(:example) do
    puts "selenium connection"
    selenium = MixpanelTesting::SeleniumProvider.new(RSpec.configuration.docker.selenium_uri, :firefox)
    selenium.connect!
    selenium.start_session RSpec.configuration.localurl
    mixpanel = MixpanelTesting::MixpanelProvider.new selenium.session_id

    RSpec.configuration.selenium = selenium
    RSpec.configuration.mixpanel = mixpanel
  end

  config.after(:example) do
    RSpec.configuration.selenium.end_session
    RSpec.configuration.selenium.quit
  end

  config.after(:suite) do
    RSpec.configuration.docker.kill
    RSpec.configuration.localsite.kill
  end

end

RSpec.shared_context "mixpaneltesting" do
  before(:each) do
    @log = Logger.new(STDOUT)
    @selenium = RSpec.configuration.selenium
    @docker = RSpec.configuration.docker
    @localsite = RSpec.configuration.localsite
    @localurl = RSpec.configuration.localurl
    @mixpanel = RSpec.configuration.mixpanel
  end
end
