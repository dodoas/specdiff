require "date"

RSpec.describe "" do
  it "has a passing spec" do
    expect(1).to eq(1)
  end

  describe "eq" do
    it "numbers" do
      expect(463).to eq(3459)
    end

    it "booleans" do
      expect(true).to eq(false)
    end

    describe "strings" do
      it "short strings" do
        expect("baglro").to eq("vinefde")
      end

      it "single line differing encodings" do
        s1 = "hello".encode("UTF-16")
        s2 = "hello".encode("UTF-8")

        expect(s1).to eq(s2)
      end

      it "short multiline strings" do
        s1 = "a\nb\nc"
        s2 = "x\ny\nc\n"

        expect(s1).to eq(s2)
      end

      it "long multiline strings" do
        s1 = <<~MSG
          Lorem ipsum dolor sit amet,
          consectetur adipiscing elit,
          sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

          Ut enim ad minim veniam,
          quis nostrud exercitation ullamco laboris nisi ut aliquip
          ex ea commodo consequat.
          Duis aute irure dolor in reprehenderit in voluptate velit
          esse cillum dolore eu fugiat nulla pariatur.

          Excepteur sint occaecat cupidatat non proident,
          sunt in culpa qui officia deserunt mollit anim id est laborum.
        MSG

        s2 = <<~MSG
          Lirem ipsum dolor sit amet,
          consectetur adipiscing elit,
          sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

          Tu mine da minim mainem,
          quis nostrud exercitation ullamco laboris nisi ut aliquip
          ex ea commodo consequat.
          Dui aute irure dolor in reprehenderi in voluptate velit
          esse cillum dolore eu fugiat nolla pariatur.

          x

          Excepteur sint occaecat cupidatat non proident,
          sunt in culpa qui officia deserunt mollit anim id est laborum.
        MSG

        expect(s1).to eq(s2)
      end

      it "long strings with no newlines" do
        s1 = <<~MSG.delete("\n")
          Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
        MSG

        s2 = <<~MSG.delete("\n")
          Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?
        MSG

        expect(s1).to eq(s2)
      end

      it "long strings, no newlines and subtle difference" do
        s1 = <<~MSG.chomp
          On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.
        MSG

        s2 = <<~MSG.chomp
          On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our belng able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.
        MSG

        expect(s1).to eq(s2)
      end

      it "multi line multi hunk" do
        s1 = <<~MSG.chomp
          a

          aa
          aaa
          aaa
          a

          a
          a
          a
          a
          a
          a
          a
          a

          aghf

          be
          bebeb
          be
          eeb
          bebe
          d

          segesrgawf
          segesrgawf
          segesrgawf
          segesrgawf
          segesrgawf
          segesrgawf
          segesrgawf

          a
          aaa
          ddd
          s
        MSG
        s2 = <<~MSG.chomp
          a

          aa
          aba
          aaa
          a

          a
          a
          a
          b
          a
          a
          a
          a

          aghf

          be
          bebeb
          be
          eeb
          bebe
          d

          segesrgawf
          segesrgawf
          segesrgawf
          segesrgawf
          segesrgawf
          segesrgawf

          a
          aaa
          ddd
          s
        MSG

        expect(s1).to eq(s2)
      end
    end

    describe "hashes" do
      it "1 key, value difference" do
        expect({alpha: "wares"}).to eq({alpha: "waldo"})
      end
      it "1 key, key difference" do
        expect({beta: "wares"}).to eq({alpha: "wares"})
      end

      it "5 keys" do
        expect({
          a: :b,
          c: "d",
          ee: "k",
          b: 22,
          "k" => :then,
        }).to eq({
          a: "b",
          c: "de",
          ea: "k",
          l: 23,
          "m" => :ok,
        })
      end

      it "more keys than lcs context, mostly nested" do
        expect({
          "slasher" => [
            {
              tigress: 4,
              coffee: Date.parse("2029-01-01"),
              cavalry: nil,
              exert: "AAA3",
              pension: Date.parse("2029-09-10"),
              thermal: "USD",
              swung: 999,
              tipping: "XY342",
              uncombed: "AAA333AAA333AAA333",
              tactical: "Barber boy",
              thyself: "Evil Cackle",
              race: [
                {
                  gully: 2,
                  snarl: "dry",
                  avatar: nil,
                  bulge: 2104.92,
                  chosen: "AAA",
                },
                {
                  gully: 3,
                  snarl: "pony",
                  avatar: nil,
                  bulge: 2104.92,
                  chosen: "AAA",
                },
              ],
              blitz: 432252,
            },
          ],
          "late" => false,
        }).to eq({
          "slasher" => [
            {
              tigress: 4,
              coffee: Date.parse("2029-01-01"),
              cavalry: nil,
              exert: "AAA3",
              pension: Date.parse("2029-09-10"),
              thermal: "USD",
              swung: 999,
              tipping: "XY342",
              uncombed: "AAA333AAA333AAA333",
              tactical: "Barber boy",
              thyself: "Evil Cackle",
              race: [
                {
                  gully: 2,
                  snarl: "dry",
                  avatar: nil,
                  bulge: 2104.92,
                  chosen: "AAA",
                },
                {
                  gully: 3,
                  snarl: "pony",
                  avatar: nil,
                  bulge: 2104.92,
                  chosen: "AAA",
                },
              ],
              blitz: 4523.643,
            },
          ],
          "late" => true,
        })
      end

      it "more keys than lcs context, empty ish diff" do
        expect({
          "slasher" => [
            {
              race: [
                {}, {},
              ],
            },
          ],
        }).to eq({
          "slasher" => [
            {
              tigress: 4,
              coffee: Date.parse("2029-01-01"),
              cavalry: nil,
              exert: "AAA3",
              pension: Date.parse("2029-09-10"),
              thermal: "USD",
              swung: 999,
              tipping: "XY342",
              uncombed: "AAA333AAA333AAA333",
              tactical: "Barber boy",
              thyself: "Evil Cackle",
              race: [
                {
                  gully: 2,
                  snarl: "dry",
                  avatar: nil,
                  bulge: 2104.92,
                  chosen: "AAA",
                },
                {
                  gully: 3,
                  snarl: "pony",
                  avatar: nil,
                  bulge: 2104.92,
                  chosen: "AAA",
                },
              ],
              blitz: 4523.643,
            },
          ],
          "late" => true,
        })
      end

      it "hash with procs and other weird objects" do
        expect({
          test: ->(a, b) { puts a; puts b },
          x: "42",
        }).to eq({
          test: lambda do sleep 1 end,
          x: "43",
        })
      end

      it "the hash diff example" do
        expect({
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
        }).to eq({
          data: {
            latitude: 200,
            "longitude" => 60,
            generationtime_ms: 2.2342,
            hourly: {
              time: ["2022-07-01T01:00", "2022-07-01T02:00", "2022-07-01T03:00"],
              temperature: [12.7, 12.5, 12.3],
            },
            hourly_units: {
              temperature: "°F",
            },
          },
        })
      end

      it "the hash text diff example" do
        expect({
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
        }).to eq({
          "data" => {
            "latitude" => 200,
            "longitude" => 60,
            "hourly" => {
              "time" => ["2022-07-01T00:00", "2022-07-01T01:00", "2022-07-01T02:00"],
              "temperature" => [13, 12.7, 12.5],
            },
            "hourly_units" => {
              "temperature" => "°C",
            },
          },
        })
      end
    end

    it "hash vs nil" do
      expect({a: :b}).to eq(nil)
    end
  end

  describe "eql" do
    it "strings" do
      s1 = <<~MSG
        this is gtex
        pweoekeoekwpef

        cam shaft motorway
        ca shaft morord day

        video games
      MSG

      s2 = <<~MSG
        rthoijserg
        erg
        sehg
        earg
        ersgerg
      MSG

      expect(s1).to eql(s2)
    end

    it "hashes" do
      hash1 = {
        a: {a: {a: {a: [1, 2, 3]}}},
        b: :x,
      }
      hash2 = {
        a: {a: {b: {a: [1, 2, 3]}}},
        b: :x,
      }

      expect(hash1).to eql(hash2)
    end
  end

  describe "equal" do
    it "different strings" do
      s1 = <<~MSG
        this is gtex
        pweoekeoekwpef

        cam shaft motorway
        ca shaft morord day

        video games
      MSG

      s2 = <<~MSG
        rthoijserg
        erg
        sehg
        earg
        ersgerg
      MSG

      expect(s1).to equal(s2)
    end

    it "different hashes" do
      hash1 = {
        a: {a: {a: {a: [1, 2, 3]}}},
        b: :x,
      }
      hash2 = {
        a: {a: {b: {a: [1, 2, 3]}}},
        b: :x,
      }

      expect(hash1).to equal(hash2)
    end

    it "same strings" do
      s1 = <<~MSG
        rthoijserg
        erg
        sehg
        earg
        ersgerg
      MSG

      s2 = <<~MSG
        rthoijserg
        erg
        sehg
        earg
        ersgerg
      MSG

      expect(s1).to equal(s2)
    end

    it "same hashes" do
      hash1 = {
        a: {a: {a: {a: [1, 2, 3]}}},
        b: :x,
      }
      hash2 = {
        a: {a: {a: {a: [1, 2, 3]}}},
        b: :x,
      }

      expect(hash1).to equal(hash2)
      end
  end

  describe "have_attributes" do
    it "two symbol keys" do
      klass = Class.new do
        def hibernate
          "yes"
        end
        def sawblade
          34
        end
        def ignored
          /haha/
        end
      end
      instance = klass.new

      expect(instance).to have_attributes({hibernate: "yes", sawblade: 34})

      # no diff when missing an attribute, since it just complains that the
      # object doesn't respond
      # expect(instance).to have_attributes({
      #   bong: :bing,
      #   bang: :bling,
      #   song: :sing,
      #   hibernate: 42,
      # })
      expect(instance).to have_attributes({
        hibernate: "no", sawblade: 33,
      })
    end

    it "two string keys" do
      klass = Class.new do
        def hibernate
          "yes"
        end
        def sawblade
          34
        end
        def ignored
          /haha/
        end
      end
      instance = klass.new

      expect(instance).to have_attributes({"hibernate" => "yes", "sawblade" => 34})

      # expect(instance).to have_attributes({
      #   bong: :bing,
      #   bang: :bling,
      #   song: :sing,
      #   hibernate: 42,
      # })
      expect(instance).to have_attributes({
        "hibernate" => "no", "sawblade" => 33,
      })
    end
  end

  describe "include" do
    it "array numbers" do
      expect([1, 2]).to include(1, 4, 2, 3)
    end

    it "multiline strings" do
      string = <<~TXT
        aaaaa

        bbbbbc
        cc
        deeee
        heee
      TXT

      expect(string).to include("cc\ndeed")
    end

    it "2 multiline strings" do
      string = <<~TXT
        aaaaa

        bbbbbc
        cc
        deeee
        heee
      TXT

      expect(string).to include("cc\ndeed", "e\nhehe")
    end

    it "shallow hash" do
      hash = {
        a: :b,
        c: "d",
        e: 3,
      }

      expect(hash).to include("d")
    end

    # hmm interesting. doesn't look too good, but still a little better than
    # default rspec
    it "shallow nested hash" do
      hash = {
        a: :b,
        c: {
          ve: "lu",
          mm: "hmm",
        },
        e: 3,
      }

      expect(hash).to include({c: {mm: "hmmm", ve: "le"}})
    end
  end

  describe "match" do
    it "single line string against regex" do
      expect("tootsie fall").to match(/oot.+fals/)
    end

    it "single line string against string" do
      expect("tootsie fall").to match("ootsflas")
    end

    it "multi line string against regex" do
      expect("tootsie\nwitsy\nmatsy\nmoe").to match(/wity.+matty/)
    end

    it "mutli line string against string" do
      expect("tootsie\nwitsy\nmatsy\nmoe").to match("sie\nwitsy\nsds")
    end
  end

  describe "output" do
    it "single line string against regex" do
      expect { $stdout.puts "ninja simulator sickness" }
        .to output(/ninsim/).to_stdout
    end

    it "single line string against string" do
      expect { $stdout.puts "ninja simulator sickness" }
        .to output("ninsim").to_stdout
    end

    it "multi line string against regex" do
      expect { $stdout.puts "ninja\nsimulator\nsickness" }
        .to output(/sim.+sicns/).to_stdout
    end

    it "mutli line string against string" do
      expect { $stdout.puts "ninja\nsimulator\nsickness" }
        .to output("ninja\nsim\soicns").to_stdout
    end
  end

  describe "custom matcher" do
    RSpec::Matchers.define :my_cool_matcher do |expected|
      match do |actual|
        expected = "my\nsuper\ncool\nstring\nyo"

        actual == expected
      end

      def diffable?
        true
      end
    end

    it "string" do
      expect("my string").to my_cool_matcher
    end

    it "mutli line string" do
      expect("my\nnot\nvery\ncool\nstring").to my_cool_matcher
    end
  end

  describe "inspect output" do
    it "all the types" do
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

      basic_object2_klass = Class.new(BasicObject)
      basic_object2 = basic_object2_klass.new

      expect({
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
        a_normal_class: Module,
        fallback_to_inspect: inspecty_boi,
        uninspectable1: basic_object,
        uninspectable2: inspect_was_undefd,
        uninspectable3: basic_object2,
      }).to eq({})
    end

    it "very weird hash keys" do
      my_cool_hash = {1 => 2, "yes" => :no}
      an_ary = [1, 2, my_cool_hash, "whoa"]

      expect({
        Time => 1,
        Date => 2,
        Class.new => 3,
        {} => :x,
        my_cool_hash => my_cool_hash,
        [] => an_ary,
        [1, 2] => {x: ["d"]},
      }).to eq({})
    end
  end

  describe 'situations where rspec matchers get "inspected"' do
    it "match([have_attributes(...), have_attributes(...), ...])" do
      alpha = Struct.new(:a)

      expect([alpha.new(2), alpha.new(4)]).to match([
        have_attributes(a: 3),
        have_attributes(a: 6),
        have_attributes(a: 4),
      ])
    end

    it ".and" do
      expect("s\nn\nl\n").to eq("k\ntl")
        .and(eq("s\ne\nl"))
    end

    it ".or" do
      expect("s\nn\nl\n").to eq("k\ntl")
        .or(eq("s\ne\nl"))
    end

    it ".all" do
      expect([
        "s\nn\nl",
        "v\nd\nl",
      ]).to all(eq("j\no\nh"))
    end
  end
end
