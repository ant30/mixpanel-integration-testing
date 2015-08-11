require 'excon'


module MixpanelTesting

  class LocalSiteProvider

    def initialize(cmd, uri)
      @cmd = cmd
      @uri = uri
      @timeout = MixpanelTesting::Settings.timeout
      @log = Logger.new(STDOUT)
      @pid = nil
    end

    def start
      @pid = Process.spawn @cmd
      puts "Spawn #{@cmd} with pid #{@pid}"

      (1..@timeout).each { |i|
        sleep 1
        break if ready?
      }
      @log.info "Site should be available on #{@uri}"
    end

    def kill
      return nil if @pid.nil?
      @log.info "Killing subprocess with localsite"
      Process.kill('KILL', @pid)
    end

    def ready?
      !Excon.get(@uri).status.nil? rescue false
    end

  end

end

