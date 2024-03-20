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

    it "produces an empty diff" do
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
    it "diffs hashes" do
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
        b changed (45 => 12)
        c[0] changed (:a => :c)
        c[2] changed (:c => :a)
        missing key: d.e.f[0] (34)
        d.g changed (:l => 6543234)
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

      # maybe there is an opportunity to make the diff intelligently detect the
      # fact that there is nothing in common in large hashes and just provide
      # no diff in that case? since the diff is unlikely to be useful
      expect(result.to_s).to eq(<<~DIFF)
        missing key: amount1 (34235)
        missing key: amount2 (4534)
        missing key: calculated_amount1 (45346)
        missing key: calculated_amount2 (5436345)
        missing key: status ("filled")
        missing key: total1 (45345)
        missing key: total2 (54621)
        new key: "CamelCase" ("TaDa")
        new key: "SCREAMING_SNAKE_CASE" ("TA_DA")
        new key: "UPPERCASE" ("TADA")
        new key: "kebab-case" ("ta-da")
        new key: "lowercase" ("tada")
        new key: "pascalCase" ("taDa")
        new key: "snake_case" ("ta_da")
      DIFF
    end

    it "diffs arrays" do
      array1 = [1, 2, 3, 4, 5, 6, 7, 8]
      array2 = [:one, 2, 3, 4, "5", 6, 7.1, 8.0]

      result = diff(array1, array2)

      expect(result.types).to eq([:array, :array])
      expect(result.empty?).to eq(false)
      expect(result.to_s).to eq(<<~DIFF)
        [0] changed (1 => :one)
        [4] changed (5 => "5")
        [6] changed (7 => 7.1)
        [7] changed (8 => 8.0)
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

      expect(result.to_s).to eq(<<~DIFF)
        [0].t changed (546 => 546.0)
        [1].hash1 changed ("2" => "22")
        [2].n changed (34 => 675)
      DIFF
    end

    it "differentiates symbols and strings in arrays" do
      array1 = [:a, :b, "c"]
      array2 = ["a", :b, :c]

      result = diff(array1, array2)

      expect(result.to_s).to eq(<<~DIFF)
        [0] changed (:a => "a")
        [2] changed ("c" => :c)
      DIFF
    end

    it "differentiates symbols and strings in hash keys" do
      hash1 = {test: "yes"}
      hash2 = {"test" => "yes"}

      result = diff(hash1, hash2)

      expect(result.to_s).to eq(<<~DIFF)
        missing key: test ("yes")
        new key: "test" ("yes")
      DIFF
    end

    it "differentiates symbols and strings in nested hash keys" do
      hash1 = {
        a: {"test" => "1234"},
      }
      hash2 = {
        a: {test: "1234"},
      }

      result = diff(hash1, hash2)

      expect(result.to_s).to eq(<<~DIFF)
        missing key: a."test" ("1234")
        new key: a.test ("1234")
      DIFF
    end

    it "differentiates symbols and strings in nested hash keys in arrays" do
      array1 = [
        {a: "b", "c" => :d},
        {vegetate: "long"},
      ]
      array2 = [
        {"a" => "b", c: :d},
        {vegetate: "long"},
      ]

      result = diff(array1, array2)

      expect(result.to_s).to eq(<<~DIFF)
        missing key: [0].a ("b")
        missing key: [0]."c" (:d)
        new key: [0]."a" ("b")
        new key: [0].c (:d)
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
    end

    it "produces an empty diff from arrays" do
      array1 = [4, 45, "342", "test", 213]
      array2 = array1.dup

      result = diff(array1, array2)

      expect(result.empty?).to eq(true)
      expect(result.to_s).to eq("")
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
      expect(result.to_s).to eq("nil = nil")
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
  end
end
