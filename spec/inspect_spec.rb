RSpec.describe "Specdiff::Inspect" do
  def call(*args, **kwargs, &block)
    ::Specdiff.diff_inspect(*args, **kwargs, &block)
  end

  it "inspects nil" do
    expect(call(nil)).to eq("nil")
  end

  it "inspects basic types" do
    expect(call(35)).to eq("35")
    expect(call(463.52)).to eq("463.52")
    expect(call("ca")).to eq('"ca"')
  end

  it "inspects date" do
    expect(call(Date.new(1, 2, 3))).to eq("#<Date: 0001-02-03>")
  end

  it "inspects empty hash" do
    expect(call({})).to eq("{}")
  end

  it "inspects symbol keyed hash" do
    expect(call({test: 1, test2: 2})).to eq("{:test=>1, :test2=>2}")
  end

  it "inspects string keyed hash" do
    expect(call({"beep" => :sd, "boop" => 2})).to eq('{"beep"=>:sd, "boop"=>2}')
  end

  it "inspects mixed key hash" do
    expect(call({m: :a, "l" => 5456})).to eq('{:m=>:a, "l"=>5456}')
  end

  it "inspects empty array" do
    expect(call([])).to eq("[]")
  end

  it "inspects array" do
    expect(call([1, 2, "3", :four])).to eq('[1, 2, "3", :four]')
  end

  it "inspects objects that cannot be inspected" do
    # these don't have an #inspect
    basic_object = MyBasicObjectClass.new
    inspect_was_undefd = ConstantForTheSolePurposeOfUndefiningInspect.new

    expect(call(basic_object)).to eq("#<uninspectable MyBasicObjectClass>")
    expect(call(inspect_was_undefd))
      .to eq("#<uninspectable ConstantForTheSolePurposeOfUndefiningInspect>")
  end

  it "inspects hash with value that cannot be inspected" do
    # these don't have an #inspect
    basic_object = MyBasicObjectClass.new
    inspect_was_undefd = ConstantForTheSolePurposeOfUndefiningInspect.new

    expect(call({
      a: :b,
      "m" => "g",
      "whoa" => basic_object,
      test: inspect_was_undefd,
      forty: 40,
    })).to eq(<<~TXT.chomp)
      {:a=>:b, "m"=>"g", \
      "whoa"=>#<uninspectable MyBasicObjectClass>, \
      :test=>#<uninspectable ConstantForTheSolePurposeOfUndefiningInspect>, \
      :forty=>40}
    TXT
  end

  it "inspects array with element that cannot be inspected" do
    # these don't have an #inspect
    basic_object = MyBasicObjectClass.new
    inspect_was_undefd = ConstantForTheSolePurposeOfUndefiningInspect.new

    expect(call([1, 2, basic_object, "dfsgr", inspect_was_undefd, :symbo]))
      .to eq(<<~TXT.chomp)
        [1, 2, \
        #<uninspectable MyBasicObjectClass>, \
        "dfsgr", \
        #<uninspectable ConstantForTheSolePurposeOfUndefiningInspect>, \
        :symbo]
      TXT
  end

  it "deals with array that contains itself" do
    root = [Date.new(1911, 2, 10), 2, [], nil, {}]
    layer12 = [Date.new(2011, 1, 1), "test", root]
    layer11 = [2, layer12]
    root[2] = layer11

    layer21 = {x: "y", root: root}
    root[4] = layer21

    expect(call(root)).to eq(<<~TXT.chomp)
      [#<Date: 1911-02-10>, 2, [2, [#<Date: 2011-01-01>, "test", [...]]], \
      nil, {:x=>"y", :root=>[...]}]
    TXT
  end

  it "deals with hash that contains itself" do
    root = {ha: :ha, "ha" => "ha", date: Date.new(2024, 1, 1)}

    layer12 = {root: root, date: Date.new(1923, 1, 1)}
    layer11 = {layer12: layer12}
    root[:oh_no] = layer11

    layer21 = [nil, :x, root, "ha"]
    root[:i_love_arrays] = layer21

    expect(call(root)).to eq(<<~TXT.chomp)
      {:ha=>:ha, "ha"=>"ha", \
      :date=>#<Date: 2024-01-01>, \
      :oh_no=>{:layer12=>{:root=>{...}, \
      :date=>#<Date: 1923-01-01>}}, \
      :i_love_arrays=>[nil, :x, {...}, "ha"]}
    TXT
  end
end
