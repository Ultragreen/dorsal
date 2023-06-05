class ServicesDaemon
    include Singleton
    extend Carioca::Injector

    inject service: :logger
    
    

    def initialize 
      logger.info "Starting daemon"
    end
  
    def response(service:, call:, token: )
      wanted = service.to_sym
      raise "refused" unless Authenticator.check! token: token 
      if Carioca::Registry.get.services.keys.include? wanted then
        inject service: wanted
      end
      code_tab  = call.first.split('.')
      code_tab[0] = "#{service.to_s}"
      code = code_tab.join('.')
      res =  with_captured{ eval(code) }
      return res 
    end
  
  
    def with_captured
      original_stdout = $stdout  
      original_stderr = $stderr
      output = StringIO.new
      $stdout = STDProxy.new(source: "STDOUT", target: output)     
      $stderr = STDProxy.new(source: "STDERR", target: output)
      ret = yield
      stdout = $stdout.string
      stderr = $stderr.string
      res  = {returned: ret , output: output.string.split("\n") }.to_json 
  
      return res 
    ensure
       $stdout = original_stdout  
       $stderr = original_stderr
  
    end
   
    
  end
  
  
  
  
  