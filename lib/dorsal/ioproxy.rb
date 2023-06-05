class STDProxy < IO
    def initialize(source: "STDOUT", target:)
      @source = source
      @target = target
    end
    def puts(*args)
      tagged_args = args.map { |arg| "#{@source}:#{arg}" }
      @target.puts(*tagged_args)
    end
  
    def method_missing(method, *args, &block)
      @target.send(method, *args, &block)
    end
end