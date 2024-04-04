raise "webmock must be required before specdiff/webmock" unless defined?(WebMock)

module WebMock
  class RequestBodyDiff
    def initialize(request_signature, request_stub)
      @request_signature = request_signature
      @request_stub      = request_stub
    end

    PrettyPrintableThingy = Struct.new(:specdiff) do
      # webmock does not print the diff if it responds true to this.
      def empty?
        specdiff.empty?
      end

      # webmock prints the diff by passing us to PP.pp, which in turn uses this
      # method.
      def pretty_print(pp)
        pp.text("\r") # remove a space that isn't supposed to be there
        pp.text(specdiff.to_s)
      end
    end

    def body_diff
      specdiff = Specdiff.diff(request_stub_body, request_signature.body)
      PrettyPrintableThingy.new(specdiff)
    end

    attr_reader :request_signature, :request_stub
    private :request_signature, :request_stub

    private

    def request_stub_body
      request_stub.request_pattern &&
        request_stub.request_pattern.body_pattern &&
        request_stub.request_pattern.body_pattern.pattern
    end
  end
end

# marker for successfully loading this integration
class Specdiff::WebmockIntegration; end # rubocop: disable Lint/EmptyClass
