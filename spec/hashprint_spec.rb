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

  # this is actually an integration test of ::Specdiff.diff_inspect
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
      Class => Module, # prevent the hash from being sorted
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
        Class => Module,
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

  it "sorts and prints a hash with symbol keys" do
    expect(call({
      test: "testing",
      one_two_three: 123,
      is_this_thing_on: :haha,
    })).to eq(<<~TXT.chomp)
      {
        is_this_thing_on: :haha,
        one_two_three: 123,
        test: "testing",
      }
    TXT
  end

  it "sorts and prints a hash with string keys" do
    expect(call({
      "test" => "testing",
      "one, two, three" => 123,
      "is_this_thing_on" => "haha",
    })).to eq(<<~TXT.chomp)
      {
        "is_this_thing_on" => "haha",
        "one, two, three" => 123,
        "test" => "testing",
      }
    TXT
  end

  it "sorts and prints a hash with mixed keys" do
    expect(call({
      x: "y",
      "ping" => "pong",
      "abracadabra" => :hmm,
    })).to eq(<<~TXT.chomp)
      {
        "abracadabra" => :hmm,
        "ping" => "pong",
        x: "y",
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
        delayed: false,
        released: true,
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
          delayed: false,
          released: true,
        },
      }
    TXT
  end

  it "deals with array that contains itself" do
    root = [Date.new(1911, 2, 10), 2, [], nil, {}]
    layer12 = [Date.new(2011, 1, 1), "test", root]
    layer11 = [2, layer12]
    root[2] = layer11

    layer21 = {root: root, x: "y"}
    root[4] = layer21

    expect(call(root)).to eq(<<~TXT.chomp)
      [
        #<Date: 1911-02-10>,
        2,
        [
          2,
          [
            #<Date: 2011-01-01>,
            "test",
            [...],
          ],
        ],
        nil,
        {
          root: [...],
          x: "y",
        },
      ]
    TXT
  end

  it "deals with hash that contains itself" do
    root = {date: Date.new(2024, 1, 1), ha: :ha, "ha" => "ha"}

    layer12 = {date: Date.new(1923, 1, 1), root: root}
    layer11 = {layer12: layer12}

    layer21 = [nil, :x, root, "ha"]

    root[:i_love_arrays] = layer21
    root[:oh_no] = layer11

    expect(call(root)).to eq(<<~TXT.chomp)
      {
        date: #<Date: 2024-01-01>,
        ha: :ha,
        "ha" => "ha",
        i_love_arrays: [
          nil,
          :x,
          {...},
          "ha",
        ],
        oh_no: {
          layer12: {
            date: #<Date: 1923-01-01>,
            root: {...},
          },
        },
      }
    TXT
  end

  it "prints hashes with they weirdest keys you've ever seen" do
    alpha = [1, 2, 3]
    beta = {a: alpha, b: []}
    ceta = [alpha, beta, alpha]

    # recursive structure
    veta = {a: {}}
    jeta = {v: veta}
    veta[:b] = jeta

    root = {
      _hashes: { # _ makes it first in the sort order
        {} => {ya: "boi"},
        {1 => 2} => [],
        {2 => 3} => {},
      },
      arrays: {
        [] => "empty :(",
        [1] => [1, 2, 3],
        ["hash"] => {},
        ["hash2"] => {
          oh_no: "lol",
        },
      },
      classes: {
        Module => true,
        Class => false,
        Time => :pls_no,
        DateTime => Date,
        Date => Time,
      },
      more_recursion_than_you_can_shake_a_stick_at: {
        ceta => ceta,
        veta => veta,
      },
    }

    expect(call(root)).to eq(<<~TXT.chomp)
      {
        _hashes: {
          {} => {
            ya: "boi",
          },
          {1=>2} => [
          ],
          {2=>3} => {
          },
        },
        arrays: {
          [] => "empty :(",
          [1] => [
            1,
            2,
            3,
          ],
          ["hash"] => {
          },
          ["hash2"] => {
            oh_no: "lol",
          },
        },
        classes: {
          Module => true,
          Class => false,
          Time => :pls_no,
          DateTime => Date,
          Date => Time,
        },
        more_recursion_than_you_can_shake_a_stick_at: {
          [[1, 2, 3], {:a=>[1, 2, 3], :b=>[]}, [1, 2, 3]] => [
            [
              1,
              2,
              3,
            ],
            {
              a: [
                1,
                2,
                3,
              ],
              b: [
              ],
            },
            [
              1,
              2,
              3,
            ],
          ],
          {:a=>{}, :b=>{:v=>{...}}} => {
            a: {
            },
            b: {
              v: {...},
            },
          },
        },
      }
    TXT
  end
end
