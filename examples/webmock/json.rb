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
      data: {
        latitude: 200,
        longitude: 60,
        hourly: {
          time: ["2022-07-01T00:00", "2022-07-01T01:00", "2022-07-01T02:00"],
          temperature: [13, 12.7, 12.5],
        },
        hourly_units: {
          temperature: "°C",
        },
      },
    })
  )
  .to_return(status: 400, body: "hello")

begin
  HTTP.post(
    "https://www.example.com",
    headers: {"Content-Type" => "application/json"},
    body: JSON.generate({
      data: {
        latitude: 200,
        longitude: 60,
        generationtime_ms: 2.2342,
        hourly: {
          time: ["2022-07-01T01:00", "2022-07-01T02:00", "2022-07-01T03:00"],
          temperature: [12.7, 12.5, 12.3],
        },
        hourly_units: {
          temperature: "°F",
        },
      },
    }),
  )
rescue WebMock::NetConnectNotAllowedError => e
  puts "success! webmock stopped the request"
  puts "here is the error text:\n\n"

  puts e.message
  exit 0
end

puts "nothing was raised??"
