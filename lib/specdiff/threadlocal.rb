module Specdiff
  THREADLOCAL_KEY = :__specdiff_threadlocals

  def self.threadlocal
    Thread.current.thread_variable_get(THREADLOCAL_KEY) ||
      Thread.current.thread_variable_set(THREADLOCAL_KEY, {})
  end
end
