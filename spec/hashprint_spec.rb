require "bigdecimal"

RSpec.describe "Specdiff::Hashprint" do
  def call(...) = Specdiff.hashprint(...)

  it "prints the empty hash" do
    expect(call({})).to eq("{\n}")
  end

  it "prints the empty array" do
    expect(call([])).to eq("[\n]")
  end

  it "prints an array of numbers" do
    expect(call([1, 2, 3])).to eq(<<~TXT.chomp)
      [
        1,
        2,
        3,
      ]
    TXT
  end

  it "prints an array of strings" do
    expect(call(["a", "bob", "c"])).to eq(<<~TXT.chomp)
      [
        "a",
        "bob",
        "c",
      ]
    TXT
  end

  it "prints arrays of arrays of floats" do
    array = [
      [2.0, 3.2, 5.3],
      [
        [33.33, 75345.324, 222.3],
        [55.2],
      ],
      [2.0, 3.2, 5.3],
    ]

    expect(call(array)).to eq(<<~TXT.chomp)
      [
        [
          2.0,
          3.2,
          5.3,
        ],
        [
          [
            33.33,
            75345.324,
            222.3,
          ],
          [
            55.2,
          ],
        ],
        [
          2.0,
          3.2,
          5.3,
        ],
      ]
    TXT
  end

  it "prints arrays of empty arrays and empty hashes" do
    expect(call([[], [[], []], {}, [{}, {test: {}, test2: []}]])).to eq(<<~TXT.chomp)
      [
        [
        ],
        [
          [
          ],
          [
          ],
        ],
        {
        },
        [
          {
          },
          {
            test: {
            },
            test2: [
            ],
          },
        ],
      ]
    TXT
  end

  # this is actually a test of ::Specdiff.diff_inspect
  it "prints ALL the types" do
    # object ids like 0x00007f1da833a4d8 that change every test run are not
    # practical, so you should assume any type not tested here returns whatever
    # #inspect gives
    inspecty_boi = Object.new
    def inspecty_boi.inspect
      "<Inspecty boi>"
    end

    # these don't have an #inspect
    basic_object = MyBasicObjectClass.new
    inspect_was_undefd = ConstantForTheSolePurposeOfUndefiningInspect.new

    expect(call({
      string: "string HO \"",
      "symbol" => :lol,
      symbol: :symbol,
      regex: /lo?([a-d])l/i,
      int: 2,
      float: 2.45,
      infinity_plus: Float::INFINITY,
      infinity_minus: -Float::INFINITY,
      nan: Float::NAN,
      big_number_yo: 95_023_569_498_234_210_594_598_234_509_320_923_450_893_425,
      rational: Rational("2/12"),
      bigdecimal: BigDecimal("45462345.62346452342342131353467899991112454"),
      nothing: nil,
      truth: true,
      falsehood: false,
      array: [],
      hash: {},
      time: Time.new(2000, 1, 1, 5, 34, 1, "+02:00"),
      date: Date.new(1999, 12, 31),
      datetime: DateTime.new(2001, 2, 3, 4, 5, 6, "+0700"),
      fallback_to_inspect: inspecty_boi,
      uninspectable1: basic_object,
      uninspectable2: inspect_was_undefd,
    })).to eq(<<~TXT.chomp)
      {
        string: "string HO \\\"",
        "symbol" => :lol,
        symbol: :symbol,
        regex: /lo?([a-d])l/i,
        int: 2,
        float: 2.45,
        infinity_plus: Infinity,
        infinity_minus: -Infinity,
        nan: NaN,
        big_number_yo: 95023569498234210594598234509320923450893425,
        rational: (1/6),
        bigdecimal: #<BigDecimal: 45462345.62346452342342131353467899991112454>,
        nothing: nil,
        truth: true,
        falsehood: false,
        array: [
        ],
        hash: {
        },
        time: #<Time: 2000-01-01 05:34:01 +0200>,
        date: #<Date: 1999-12-31>,
        datetime: #<DateTime: 2001-02-03T04:05:06+07:00>,
        fallback_to_inspect: <Inspecty boi>,
        uninspectable1: #<uninspectable MyBasicObjectClass>,
        uninspectable2: #<uninspectable ConstantForTheSolePurposeOfUndefiningInspect>,
      }
    TXT
  end

  it "prints hash opening braces correctly inside arrays" do
    expect(call({
      "slasher" => [
        {race: [{}, {}]},
      ],
    })).to eq(<<~TXT.chomp)
      {
        "slasher" => [
          {
            race: [
              {
              },
              {
              },
            ],
          },
        ],
      }
    TXT
  end

  it "prints a hash with symbol keys" do
    expect(call({
      test: "testing",
      one_two_three: 123,
      is_this_thing_on: :haha,
    })).to eq(<<~TXT.chomp)
      {
        test: "testing",
        one_two_three: 123,
        is_this_thing_on: :haha,
      }
    TXT
  end

  it "prints a hash with string keys" do
    expect(call({
      "test" => "testing",
      "one, two, three" => 123,
      "is_this_thing_on" => "haha",
    })).to eq(<<~TXT.chomp)
      {
        "test" => "testing",
        "one, two, three" => 123,
        "is_this_thing_on" => "haha",
      }
    TXT
  end

  it "prints a hash with mixed keys" do
    expect(call({
      x: "y",
      "ping" => "pong",
    })).to eq(<<~TXT.chomp)
      {
        x: "y",
        "ping" => "pong",
      }
    TXT
  end

  it "prints hashes within hashes within hashes" do
    hash = {
      alpha: {
        "2020" => {
          x: 3, y: 6,
        },
        "2021" => {
          x: 643, y: 32,
        },
      },
      beta: {
        released: true,
        delayed: false,
      },
    }

    expect(call(hash)).to eq(<<~TXT.chomp)
      {
        alpha: {
          "2020" => {
            x: 3,
            y: 6,
          },
          "2021" => {
            x: 643,
            y: 32,
          },
        },
        beta: {
          released: true,
          delayed: false,
        },
      }
    TXT
  end
end
