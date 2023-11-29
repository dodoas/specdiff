require "webmock"
require "specdiff"
require "specdiff/webmock"

include WebMock::API

WebMock.enable!
WebMock.show_body_diff! # on by default

stub_request(:post, "https://www.example.com")
  .with(
    body: <<~TEXT1,
      this is the expected body
      that you should send
      nothing less
      nothing more
    TEXT1
  )
  .to_return(status: 400, body: "hello")

begin
  HTTP.post(
    "https://www.example.com",
    body: <<~TEXT2,
      this is the unexpected body
      that i should not have sent
      nothing less
      nothing more
    TEXT2
  )
rescue WebMock::NetConnectNotAllowedError => e
  puts "success! webmock stopped the request"
  puts "here is the error text:\n\n"

  puts e.message
  exit 0
end

puts "nothing was raised??"
