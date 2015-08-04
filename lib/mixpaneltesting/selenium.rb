require 'securerandom'
require 'selenium-webdriver'


module MixpanelTesting

  class SeleniumProvider

    def initialize(selenium_url, capabilities = :chrome)
      @selenium_url = selenium_url
      if capabilities != :chrome
        @caps = Selenium::WebDriver::Remote::Capabilities.new
        @caps.merge! capabilities
      else
        @caps = :chrome
      end

      @driver = nil
      @test_cases = []
      @wait = 2
    end

    def connect!
      puts @selenium_url
      @driver = Selenium::WebDriver.for(
        :remote,
        :url => @selenium_url,
        :desired_capabilities => @caps)

      @driver.manage.timeouts.implicit_wait = 20 # Seconds
    end

    def start_session(site_url)
      @session_id = SecureRandom.uuid
      @session_timestamp = Time.now.getutc
      connect! if @driver.nil?
      @site_url = site_url


      start_url = @site_url.include?('?') ? "#{site_url}&" : "#{site_url}?"
      start_url = "#{start_url}mp_session_start=#{@session_id}"
      @driver.get start_url
      waitfor()

    end

    def end_session(site_url = nil)
      site_url = site_url.nil? ? @site_url : site_url
      end_url = site_url.include?('?') ? "#{site_url}&" : "#{site_url}?"
      end_url = "#{end_url}mp_session_end=#{@session_id}"
      @driver.get end_url
      waitfor(2)
    end

    def quit
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

  end
end
