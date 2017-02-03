#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---
# Author : Romain GEORGES
# type : gem component library
# obj : Dorsal Module
#---

require 'methodic'

# the Dorsal Namespace
module Dorsal

  # module mixin for privates methods for both Controller and ImplementationServer
  # @private
  module Privates

    # method for daemonize blocks
    # @param [Hash] _options the list of options, keys are symbols
    # @option  _options [String] :description the description of the process, use for $0
    # @option  _options [String] :pid_file the pid filenam
    # @yield a process definion or block given 
    # @example usage inline
    #    require 'dorsal/privates'
    #    class Test
    #      include Dorsal::Privates
    #      private :daemonize
    #      def initialize
    #        @loop = Proc::new do 
    #          loop do
    #            sleep 1
    #          end
    #        end
    #      end
    #      
    #      def run
    #        daemonize({:description => "A loop daemon", :pid_file => '/tmp/pid.file'}, &@loop)
    #      end
    #     end
    # 
    # @example usage block
    #    require 'dorsal/privates'
    #    class Test
    #      include Dorsal::Privates
    #      private :daemonize
    #      def initialize
    #      end
    #      
    #      def run
    #        daemonize :description => "A loop daemon", :pid_file => '/tmp/pid.file' do
    #          loop do
    #            sleep 1
    #          end
    #        end
    #      end
    #     end
    # @return [Fixnum] pid the pid of the forked processus 
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
    
    # daemonize wrapper to prevent processus cloning
    # @param [Hash] _options the list of options, keys are symbols
    # @option  _options [String] :description the description of the process, use for $0
    # @option  _options [String] :pid_file the pid filenam
    # @return [Fixnum] pid the pid of the forked processus
    # @yield a process definion or block given 
    # @raise [Dorsal::RingServerError] if pid_file exist or processus with the present description  
    # @example usage inline
    #    require 'dorsal/privates'
    #    class Test
    #      include Dorsal::Privates
    #      private :start
    #      private :daemonize
    #      def initialize
    #        @loop = Proc::new do 
    #          loop do
    #            sleep 1
    #          end
    #        end
    #      end
    #      
    #      def run
    #        start({:description => "A loop daemon", :pid_file => '/tmp/pid.file'}, &@loop)
    #      end
    #     end
    # 
    # @example usage block
    #    require 'dorsal/privates'
    #    class Test
    #      include Dorsal::Privates
    #      private :daemonize
    #      private :start
    #      def initialize
    #      end
    #      
    #      def run
    #        start :description => "A loop daemon", :pid_file => '/tmp/pid.file' do
    #          loop do
    #            sleep 1
    #          end
    #        end
    #      end
    #     end 
    def start(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :description, :pid_file
      options.validate
      raise Dorsal::RingServerError::new('already running, pid file exist') if File::exist?(options[:pid_file])
      raise Dorsal::RingServerError::new('already running, process found') unless `ps aux|grep -v grep |grep '#{options[:description]}'`.empty?
      return daemonize(options) do
        yield
      end
    end

    # stop a running processus 
    # @param [Hash] _options the list of options, keys are symbols
    # @option _options [String] :description the description of the process, use for $0
    # @option _options [String] :pid_file the pid filename
    # @option _options [String] :name the name of the processus (OPTIONAL)
    # @return [TrueClass,FalseClass] true if a service really closed, false otherwise
    # @raise [Dorsal::ServerError] if can't close an existant service
    # @example usage inline
    #   #in the same class
    #   def stop_service
    #     stop :name => 'service', :description => 'A loop daemon', :pid_file => '/tmp/pid.file'
    #   end
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
          raise Dorsal::ServerError::new('Stopping failed') unless system("kill -TERM #{pid} > /dev/null")
        else
          return false unless system("kill -TERM #{pid} > /dev/null")
        end
        return true
      end
    end

    # give the status of a processus 
    # @param [Hash] _options the list of options, keys are symbols
    # @option _options [String] :description the description of the process, use for $0
    # @option _options [String] :pid_file the pid filename
    # @option _options [String] :name the name of the processus (OPTIONAL)
    # @return [TrueClass,FalseClass] true if service running, false otherwise
    # @example usage inline
    #   #in the same class
    #   def service_status
    #     status :name => 'service', :description => 'A loop daemon', :pid_file => '/tmp/pid.file'
    #   end
    def status(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :description, :pid_file
      options.validate
      pid = `COLUMNS=160 ps aux|grep -v grep |grep '#{options[:description]}'|awk '{ print $2}'`
      if pid.empty? then
        return false
      else
        File.open(options[:pid_file],"w"){|f| f.puts pid } unless File::exist?(options[:pid_file])
        return true
      end
    end
  end
end
