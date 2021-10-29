class CleverTap
  class Response
    attr_accessor :response, :success, :failures

    def initialize(response)
      @response = response.success? ? JSON.parse(response.body) : extract_json_body(response)
      process_response
    end

    private

    def extract_json_body(response)
      return JSON.parse(response.body)
    rescue JSON::ParserError, TypeError
      return { resp_string: response.body.to_s }.to_json
    end

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
