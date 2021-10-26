class CleverTap
  class Response
    attr_accessor :response, :success, :failures

    def initialize(response)
      begin
        @response = JSON.parse(response.body)
      rescue JSON::ParserError, TypeError => e
        @response = { non_json_resp: response.body }
      end
      process_response
    end

    private

    def process_response
      return process_success if response['status'] == 'success'
      @success = false
      @failures = [response]
    end

    def process_success
      if response['unprocessed'].to_a.empty?
        @success = true
        @failures = []
      else
        @success = false
        @failures = response['unprocessed']
      end
    end
  end
end
