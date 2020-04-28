require 'promise'

module Async
  class Task
    def initialize

    end

    def js_promise=(js_promise)
      @js_promise = js_promise
    end
=begin
    def wait(promise, &block)
      if block
        promise.then(&block)
      end
    end
=end
  end
end

module Kernel
  def Async
    raise "Async must be called with block." unless block_given?

    yield
    # promise = Promise.new

    # js_promise = %x(
    #   async function() {
    #     #{yield}
    #     #{promise.resolve}
    #   }();
    # )

    # promise.always #{|callback| %x(js_promise.then) }
  end
end
