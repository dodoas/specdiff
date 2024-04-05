RSpec.describe "Specdiff" do
  def diff(...) = Specdiff.diff(...)

  describe "text" do
    it "it diffs some text" do
      txt1 = <<~TXT
        bob
        jon
      TXT
      txt2 = <<~TXT
        bobo
        help
      TXT
      result = diff(txt1, txt2)

      expect(result.types).to eq([:text, :text])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ -1,3 +1,3 @@
        -bob
        -jon
        +bobo
        +help
      DIFF
    end

    it "diffs larger texts" do
      txt1 = <<~TXT
        this
        is
        some
        text
        that
        will
        be
        changed
      TXT
      txt2 = <<~TXT
        this
        is
        the
        changed
        text
      TXT
      result = diff(txt1, txt2)

      expect(result.to_s).to eq(<<~DIFF)
        @@ -1,9 +1,6 @@
         this
         is
        -some
        -text
        -that
        -will
        -be
        +the
         changed
        +text
      DIFF
    end

    it "creates a text diff with multiple hunks" do
      txt1 = <<~TXT
        Lorem
        ipsum
        dolor
        sit
        amet,
        consectetur
        adipiscing
        elit,
        sed
        do
        eiusmod
        tempor
        incididunt
        ut
        labore
        et
        dolore
        magna
        aliqua.
      TXT
      txt2 = <<~TXT
        lorem
        ipsum
        dolor
        sit
        amet,
        consectetur
        adipiscing
        elit,
        sed
        do
        eiusmod
        tempor
        incididunt
        ut
        labore
        et
        dolore
        magna
        aliqua
      TXT
      result = diff(txt1, txt2)

      expect(result.to_s).to eq(<<~DIFF)
       @@ -1,4 +1,4 @@
       -Lorem
       +lorem
        ipsum
        dolor
        sit

       @@ -16,5 +16,5 @@
        et
        dolore
        magna
       -aliqua.
       +aliqua
      DIFF
    end

    it "produces an empty diff when two strings are the same" do
      txt1 = <<~TXT
        my
        text
        text
        text
        ;''
      TXT
      txt2 = txt1.dup

      result = diff(txt1, txt2)

      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("")
    end

    # until we have word diffing it would be pointless to show a diff of this
    it "produces an empty diff if both strings are a single line" do
      txt1 = <<~TXT.chomp
        abcdefg js css html hmlkjgf
      TXT
      txt2 = <<~TXT.chomp
        vvv vvv js html css juletide
      TXT

      result = diff(txt1, txt2)

      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("")
    end

    describe "encoding" do
      it "diffs in a non-standard encoding" do
        txt1 = <<~TXT.encode("Windows-1252")
          thøs
          is
          søme
          text
          that
          will
          bø
          chånged
        TXT
        txt2 = <<~TXT.encode("Windows-1252")
          thøs
          is
          thå
          chånged
          text
        TXT
        result = diff(txt1, txt2)

        expect(result.types).to eq([:text, :text])
        expect(result.empty?).to eq(false)
        expect(result.to_s).to eq(<<~DIFF.encode("Windows-1252"))
          @@ -1,9 +1,6 @@
           thøs
           is
          -søme
          -text
          -that
          -will
          -bø
          +thå
           chånged
          +text
        DIFF
      end

      it "interprets binary encoding as binary" do
        blob1 = "test".encode(Encoding::BINARY)
        blob2 = "test2".encode(Encoding::BINARY)

        result = diff(blob1, blob2)

        expect(result.types).to eq([:binary, :binary])
        expect(result.empty?).to eq(true)
        expect(result.to_s).to eq(<<~DIFF.chomp)
          <binary content> != <binary content>
        DIFF
      end

      it "produces a message if the encodings are different" do
        result = diff("text".encode("Windows-1258"), "text".encode("ISO8859-10"))

        expect(result.types).to eq([:text, :text])
        expect(result.empty?).to eq(false)
        expect(result.to_s).to eq(<<~DIFF)
          Strings have different encodings:
            #<Encoding:Windows-1258> != #<Encoding:ISO-8859-10>
        DIFF
      end

      # webmock hands me one of the sides in binary encoding
      it "it tries to convert binary to the other side's encoding" do
        text1 = <<~TEXT
          text1
          the
          text
          of
          destiny
        TEXT
        text2 = <<~TEXT.encode(Encoding::BINARY)
          text2
          the
          text
          of
          greatness
        TEXT

        result = diff(text1, text2)
        expect(result.types).to eq([:text, :text])
        expect(result.empty?).to eq(false)
        expect(result.to_s).to eq(<<~DIFF)
          @@ -1,6 +1,6 @@
          -text1
          +text2
           the
           text
           of
          -destiny
          +greatness
        DIFF
      end
    end
  end

  it "detects binary and produces an empty diff if either side is binary" do
    jpeg = File.binread(fixture_path.join("1px.jpeg"))
    png = File.binread(fixture_path.join("1px.png"))

    result1 = diff(jpeg, png)

    expect(result1.types).to eq([:binary, :binary])
    expect(result1.empty?).to eq(true)
    expect(result1.to_s).to eq(<<~DIFF.chomp)
      <binary content> != <binary content>
    DIFF

    result2 = diff({jpeg: ".jpeg"}, png)

    expect(result2.types).to eq([:hash, :binary])
    expect(result2.empty?).to eq(true)
    expect(result2.to_s).to eq(<<~DIFF.chomp)
      {:jpeg=>".jpeg"} != <binary content>
    DIFF

    result3 = diff(jpeg, "png")

    expect(result3.types).to eq([:binary, :text])
    expect(result3.empty?).to eq(true)
    expect(result3.to_s).to eq(<<~DIFF.chomp)
      <binary content> != "png"
    DIFF
  end

  describe "hashes and arrays" do
    it "diffs nested hashes where values change" do
      hash1 = {
        a: :b,
        b: 45,
        c: [:a, :b, :c],
        d: {
          e: {
            f: [34],
          },
          g: :l,
        },
      }
      hash2 = {
        a: :b,
        b: 12,
        c: [:c, :b, :a],
        d: {
          e: {
            f: [],
          },
          g: 6543234,
        },
      }

      result = diff(hash1, hash2)

      expect(result.types).to eq([:hash, :hash])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +0/-1/~4 @@
        missing key: d.e.f[0] (34)
          new value: b (45 -> 12)
          new value: c[0] (:a -> :c)
          new value: c[2] (:c -> :a)
          new value: d.g (:l -> 6543234)
      DIFF
    end

    it "diffs completely different hashes" do
      hash1 = {
        amount1: 34235,
        amount2: 4534,
        calculated_amount1: 45346,
        calculated_amount2: 5436345,
        total1: 45345,
        total2: 54621,
        status: "filled",
      }
      hash2 = {
        "UPPERCASE" => "TADA",
        "lowercase" => "tada",
        "CamelCase" => "TaDa",
        "pascalCase" => "taDa",
        "snake_case" => "ta_da",
        "SCREAMING_SNAKE_CASE" => "TA_DA",
        "kebab-case" => "ta-da",
      }

      result = diff(hash1, hash2)

      expect(result.types).to eq([:text, :text])

      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ -1,10 +1,10 @@
         {
        -  amount1: 34235,
        -  amount2: 4534,
        -  calculated_amount1: 45346,
        -  calculated_amount2: 5436345,
        -  total1: 45345,
        -  total2: 54621,
        -  status: "filled",
        +  "UPPERCASE" => "TADA",
        +  "lowercase" => "tada",
        +  "CamelCase" => "TaDa",
        +  "pascalCase" => "taDa",
        +  "snake_case" => "ta_da",
        +  "SCREAMING_SNAKE_CASE" => "TA_DA",
        +  "kebab-case" => "ta-da",
         }
      DIFF
    end

    it "uses hashdiff on nested hashes w/ only extra or missing keys" do
      hash1 = {
        "slasher" => [
          {
            race: [
              {}, {},
            ],
          },
        ],
      }
      hash2 = {
        "slasher" => [
          {
            tigress: 4,
            coffee: "2029-01-01",
            cavalry: nil,
            exert: "AAA3",
            pension: "2029-09-10",
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
      }

      result1 = diff(hash1, hash2)

      expect(result1.to_s).to eq(<<~DIFF)
        @@ +23/-0/~0 @@
          extra key: "slasher"[0].race[0].avatar (nil)
          extra key: "slasher"[0].race[0].bulge (2104.92)
          extra key: "slasher"[0].race[0].chosen ("AAA")
          extra key: "slasher"[0].race[0].gully (2)
          extra key: "slasher"[0].race[0].snarl ("dry")
          extra key: "slasher"[0].race[1].avatar (nil)
          extra key: "slasher"[0].race[1].bulge (2104.92)
          extra key: "slasher"[0].race[1].chosen ("AAA")
          extra key: "slasher"[0].race[1].gully (3)
          extra key: "slasher"[0].race[1].snarl ("pony")
          extra key: "slasher"[0].blitz (4523.643)
          extra key: "slasher"[0].cavalry (nil)
          extra key: "slasher"[0].coffee ("2029-01-01")
          extra key: "slasher"[0].exert ("AAA3")
          extra key: "slasher"[0].pension ("2029-09-10")
          extra key: "slasher"[0].swung (999)
          extra key: "slasher"[0].tactical ("Barber boy")
          extra key: "slasher"[0].thermal ("USD")
          extra key: "slasher"[0].thyself ("Evil Cackle")
          extra key: "slasher"[0].tigress (4)
          extra key: "slasher"[0].tipping ("XY342")
          extra key: "slasher"[0].uncombed ("AAA333AAA333AAA333")
          extra key: "late" (true)
      DIFF
      expect(result1.empty?).to eq(false)

      result2 = diff(hash2, hash1)

      expect(result2.to_s).to eq(<<~DIFF)
        @@ +0/-23/~0 @@
        missing key: "late" (true)
        missing key: "slasher"[0].blitz (4523.643)
        missing key: "slasher"[0].cavalry (nil)
        missing key: "slasher"[0].coffee ("2029-01-01")
        missing key: "slasher"[0].exert ("AAA3")
        missing key: "slasher"[0].pension ("2029-09-10")
        missing key: "slasher"[0].swung (999)
        missing key: "slasher"[0].tactical ("Barber boy")
        missing key: "slasher"[0].thermal ("USD")
        missing key: "slasher"[0].thyself ("Evil Cackle")
        missing key: "slasher"[0].tigress (4)
        missing key: "slasher"[0].tipping ("XY342")
        missing key: "slasher"[0].uncombed ("AAA333AAA333AAA333")
        missing key: "slasher"[0].race[0].avatar (nil)
        missing key: "slasher"[0].race[0].bulge (2104.92)
        missing key: "slasher"[0].race[0].chosen ("AAA")
        missing key: "slasher"[0].race[0].gully (2)
        missing key: "slasher"[0].race[0].snarl ("dry")
        missing key: "slasher"[0].race[1].avatar (nil)
        missing key: "slasher"[0].race[1].bulge (2104.92)
        missing key: "slasher"[0].race[1].chosen ("AAA")
        missing key: "slasher"[0].race[1].gully (3)
        missing key: "slasher"[0].race[1].snarl ("pony")
      DIFF
      expect(result2.empty?).to eq(false)
    end

    it "uses text diff on nested hashes where all the keys change" do
      hash1 = {
        "slasher" => [
          {
            cruelness: 4,
            stagnant: "2029-01-01",
            uncooked: nil,
            spinout: "AAA3",
            favoring: "2029-09-10",
            whinny: "USD",
            ascertain: 999,
            angriness: "XY342",
            wobbly: "AAA333AAA333AAA333",
            blooper: "Barber boy",
            landowner: "Evil Cackle",
            asleep: [
              {
                crispness: 2,
                landless: "dry",
                surging: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
              {
                crispness: 3,
                landless: "pony",
                surging: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
            ],
            creatable: 4523.643,
          },
        ],
        "cupcake" => true,
      }
      hash2 = {
        "slasher" => [
          {
            tigress: 4,
            coffee: "2029-01-01",
            cavalry: nil,
            exert: "AAA3",
            pension: "2029-09-10",
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
      }

      result = diff(hash1, hash2)

      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ -1,36 +1,36 @@
         {
           "slasher" => [
             {
        -      cruelness: 4,
        -      stagnant: "2029-01-01",
        -      uncooked: nil,
        -      spinout: "AAA3",
        -      favoring: "2029-09-10",
        -      whinny: "USD",
        -      ascertain: 999,
        -      angriness: "XY342",
        -      wobbly: "AAA333AAA333AAA333",
        -      blooper: "Barber boy",
        -      landowner: "Evil Cackle",
        -      asleep: [
        +      tigress: 4,
        +      coffee: "2029-01-01",
        +      cavalry: nil,
        +      exert: "AAA3",
        +      pension: "2029-09-10",
        +      thermal: "USD",
        +      swung: 999,
        +      tipping: "XY342",
        +      uncombed: "AAA333AAA333AAA333",
        +      tactical: "Barber boy",
        +      thyself: "Evil Cackle",
        +      race: [
                 {
        -          crispness: 2,
        -          landless: "dry",
        -          surging: nil,
        -          tattoo: 2104.92,
        -          mama: "AAA",
        +          gully: 2,
        +          snarl: "dry",
        +          avatar: nil,
        +          bulge: 2104.92,
        +          chosen: "AAA",
                 },
                 {
        -          crispness: 3,
        -          landless: "pony",
        -          surging: nil,
        -          tattoo: 2104.92,
        -          mama: "AAA",
        +          gully: 3,
        +          snarl: "pony",
        +          avatar: nil,
        +          bulge: 2104.92,
        +          chosen: "AAA",
                 },
               ],
        -      creatable: 4523.643,
        +      blitz: 4523.643,
             },
           ],
        -  "cupcake" => true,
        +  "late" => true,
         }
      DIFF
    end

    it "uses text diff when 5\% of the changes are value changes" do
      hash1 = {
        "slasher" => [
          {
            cruelness: 90001,
            stagnant: "2029-01-02",
            uncooked: "true",
            spinout: "AAA4",
            favoring: "2029-09-10",
            whinny: "USD",
            ascertain: 999,
            angriness: "XY342",
            wobbly: "RTHITHIRTO334",
            blooper: "Barber boy",
            landowner: "Evil Cackle",
            asleep: [
              {
                crispness: 2,
                landless: "dry",
                surging: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
              {
                crispness: 3,
                landless: "pony",
                surging: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
            ],
            creatable: 4523.643,
          },
        ],
        "cupcake" => true,
      }
      hash2 = {
        "slasher" => [
          {
            payable: 90001,
            street: "2029-01-02",
            unsorted: "true",
            bullpen: "AAA4",
            favoring: "2029-09-10",
            nuzzle: "USD",
            ascertain: 999,
            angriness: "XY342",
            wobbly: "RTHITHIRTO334",
            blooper: "Barber boy",
            running: "Evil Cackle",
            asleep: [
              {
                crispness: 2,
                landless: "dry",
                amperage: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
              {
                crispness: 3,
                landless: "pony",
                amperage: nil,
                tattoo: 2104.92,
                mama: "ABA",
              },
            ],
            banner: 4523.643,
          },
        ],
      }

      result = diff(hash1, hash2)

      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ -1,36 +1,35 @@
         {
           "slasher" => [
             {
        -      cruelness: 90001,
        -      stagnant: "2029-01-02",
        -      uncooked: "true",
        -      spinout: "AAA4",
        +      payable: 90001,
        +      street: "2029-01-02",
        +      unsorted: "true",
        +      bullpen: "AAA4",
               favoring: "2029-09-10",
        -      whinny: "USD",
        +      nuzzle: "USD",
               ascertain: 999,
               angriness: "XY342",
               wobbly: "RTHITHIRTO334",
               blooper: "Barber boy",
        -      landowner: "Evil Cackle",
        +      running: "Evil Cackle",
               asleep: [
                 {
                   crispness: 2,
                   landless: "dry",
        -          surging: nil,
        +          amperage: nil,
                   tattoo: 2104.92,
                   mama: "AAA",
                 },
                 {
                   crispness: 3,
                   landless: "pony",
        -          surging: nil,
        +          amperage: nil,
                   tattoo: 2104.92,
        -          mama: "AAA",
        +          mama: "ABA",
                 },
               ],
        -      creatable: 4523.643,
        +      banner: 4523.643,
             },
           ],
        -  "cupcake" => true,
         }
      DIFF
    end

    it "uses hashdiff when 33\% of the changes are value changes" do
      hash1 = {
        "slasher" => [
          {
            cruelness: 90001,
            stagnant: "2029-01-01",
            uncooked: "true",
            spinout: "AAA4",
            favoring: "2029-09-10",
            whinny: "USD",
            ascertain: 999,
            angriness: "XY342",
            aide: "RTHITHIRTO334",
            blooper: "Barber boy",
            landowner: "Evil Cackle",
            asleep: [
              {
                crispness: 2,
                landless: "dry",
                surging: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
              {
                crispness: 3,
                landless: "pony",
                surging: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
            ],
            creatable: 4523.643,
          },
        ],
        "cupcake" => true,
      }
      hash2 = {
        "slasher" => [
          {
            cruelness: 2,
            stagnant: "2029-01-02",
            designing: "true",
            eagle: "AAA4",
            favoring: "2029-09-10",
            whinny: "USD",
            aide: "RTHITHIRTO334",
            blooper: "Barber boy",
            landowner: "Evil Cackle",
            asleep: [
              {
                crispness: 22222,
                bobsled: "dry",
                surging: nil,
                tattoo: 2104.92,
                mama: "AAA",
              },
              {
                crispness: 3333,
                bobsled: "ponies",
                surging: nil,
                tattoo: 34.2,
                mama: "AAA",
              },
            ],
            creatable: 4523.643,
          },
        ],
        "cupcake" => true,
      }

      result = diff(hash1, hash2)

      expect(result.types).to eq([:hash, :hash])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +4/-6/~5 @@
        missing key: "slasher"[0].angriness ("XY342")
        missing key: "slasher"[0].ascertain (999)
        missing key: "slasher"[0].spinout ("AAA4")
        missing key: "slasher"[0].uncooked ("true")
        missing key: "slasher"[0].asleep[0].landless ("dry")
        missing key: "slasher"[0].asleep[1].landless ("pony")

          extra key: "slasher"[0].asleep[0].bobsled ("dry")
          extra key: "slasher"[0].asleep[1].bobsled ("ponies")
          extra key: "slasher"[0].designing ("true")
          extra key: "slasher"[0].eagle ("AAA4")

          new value: "slasher"[0].asleep[0].crispness (2 -> 22222)
          new value: "slasher"[0].asleep[1].crispness (3 -> 3333)
          new value: "slasher"[0].asleep[1].tattoo (2104.92 -> 34.2)
          new value: "slasher"[0].cruelness (90001 -> 2)
          new value: "slasher"[0].stagnant ("2029-01-01" -> "2029-01-02")
      DIFF
    end

    it "diffs arrays" do
      array1 = [1, 2, 3, 4, 5, 6, 7, 8]
      array2 = [:one, 2, 3, 4, "5", 6, 7.1, 8.0]

      result = diff(array1, array2)

      expect(result.types).to eq([:array, :array])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +0/-0/~4 @@
          new value: [0] (1 -> :one)
          new value: [4] (5 -> "5")
          new value: [6] (7 -> 7.1)
          new value: [7] (8 -> 8.0)
      DIFF
    end

    it "diffs arrays of hashes" do
      array1 = [
        {hash1: "1", n: 45, t: 546},
        {hash1: "2", n: 65, t: 65},
        {hash1: "3", n: 34, t: 64},
        {hash1: "4", n: 87, t: 34},
      ]

      array2 = [
        {hash1: "1", n: 45, t: 546.0},
        {hash1: "22", n: 65, t: 65},
        {hash1: "3", n: 675, t: 64},
        {hash1: "4", n: 87, t: 34},
      ]

      result = diff(array1, array2)

      expect(result.types).to eq([:array, :array])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +0/-0/~3 @@
          new value: [0].t (546 -> 546.0)
          new value: [1].hash1 ("2" -> "22")
          new value: [2].n (34 -> 675)
      DIFF
    end

    it "differentiates symbols and strings in arrays" do
      array1 = [:a, :b, "c"]
      array2 = ["a", :b, :c]

      result = diff(array1, array2)

      expect(result.types).to eq([:array, :array])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +0/-0/~2 @@
          new value: [0] (:a -> "a")
          new value: [2] ("c" -> :c)
      DIFF
    end

    it "differentiates symbols and strings in hash keys" do
      hash1 = {test: "yes", "test" => "yess", "y" => 3}
      hash2 = {"test" => "yes", test: "yess", x: 1}

      result = diff(hash1, hash2)

      expect(result.types).to eq([:hash, :hash])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +1/-1/~2 @@
        missing key: "y" (3)
          extra key: x (1)
          new value: test ("yes" -> "yess")
          new value: "test" ("yess" -> "yes")
      DIFF
    end

    it "differentiates symbols and strings in nested hash keys" do
      hash1 = {
        a: {test: "1234", "test" => "12", "y" => 3},
      }
      hash2 = {
        a: {"test" => "1234", test: "12", x: 1},
      }

      result = diff(hash1, hash2)

      expect(result.types).to eq([:hash, :hash])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +1/-1/~2 @@
        missing key: a."y" (3)
          extra key: a.x (1)
          new value: a.test ("1234" -> "12")
          new value: a."test" ("12" -> "1234")
      DIFF
    end

    it "differentiates symbols and strings in nested hash keys in arrays" do
      array1 = [
        {a: "b", "c" => :d},
        {"vegetate" => "long"},
      ]
      array2 = [
        {a: "c", "c" => :v},
        {vegetate: "long"},
      ]

      result = diff(array1, array2)

      expect(result.types).to eq([:array, :array])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        @@ +1/-1/~2 @@
        missing key: [1]."vegetate" ("long")
          extra key: [1].vegetate ("long")
          new value: [0].a ("b" -> "c")
          new value: [0]."c" (:d -> :v)
      DIFF
    end

    it "produces an empty diff from hashes" do
      hash1 = {
        this: "hash",
        exists: true,
        number: 345,
      }
      hash2 = hash1.dup

      result = diff(hash1, hash2)

      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("")
      expect(result.types).to eq([:hash, :hash])
    end

    it "produces an empty diff from arrays" do
      array1 = [4, 45, "342", "test", 213]
      array2 = array1.dup

      result = diff(array1, array2)

      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("")
      expect(result.types).to eq([:array, :array])
    end
  end

  describe "refusing to diff" do
    it "integers" do
      result = diff(1, 2)

      expect(result.types).to eq([:unknown, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("1 != 2")
    end

    it "floats" do
      result = diff(1.2, 2.6)

      expect(result.types).to eq([:unknown, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("1.2 != 2.6")
    end

    it "nils" do
      result = diff(nil, nil)

      expect(result.types).to eq([:nil, :nil])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("nil == nil")
    end

    it "array and hash" do
      result = diff([1, 2], {bing: :bang, bong: "o"})

      expect(result.types).to eq([:array, :hash])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq('[1, 2] != {:bing=>:bang, :bong=>"o"}')
    end

    it "array and integer" do
      result = diff([1, 2], 5)

      expect(result.types).to eq([:array, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("[1, 2] != 5")
    end

    it "float and integer" do
      result = diff(5634.32, 5)

      expect(result.types).to eq([:unknown, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("5634.32 != 5")
    end

    it "nil and integer" do
      result = diff(nil, 42)

      expect(result.types).to eq([:nil, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("nil != 42")
    end

    it "nil and array" do
      result = diff(nil, [])

      expect(result.types).to eq([:nil, :array])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("nil != []")
    end

    it "string and array" do
      result = diff("hellope", [])

      expect(result.types).to eq([:text, :array])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq('"hellope" != []')
    end

    it "string and hash" do
      result = diff("hellope", {yes: "this is phone"})

      expect(result.types).to eq([:text, :hash])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq('"hellope" != {:yes=>"this is phone"}')
    end

    it "booleans" do
      result = diff(true, false)

      expect(result.types).to eq([:unknown, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq('true != false')

      result = diff(true, true)

      expect(result.types).to eq([:unknown, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq('true == true')

      result = diff(false, false)

      expect(result.types).to eq([:unknown, :unknown])
      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq('false == false')
    end
  end
end
