require 'securerandom'
require 'logger'

require 'selenium-webdriver'


module MixpanelTesting

  class SeleniumProvider

    def initialize(selenium_url, capabilities = :firefox)
      @selenium_url = selenium_url
      @log = Logger.new(STDOUT)
      logs.info "Selenium initializer"
      if ![:chrome, :firefox].include? capabilities
        @caps = Selenium::WebDriver::Remote::Capabilities.new
        if capabilities['device'].nil?
          logs.info "Creating capabilities, desktop environment"
          # REQUIRED capabilities
          ['os', 'os_version', 'browser',
           'browser_version', 'resolution'].each { |key|
            @caps[key] = capabilities[key]
            puts @caps[key]
          }

          # NOT REQUIRED capabilities
          ['browserstack_local', 'browserstack_localIdentifier',
           'build', 'project', 'device', 'platform', 'browserName'].each { |key|
            @caps[key.gsub('_','.')] = capabilities[key] if !capabilities[key].nil?
          }
        else
          logs.info "Creating capabilities, mobile environment"
          @caps["device"] = capabilities['device']
          @caps[:platform] = capabilities['platform']
          @caps[:browserName] = capabilities['browserName']
          @caps['browserstack.local'] = capabilities['browserstack_local'] == true
        end
      else
        @caps = capabilities
      end

      @driver = nil
      @test_cases = []
      @wait = 2
      logs.info "Ready to connect"
    end

    def connect!
      @log.info "Connecting to selenium through #{@selenium_url}"
      @driver = Selenium::WebDriver.for(
        :remote,
        :url => @selenium_url,
        :desired_capabilities => @caps)

      @driver.manage.timeouts.implicit_wait = Settings.timeout
    end

    def start_session(site_url)
      @session_id = SecureRandom.uuid
      @session_timestamp = Time.now.getutc
      connect! if @driver.nil?
      @site_url = site_url

      @log.info "Start mixpanel session #{@session_id}"

      start_url = site_url.include?('?') ? "#{site_url}&" : "#{site_url}?"
      start_url = "#{start_url}mp_session_start=#{@session_id}"
      @driver.get start_url
      waitfor()
    end

    def navigate(url)
      @driver.get url.start_with?('http') ? url : "#{@site_url}#{url}"
      waitfor()
    end

    def end_session(site_url = nil)
      puts @site_url
      site_url = site_url.nil? ? @site_url : site_url
      end_url = site_url.include?('?') ? "#{site_url}&" : "#{site_url}?"
      end_url = "#{end_url}mp_session_end=#{@session_id}"
      @driver.get end_url
      waitfor()
    end

    def get_page_source
      @driver.page_source
    end

    def quit
      @log.info "Clossing selenium connection BYE!!"
      @driver.quit
    end

    def session_id
      @session_id
    end

    def driver
      @driver
    end

    def waitfor(n=false)
      # Use waitfor for correct mixpanel js loading and tracking
      wait = n ? n : @wait
      (1..wait).each {
        print "."
        sleep(1)
      }
      print "\r"
    end

    def waitfor_object_displayed(*selector)
      # Use this method to tell selenium to wait until one element is displayed
      # Arguments:
      #   selector:  is selenium find_element selector
      #            ex: waitfor_object_displayed(:class, 'cookies-eu-ok')
      @log.debug "Waiting for #{selector} to be displayed"
      return if @driver.find_element(*selector).displayed?
      wait = Selenium::WebDriver::Wait.new(:timeout =>  Settings.timeout)
      wait.until { !@driver.find_element(*selector).displayed? }
    end

    def click(selector)
      # Click in the object given by selector. It should be visible in the
      # browser area.
      @log.debug "Clicking at #{selector}"
      link = @driver.find_element(selector)
      @driver.execute_script("arguments[0].scrollIntoView(true);", link)
      link = @driver.find_element(selector)
      link.click
      waitfor()
    end
  end
end
