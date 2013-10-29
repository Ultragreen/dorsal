#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---
# Author : Romain GEORGES
# type : gem component library
# obj : Dorsal Module
#---
require 'drb'
require 'dorsal/privates'

# the dorsal namespace
module Dorsal
  
  # the Ring Server DRbObject Implementation
  # @note should NOT be instantiate
  # @note this classe is made to be instantiate as a ring server 
  # @private
  class ImplementationServer
    
    include DRbUndumped
    include Dorsal::Privates
    
    # @attr_reader [Hash] data the internal Hash of the ring server
    # @note for debug only
    attr_reader :data
    
    # the contructor of the Ring Server
    # @param [Hash] _options the params of the constructor, keys must be symbols
    # @note :description (default) 'Dorsal::DEFAULT_RINGSERVER_DESCRIPTION'
    # @note :debug (default) 'Dorsal::DEFAULT_DEBUG'
    # @note :host (default) 'Dorsal::DEFAULT_HOST'
    # @note :port (default) 'Dorsal::DEFAULT_PORT'
    # @note :dir (default) 'Dorsal::DEFAULT_DIR'
    # @note :name (default) 'Dorsal::DEFAULT_RINGSERVER_NAME'
    # @note :uri rule 'druby://(:host):(:port)'                                                                                                                                  
    # @note :pid_file rule '(:dir)/(:name).pid' 
    # @option _options [String] :description the description of ring server 
    # @option _options [TrueClass,FalseClass] :debug the deubg mode  
    # @option _options [String] :host the host for ring server and services
    # @option _options [String] :port the port for the ring server
    # @option _options [String] :dir the writable path for pids files
    # @option _options [String] :name the ring server name
    # @option _options [String] :uri the defined uri for ring server
    # @option _options [String] :pid_file the defined pid_file for ring server
    # @note DO NOT USE DIRECTLY
    def initialize(_options = {})
      @options = Methodic::get_options(_options)
      @options.specify_defaults_values :name => 'ringserver',
      :host => 'localhost',
      :debug => false,
      :dir => '/tmp/dorsal'
      @options.merge
      @data ={}
    end


    # start a service from the ring server
    # @return [Fixnum,FalseClass] the pid of the process who host the DRb service, false if already started
    # @param [Hash] _options the params of the constructor, keys must be symbols
    # @option _options [String] :name the name of the service
    # @option _options [String] :description the long name of the service, use for $0 
    # @option _options [Object] :object an object to be served by DRb 
    # @note access by Dorsal::Controller::new.bind_to_ring.start_service
    # @example usage
    #   Dorsal::Controller::new.bind_to_ring.start_service :name => 'service', :description => 'a service', :object => MyService::new
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
          options[:object].extend DRb::DRbUndumped
          DRb.start_service(options[:uri], options[:object])
          DRb.thread.join
        end
      else
        return false
      end 
    end
    
    # stop a service in the ring 
    # @return [TrueClass,FalseClass] true if really stop, false if already down
    # @param [Hash] _options the params of the constructor, keys must be symbols
    # @option _options [String] :name the name of the service
    # @note access by Dorsal::Controller::new.bind_to_ring.destroy_service
    # @example usage
    #   Dorsal::Controller::new.bind_to_ring.destroy_service :name => 'service'
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


    # bind to a service from the ring server
    # @return [DRbObject,nil] the Distributed Service, nil if service not in the Ring
    # @param [Hash] _options the params of the constructor, keys must be symbols
    # @option _options [String] :name the name of the service
    # @note access by Dorsal::Controller::new.bind_to_ring.bind_to_service
    # @example usage
    #   Dorsal::Controller::new.bind_to_ring.bind_to_service :name => 'service'
    def bind_to_service(_options = {})
      options = Methodic::get_options(_options)
      options.specify_presences_of :name
      options.validate
      if list_services.include?(options[:name]) then
        DRb.start_service
        return DRbObject.new nil, @data[options[:name]][:uri]
      else
        return nil
      end
    end

    # list the services from the ring server
    # @return [Hash] the structured list of services in the ring
    # @note access by Dorsal::Controller::new.bind_to_ring.list_services
    # @example usage
    #   Dorsal::Controller::new.bind_to_ring.list_services
    def list_services
      return @data
    end

    private
    # return a free TCP port in range
    # @param [Fixnum,String] _start the first port (default 40000)
    # @param [Fixnum,String] _end the last port (default 50000)
    # @return [fixnum, FalseClass] the port or false if no port found
    def get_free_port(_start=40000,_end=50000)
      list = IO.popen("netstat -an|grep tcp|awk '{ print $4}'").readlines.map!{|item| item.chomp! ; item = item.split('.').last}
      _start.upto(_end) do |port|
        return port unless list.include?(port.to_s)
      end
      return false
    end
    
  end
end
