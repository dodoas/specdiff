RSpec.describe "optional included json differ support" do
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

    expect(result.types).to eq([:hash, :hash])
    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq(<<~DIFF)
      changed key: "key1" (435 -> 453)
      changed key: "key2" ("yes" -> 342)
      changed key: "key3" ("bongo452" -> "video")
      changed key: "key5" ("present!" -> nil)
    DIFF
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
          new key: [4] ([])
      changed key: [0] (1 -> {})
      changed key: [2] (3 -> "3")
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
      changed key: "my_hash" ("my hash" -> "my (not) hash")
      changed key: "this" ("is" -> "isn't")
    DIFF

    result2 = diff(hash, json)

    expect(result2.types).to eq([:hash, :hash])
    expect(result2.empty?).to eq(false)
    expect(result2.to_s).to eq(<<~DIFF)
      changed key: "my_hash" ("my (not) hash" -> "my hash")
      changed key: "this" ("isn't" -> "is")
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
end
