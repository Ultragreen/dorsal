require 'drb'
require './lib/dorsal/privates'
require './lib/dorsal/exceptions'

module Dorsal
  class Controller
    
    include Dorsal::Privates
    private :start
    private :stop
    private :status
    
    attr_reader :options

    def initialize(_options = {})
      @options = Methodic::get_options(_options)
      @options.specify_defaults_values :name => 'ringserver',
      :description => 'Dorsal Ring Server', 
      :debug => false, 
      :host => 'localhost', 
      :port => '8686', 
      :dir => '/tmp/dorsal'
      @options.merge
      @options[:dir].chomp!('/')
      @options[:uri] = "druby://#{options[:host]}:#{options[:port]}"
      Dir::mkdir(@options[:dir]) unless File::exist?(@options[:dir])
      @options[:pid_file] = "#{@options[:dir]}/#{@options[:name]}.pid"
      @options[:object] = Dorsal::ImplementationServer::new({ :dir => @options[:dir], :host => @options[:host], :debug => @options[:debug]})
    end
    
    def bind_to_ring
      DRb.start_service
      return DRbObject.new nil, @options[:uri]
    end
    
    def start_ring_server 
      res = start(@options) do
        DRb.start_service(@options[:uri], @options[:object])
        DRb.thread.join
      end
      return res
    end
    
    def stop_ring_server
      ring = self.bind_to_ring
      ring.list_services.keys.each do |service|
        ring.destroy_service :name => service
      end
     return stop @options
    end
    
    def ring_server_status
      return status @options
    end
  end
end
