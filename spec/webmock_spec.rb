RSpec.describe "Webmock integration" do
  it "works"

  # def stringify_diff_like_webmock(diff)
  #   # this is the way webmock stringifies the result, so I want to test that the
  #   # result looks good when passing through this code.
  #   StringIO.open("".dup) do |stream|
  #     PP.pp(diff, stream)
  #     stream.rewind
  #     stream.read
  #   end.to_s
  # end

  # def diff_to_string(...)
  #   result = diff(...)

  #   stringify_diff_like_webmock(result)
  # end


  # describe "what it looks like in webmock" do
  #   it "1" do
  #     stub_request(:post, "https://www.example.com")
  #       .with(body: {
  #         test: "alpha",
  #         test2: 4532,
  #         test3: 54635,
  #       }.to_json)
  #       .to_return(status: 200, body: "YES IT WORKED!")

  #     response = HTTP.post(
  #       "https://www.example.com",
  #       headers: {
  #         "content-type" => "application/json",
  #       },
  #       body: {
  #         test: "beta",
  #         test2: 4532,
  #         test3: 213,
  #       }.to_json,
  #     )

  #     expect(response.body).to eq("YES IT WORKED!")
  #   end
  # end
end
