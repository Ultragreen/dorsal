module Dorsal
  module Privates

    def daemonize(_options)
      options = Methodic::get_options(_options)
      options.specify_presences_of :description, :pid_file
      options.validate
      return yield if options[:debug]
      pid = fork do 
        trap("SIGINT"){ exit! 0 }
        trap("SIGTERM"){ exit! 0 }
        trap("SIGHUP"){ exit! 0 }
        Process.daemon
        $0 = options[:description]
        yield
      end
      File.open(options[:pid_file],"w"){|f| f.puts pid } if options[:pid_file]
      return pid
    end


    def start(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :description, :pid_file
      options.validate
#       unless _options[:name] == 'ringserver' then
#         return false if File::exist?(_options[:pid_file]) 
#         return false if `ps aux|grep ruby|grep -v grep |grep '#{_options[:description]}'`.empty?
#       end
      raise Dorsal::RingServerError::new('already running, pid file exist') if File::exist?(options[:pid_file])
      raise Dorsal::RingServerError::new('already running') unless `ps aux|grep ruby|grep -v grep |grep '#{options[:description]}'`.empty?
      return daemonize options do
        yield
      end
    end

    def stop(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :description, :pid_file
      options.validate
      File::unlink(options[:pid_file]) if File::exist?(options[:pid_file])
      pid = `COLUMNS=160 ps aux|grep ruby|grep -v grep |grep '#{options[:description]}'|awk '{ print $2}'`
      if pid.empty? then
        return false
      else
        if options[:name] == 'ringserver' then
          raise ServerError::new('Stopping failed') unless system("kill -TERM #{pid} > /dev/null")
        else
          return false unless system("kill -TERM #{pid} > /dev/null")
        end
        return true
      end
    end

    def status(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :description, :pid_file
      options.validate
      pid = `COLUMNS=160 ps aux|grep ruby|grep -v grep |grep '#{options[:description]}'|awk '{ print $2}'`
      if pid.empty? then
        return false
      else
        File.open(options[:pid_file],"w"){|f| f.puts pid } unless File::exist?(options[:pid_file])
        return true
      end
    end


  end
end
