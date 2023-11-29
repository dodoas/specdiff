require "webmock"
require "specdiff"
require "specdiff/webmock"

Specdiff.load!(:json)

include WebMock::API

WebMock.enable!
WebMock.show_body_diff! # on by default

stub_request(:post, "https://www.example.com")
  .with(
    body: JSON.generate({
      my_hash: "is great",
      the_hash: "is amazing",
    })
  )
  .to_return(status: 400, body: "hello")

begin
  HTTP.post(
    "https://www.example.com",
    body: JSON.generate({
      i_had_to_go: "and post a different hash",
      my_hash: "is different",
    }),
  )
rescue WebMock::NetConnectNotAllowedError => e
  puts "success! webmock stopped the request"
  puts "here is the error text:\n\n"

  puts e.message
  exit 0
end

puts "nothing was raised??"
