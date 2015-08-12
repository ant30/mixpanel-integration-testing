require 'logger'
require 'json'

require 'mixpanel_client'

module MixpanelTesting

  class MixpanelProvider

    def initialize(session_id)
      @log = Logger.new(STDOUT)
      @log.info "Login at Mixpanel: #{Settings.mixpanel_api_key}"
      @client = Mixpanel::Client.new(
        api_key: Settings.mixpanel_api_key,
        api_secret: Settings.mixpanel_api_secret
      )
      @today = Date.today.strftime("%Y-%m-%d")
      @yesterday = (Date.today - 1).strftime("%Y-%m-%d")
      @session_id = session_id
      puts ""
    end

    def validate_events(expected_results)
      # Arguments:
      #   expected_results: is a hash of event names (string) related with
      #   expected result
      # Return:
      #   true: if succesfull.
      #   false: if doesn't. Some info messages can go to stdout with this state.

      correct = false

      (1..10).each {
        mixpanel_result = events_segmentation expected_results.keys

        result = expected_results.each { |event, expected_value|
          if expected_value != mixpanel_result[event]
            @log.info "\"#{event}\": expected value #{expected_value} received #{mixpanel_result[event]}"
            break
          end
        }
        correct = !result.nil?

        break if correct
        puts "Retrying mixpanel queries in two seconds"
        sleep(3)
      }

      correct
    end

    def validate_complex_query(event, extra_query, expected)
      # Arguments:
      #   event: The event name to use in the query
      #   extra_query: String with params for mixpanel query.
      #   expected: The integer result to be expected
      # Return:
      #   true: if succesfull.
      #   false: if doesn't. Some info messages can go to stdout with this state.
      received = event_complex_query(event, extra_query)
      @log.info "\"#{event}\": expected value #{expected} received #{received}" unless received == expected
      received == expected
    end

    def events_segmentation(events)
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

    def event_complex_query(event, extra_query)
      # Arguments:
      #   event: The event to validate dates.
      @log.debug "Request to mixpanel: #{event}"
      response = @client.request(
        'segmentation',
        event: event,
        type: 'general',
        unit: 'day',
        from_date: @yesterday,
        to_date: @today,
        where: "properties[\"mp_session_id\"] == \"#{@session_id}\" and (#{extra_query})"
      )
      @log.debug JSON.pretty_generate(response)
      response['data']['values'][event][@today]
    end
  end
end
