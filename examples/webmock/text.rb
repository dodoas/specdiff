require "webmock"
require "specdiff"
require "specdiff/webmock"

include WebMock::API

WebMock.enable!
WebMock.show_body_diff! # on by default

stub_request(:post, "https://www.example.com")
  .with(
    body: <<~TEXT1,
      <bookstore>
        <book category="COOKING">
          <title lang="en">Everyday Italian</title>
          <author>Giada De Laurentiis</author>
          <year>2005</year>
          <price>30.00</price>
        </book>
        <book category="CHILDREN">
          <title lang="en">Harry Potter</title>
          <author>J K. Rowling</author>
          <year>2005</year>
          <price>29.99</price>
        </book>
        <book category="WEB">
          <title lang="en">Learning XML</title>
          <author>Erik T. Ray</author>
          <year>2003</year>
          <price>39.95</price>
        </book>
      </bookstore>
    TEXT1
  )
  .to_return(status: 400, body: "hello")

begin
  HTTP.post(
    "https://www.example.com",
    body: <<~TEXT2,
      <bookstore>
        <book category="COOKING">
          <title lang="en">Everyday Italian</title>
          <author>Giada De Laurentiis</author>
          <year>2005</year>
          <price>50.00</price>
        </book>
        <book category="ECONOMICS">
          <title lang="en">Inflation</title>
          <author>The 1%</author>
          <year>2008</year>
          <price>999.99</price>
        </book>
        <book category="CHILDREN">
          <title lang="en">Harry Potter</title>
          <author>J K. Rowling</author>
          <year>2005</year>
          <price>39.99</price>
        </book>
        <book category="WEB">
          <title lang="en">Learning XML</title>
          <author>Erik T. Ray</author>
          <year>2003</year>
          <price>49.95</price>
        </book>
      </bookstore>
    TEXT2
  )
rescue WebMock::NetConnectNotAllowedError => e
  puts "success! webmock stopped the request"
  puts "here is the error text:\n\n"

  puts e.message
  exit 0
end

puts "nothing was raised??"
