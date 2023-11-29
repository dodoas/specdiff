module Specdiff::Colorize
  module_function

  def colorize_by_line(string, line_separator = "\n")
    return string if !::Specdiff.config.colorize?

    string.lines(line_separator).map do |line|
      yield(line)
    end.join
  end

  def reset_color(text)
    "\e[0m#{text}"
  end

  def red(text)
    "\e[31m#{text}\e[0m"
  end

  def green(text)
    "\e[32m#{text}\e[0m"
  end

  def yellow(text)
    "\e[33m#{text}\e[0m"
  end

  def blue(text)
    "\e[34m#{text}\e[0m"
  end
end
