RSpec.describe "json plugin" do
  def diff(...) = Specdiff.diff(...)

  before(:all) do
    Specdiff.load!(:json)
  end

  after(:all) do
    Specdiff._clear_plugins!
  end

  it "diffs json as hashes" do
    json1 = {
      key1: 435,
      key2: "yes",
      key3: "bongo452",
      key4: 4395.324,
      key5: "present!",
    }.to_json
    json2 = {
      key1: 453,
      key2: 342,
      key3: "video",
      key4: 4395.324,
      key5: nil,
    }.to_json

    result = diff(json1, json2)

    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq(<<~DIFF)
      @@ +0/-0/~4 @@
        new value: "key1" (435 -> 453)
        new value: "key2" ("yes" -> 342)
        new value: "key3" ("bongo452" -> "video")
        new value: "key5" ("present!" -> nil)
    DIFF
    expect(result.types).to eq([:hash, :hash])
  end

  it "diffs json where key names change" do
    json1 = {
      confused: true,
      intellectual: true,
      mixture: true,
      seemingly: true,
      unintelligible: true,
    }.to_json
    json2 = {
      confusinated: true,
      intellectual: true,
      mixd: true,
      seems: true,
      unintelligibleh: true,
    }.to_json

    result = diff(json1, json2)

    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq(<<~DIFF)
       @@ -1,8 +1,8 @@
        {
       -  "confused" => true,
       +  "confusinated" => true,
          "intellectual" => true,
       -  "mixture" => true,
       -  "seemingly" => true,
       -  "unintelligible" => true,
       +  "mixd" => true,
       +  "seems" => true,
       +  "unintelligibleh" => true,
        }
    DIFF
    expect(result.types).to eq([:text, :text])
  end

  it "diffs json strings" do
    json1 = '"test\njson\nstring"'
    json2 = '"test\njson\nstirng"'

    result = diff(json1, json2)

    expect(result.types).to eq([:text, :text])
    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq(<<~DIFF)
       @@ -1,4 +1,4 @@
        test
        json
       -string
       +stirng
    DIFF
  end

  it "does not diff a json against a json null" do
    json1 = "null"
    json2 = {status: "haha"}.to_json

    result = diff(json1, json2)

    expect(result.types).to eq([:nil, :hash])
    expect(result.empty?).to eq(true)
    expect(result.to_s).to eq("nil != {\"status\"=>\"haha\"}")
  end

  it "diffs json arrays" do
    json1 = JSON.generate([1, 2, 3, "4"])
    json2 = JSON.generate([{}, 2, "3", "4", []])

    result = diff(json1, json2)

    expect(result.types).to eq([:array, :array])
    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq(<<~DIFF)
      @@ +1/-0/~2 @@
        extra key: [4] ([])
        new value: [0] (1 -> {})
        new value: [2] (3 -> "3")
    DIFF
  end

  it "diffs json and a hash" do
    json = JSON.generate({
      this: "is",
      my_hash: "my hash",
      is: "amazing",
    })
    hash = {
      "this" => "isn't",
      "my_hash" => "my (not) hash",
      "is" => "amazing",
    }

    result1 = diff(json, hash)

    expect(result1.types).to eq([:hash, :hash])
    expect(result1.empty?).to eq(false)
    expect(result1.to_s).to eq(<<~DIFF)
      @@ +0/-0/~2 @@
        new value: "my_hash" ("my hash" -> "my (not) hash")
        new value: "this" ("is" -> "isn't")
    DIFF

    result2 = diff(hash, json)

    expect(result2.types).to eq([:hash, :hash])
    expect(result2.empty?).to eq(false)
    expect(result2.to_s).to eq(<<~DIFF)
      @@ +0/-0/~2 @@
        new value: "my_hash" ("my (not) hash" -> "my hash")
        new value: "this" ("isn't" -> "is")
    DIFF
  end

  it "produces an empty diff from hashes" do
    json1 = JSON.generate({
      this: "hash",
      exists: true,
      number: 345,
    })
    json2 = json1.dup

    result = diff(json1, json2)

    expect(result.empty?).to eq(true)
    expect(result.to_s).to eq("")
  end

  it "produces an empty diff from arrays" do
    json1 = JSON.generate([4, 45, "342", "test", 213])
    json2 = json1.dup

    result = diff(json1, json2)

    expect(result.empty?).to eq(true)
    expect(result.to_s).to eq("")
  end

  # I don't think we want this thing to infinitely recurse into json
  # structures to diff them.
  it "only parses jsons one level deep" do
    json1 = JSON.generate({x: "y"})
    json2 = JSON.generate({l: json1})
    json3 = JSON.generate({o: json2})
    json4 = JSON.generate({x: "z"})

    result = diff(json3, json4)
    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq(<<~DIFF)
      @@ -1,4 +1,4 @@
       {
      -  "o" => "{\\"l\\":\\"{\\\\\\"x\\\\\\":\\\\\\"y\\\\\\"}\\"}",
      +  "x" => "z",
       }
    DIFF
  end

  it "only parses json strings one level deep" do
    json1 = JSON.generate({x: "y"})
    json2 = "\"#{json1}\""
    json3 = "\"s\nl\nm\nba\""

    result = diff(json2, json3)
    expect(result.to_s).to eq(<<~DIFF)
      @@ -1,4 +1,7 @@
      -"{"x":"y"}"
      +"s
      +l
      +m
      +ba"
    DIFF
  end
end
