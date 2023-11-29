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
      changed "key1" from 435 to 453
      changed "key2" from "yes" to 342
      changed "key3" from "bongo452" to "video"
      changed "key5" from "present!" to nil
    DIFF
  end

  it "diffs json strings" do
    json1 = '"test json string"'
    json2 = '"test json stirng"'

    result = diff(json1, json2)

    expect(result.types).to eq([:text, :text])
    expect(result.empty?).to eq(false)
    expect(result.to_s).to eq(<<~DIFF)
      @@ -1 +1 @@
      -test json string
      +test json stirng
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
      changed [0] from 1 to {}
      changed [2] from 3 to "3"
      added [4] with value []
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
      changed "my_hash" from "my hash" to "my (not) hash"
      changed "this" from "is" to "isn't"
    DIFF

    result2 = diff(hash, json)

    expect(result2.types).to eq([:hash, :hash])
    expect(result2.empty?).to eq(false)
    expect(result2.to_s).to eq(<<~DIFF)
      changed "my_hash" from "my (not) hash" to "my hash"
      changed "this" from "isn't" to "is"
    DIFF
  end
end
