#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---
# Author : Romain GEORGES
# type : gem component library
# obj : Dorsal Module
#---
require 'drb'
require 'methodic'
require 'dorsal/privates'
require 'dorsal/exceptions'

# the Dorsal namespace
module Dorsal
  # the Controller Class, provide access and control of the Ring Server and services, via the Ring Server
  # @example usage
  #   dorsal = Dorsal::Controller::new
  #   # or 
  #   dorsal = Dorsal::Contoller::new :host => 'dorsal.example.com', 
  #                                   :port => "8888", :dir => '/a/writable/path', :description => 'My Own Dorsal Ring Server'
  class Controller
    
    # use shared privates
    include Dorsal::Privates
    private :start
    private :stop
    private :status
    

    # @example read
    #   dorsal = Dorsal::Controller::new
    #   p dorsal.options                                                                                                                                                             
    # @attr_reader [Hash] options a hash table of all structured options of Dorsal
    attr_reader :options

    # contructor for Dorsal::Controller
    # @param [Hash] _options (all options are optionals
    # @note see default values from Dorsal namespace Constants 
    # @option _options [String] :name the name of the ringserver instance
    # @option _options [String] :description the detail name of the the ring server, use for $0
    # @option _options [String] :port the port where to bind ring server
    # @option _options [String] :host the host name share between ring server and hosted DRb services
    # @option _options [String] :dir a writable path where to write pid files and more.
    # @option _options [TruClass,FalseClass] :debug to run Dorsal Ring server in foreground, with more traces 
    # @example usage
    #   dorsal = Dorsal::Controller::new
    #   # or 
    #   dorsal = Dorsal::Contoller::new :host => 'dorsal.example.com', 
    #                                   :port => "8888", :dir => '/a/writable/path', :description => 'My Own Dorsal Ring Server'
    def initialize(_options = {})
      @options = Methodic::get_options(_options)
      @options.specify_defaults_values :description => Dorsal::DEFAULT_RINGSERVER_DESCRIPTION, 
      :debug => Dorsal::DEFAULT_DEBUG, 
      :host => Dorsal::DEFAULT_HOST, 
      :port => Dorsal::DEFAULT_PORT, 
      :dir => Dorsal::DEFAULT_DIR
      @options.merge
      @options[:dir].chomp!('/')
      @options[:name] = Dorsal::DEFAULT_RINGSERVER_NAME
      @options[:uri] = "druby://#{options[:host]}:#{options[:port]}"
      Dir::mkdir(@options[:dir]) unless File::exist?(@options[:dir])
      @options[:pid_file] = "#{@options[:dir]}/#{@options[:name]}.pid"
      @options[:object] = Dorsal::ImplementationServer::new({ :dir => @options[:dir], :host => @options[:host], :debug => @options[:debug]})
    end
    
    # accessor to ring server if up
    # @return [DRbObject, nil] the ring server Drb Object if Up or nil
    # @example usage
    #   dorsal = Dorsal::Controller::new
    #   dorsal.start_ring_server
    #   ring = dorsal.bin_to_ring
    def bind_to_ring
      if ring_server_status then
        DRb.start_service
        return DRbObject.new nil, @options[:uri]
      else
        return nil
      end
    end
    
    # start the ring server if not
    # @return [Fixnum, FalseClass] the pid of the ring server or false if already start
    # @example usage
    #   dorsal = Dorsal::Controller::new
    #   dorsal.start_ring_server #=> a Fixnum for the PID
    #   dorsal.start_ring_server #=> false
    def start_ring_server 
      unless ring_server_status then
          res = start(@options) do
            DRb.start_service(@options[:uri], @options[:object])
            DRb.thread.join
          end
        return res      
      else
        return false
      end
      
    end
    
    # stop the ring server if up
    # @return [TrueClass, FalseClass] true if really shutdown, false otherwise
    # @example usage
    #   dorsal = Dorsal::Controller::new
    #   dorsal.start_ring_server #=> a Fixnum for the PID
    #   dorsal.stop_ring_server #=> true
    #   dorsal.stop_ring_server #=> false
    def stop_ring_server
      if ring_server_status then
        ring = self.bind_to_ring
        ring.list_services.keys.each do |service|
          ring.destroy_service :name => service
        end
        return stop @options
      else
        return false
      end
    end
    
    # return the running status of the ring server
    # @return [TrueClass, FalseClass] true if up, false if down
    # @example usage
    #   dorsal = Dorsal::Controller::new
    #   dorsal.start_ring_server #=> a Fixnum for the PID
    #   dorsal.ring_server_status #=> true
    #   dorsal.stop_ring_server #=> true
    #   dorsal.ring_server_status #=> false
    def ring_server_status
      return status @options
    end
  end
end
