require 'drb'
require './lib/dorsal/privates'

module Dorsal
  class ImplementationServer
    
    include DRbUndumped
    include Dorsal::Privates
    attr_accessor :data

    def initialize(_options = {})
      @options = Methodic::get_options(_options)
      @options.specify_defaults_values :name => 'ringserver',
      :host => 'localhost',
      :debug => false,
      :dir => '/tmp/dorsal'
      @options.merge
      @data ={}
    end

    def start_service(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :name, :description, :object
      options.validate
      unless @data.include?(options[:name]) then
      options[:pid_file] = "#{@options[:dir]}/service-#{options[:name]}.pid"
      options[:uri] = "druby://#{@options[:host]}:#{get_free_port(40000,50000)}"
        @data[options[:name]] = { :description => options[:description] , :pid_file => options[:pid_file], :uri => options[:uri] }
        return start(options) do
          require 'drb'
          DRb.start_service(options[:uri], options[:object])
          DRb.thread.join
        end
      else
        return false
      end 
    end
    
    def destroy_service(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :name
      options.validate
      if @data.include? options[:name] then
        options[:pid_file] = @data[options[:name]][:pid_file]
        options[:description] = @data[options[:name]][:description]
        if stop(options) then
          @data.delete(options[:name])  
          return true
        end
        return false
      end
      return false
    end

    def bind_to_service(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :name
      options.validate
      DRb.start_service
      return DRbObject.new nil, @data[options[:name]][:uri]
    end

    def list_services
      return @data
    end

    private
    def get_free_port(_start,_end)
      list = IO.popen("netstat -an|grep tcp|awk '{ print $4}'").readlines.map!{|item| item.chomp! ; item = item.split('.').last}
      _start.upto(_end) do |port|
        return port unless list.include?(port.to_s)
      end
      return false
    end
    
  end
end
