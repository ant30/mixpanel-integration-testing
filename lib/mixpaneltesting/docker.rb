require 'docker'
require 'excon'
require 'uri'


module MixpanelTesting

  class DockerProviderBrowserNotAvailable < StandardError
  end

  class DockerProvider

    def initialize(browser, version=nil, debug=false)
      if !['firefox', 'chrome'].include?(browser)
        raise DockerProviderBrowserNotAvailable, "#{browser} not available"
      end

      @log = Logger.new(STDOUT)
      @docker_uri = URI(ENV['DOCKER_HOST'])
      @browser = browser
      @debug = debug
      @version = version.nil? ? "" : ":#{version}"
      @image_name = (@debug ?
                      "selenium/standalone-#{@browser}-debug#{@version}" :
                      "selenium/standalone-#{@browser}#{@version}")

      @threads = []

      @log.info ["Creating selenium docker, if you don't see Docker started",
                 "message, try to remove mixpaneltesting docker with:",
                 "docker rm -rf mixpaneltesting"].join('/n')
      # This settings is fully wired for boot2docker/docker-machines
      # We should change this to make compatible with other
      @container = Docker::Container.create(
        'Image' => @image_name,
        'name' => 'mixpaneltesting',  # Name given for helping with debug
        'ExposedPorts' => {
          '4444/tcp' => {},
          '5900/tcp' => {},
        },
        'HostConfig' => {
          'PortBindings' => {
            '4444/tcp' => [{ 'HostPort' => '4444'}], # Selenium Port
            '5900/tcp' => [{ 'HostPort' => '5900'}], # VNC Port for everyone
          }
        },
        "OomKillDisable": false,
      )

    end

    def start
      @container.start

      (1..Settings.timeout).each { |i|
        sleep 1
        @log.info "Waiting to docker ready: #{i}"
        break if ready?
      }
      @log.info "Docker started"

      open_vnc if @debug
    end

    def kill
      @container.kill!
      @container.delete(:force => true)

      @threads.each { |thr|
        @log.info "Killing thread"
        thr.exit
      }
    end

    def ready?
      puts selenium_uri
      Excon.get(selenium_uri).status == 302 rescue false
    end

    def selenium_uri
      "http://#{@docker_uri.host}:4444/wd/hub"
    end

    def vnc_uri
      "vnc://:secret@#{@docker_uri.host}:5900"
    end

    def open_vnc
      @threads.push Thread.new {
        `open #{vnc_uri}`
      }
    end

  end

end

