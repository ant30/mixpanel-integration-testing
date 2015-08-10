require 'logger'
require 'json'

require 'mixpanel_client'

module MixpanelTesting

  class MixpanelProvider

    def initialize(session_id)
      @log = Logger.new(STDOUT)
      @log.info "Login at Mixpanel: #{ENV['MIXPANEL_API_KEY']}  #{ENV['MIXPANEL_API_SECRET']}"
      @client = Mixpanel::Client.new(
        api_key: ENV['MIXPANEL_API_KEY'],
        api_secret: ENV['MIXPANEL_API_SECRET'],
      )
      @today = Date.today.strftime("%Y-%m-%d")
      @yesterday = (Date.today - 1).strftime("%Y-%m-%d")
      @session_id = session_id
      puts ""
    end

    def segmentation(events)
      # Arguments:
      #   events: is a list of event names.
      @log.debug "Request to mixpanel: #{events}"
      Hash[events.map { |event|
        response = @client.request(
          'segmentation',
          event: event,
          type: 'general',
          unit: 'day',
          from_date: @yesterday,
          to_date: @today,
          where: "properties[\"mp_session_id\"] == \"#{@session_id}\""
        )
        @log.debug JSON.pretty_generate(response)
        [event, response['data']['values'][event][@today]]
      }]
    end

    def validate_results(expected_results)
      # Arguments:
      #   expected: is a hash of event names (string) related with expected
      #     result
      # Return:
      #   true: if succesfull.
      #   false: if doesn't. Some info messages can go to stdout with this state.


      correct = false


      (1..10).each {

        mixpanel_result = segmentation expected_results.keys

        result = expected_results.each { |event, expected_value|
          if expected_value != mixpanel_result[event]
            @log.info "\"#{event}\": expected value #{expected_value} received #{mixpanel_result[event]}"
            break
          end
        }
        correct = !result.nil?

        break if correct
        puts "Retrying mixpanel queries in two seconds"
        sleep(2)
      }

      correct
    end

  end
end
