# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)

require "rubocop/rake_task"

RuboCop::RakeTask.new(:lint)

task default: %i[test lint]

require "bigdecimal"
require "bigdecimal/util"

class MakeBytesReadable
  BASE = 1024
  BYTES_AND_STUFF = {
    byte: ["Byte", "Bytes"],
    kb: ["KiB", "KiB"],
    mb: ["MiB", "MiB"],
    gb: ["GiB", "GiB"],
    tb: ["tebibyte", "tebibytes"],
    pb: ["pebibyte", "pebibytes"],
    eb: ["exbibyte", "exbibytes"],
    zb: ["zebibyte", "zebibytes"],
    yb: ["yobibyte", "yobibytes"],
  }
  STORAGE_UNITS = BYTES_AND_STUFF.keys.freeze
  ROUNDING_PRECISION = 3

  def self.call(n)
    bn = BigDecimal(n)

    unit = nil
    if bn.to_i.abs >= BASE
      exponent = calculate_exponent(bn)
      human_size = bn / (BASE**exponent)

      human_number = human_size.round(ROUNDING_PRECISION).to_s("F")
      unit = STORAGE_UNITS[exponent]
    else
      human_number = n.to_i.to_s
      unit = :byte
    end

    human_unit = BYTES_AND_STUFF[unit]
    pluralized_unit = human_size == 1 ? human_unit[0] : human_unit[1]


    "#{human_number} #{pluralized_unit}"
  end

  def self.calculate_exponent(n)
    result = (Math.log(n.abs) / Math.log(BASE)).to_i
    return max if result > STORAGE_UNITS.size - 1
    result
  end
end

desc <<~DESC
  Check how big the ruby gem is when packaged. This helps you avoid pushing \
  bloated packages with unneccessary files in them.
DESC
task :inspect_build do
  output_path = "tmp/sizetest.gem"
  sh "gem build -o #{output_path}"
  bytes = File.size(output_path)
  readable_bytes = MakeBytesReadable.call(bytes)

  puts
  puts "== BUILD SIZE: #{readable_bytes} (#{bytes} bytes) =="
  puts

  unpacking_directory = "tmp/sizetest"
  mkdir_p unpacking_directory

  sh "tar xf #{output_path} --directory #{unpacking_directory}"

  puts
  puts "== THESE FILES WERE INCLUDED IN YOUR BUILD =="
  sh "tar ztf #{unpacking_directory}/data.tar.gz"

  puts
  rm output_path
  rm_r unpacking_directory
end

desc "Run some of the release procedure automatically (that which is automatable)"
task prerelease: %i[test lint inspect_build]
