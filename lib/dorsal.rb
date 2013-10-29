#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---# Author : Romain GEORGES
# type : gem component library
# obj : Dorsal Module
#---
require "dorsal/version"
require 'rubygems'
require 'methodic'
require 'drb/drb'
require 'dorsal/privates'
require 'dorsal/exceptions'
require 'dorsal/implementation'
require 'dorsal/controller'

# module Dorsal
# @author Romain GEORGES <romain@ultragreen.net>
# @see http://www.ultragreen.net/projects/dorsal
# @version (See Dorsal::VERSION)
# @note this module is a namespace Dorsal 
module Dorsal

  # the default dir where write pid files
  DEFAULT_DIR  = '/tmp/dorsal'

  # the default host name shared between Ring Server and DRb hosted services
  DEFAULT_HOST = 'localhost'
  
  # the default port of the Ring Server
  DEFAULT_PORT = '8686' 

  # the default shortname of the ringserver 
  DEFAULT_RINGSERVER_NAME = 'ringserver'

  # the default long description of the ring Server
  DEFAULT_RINGSERVER_DESCRIPTION = 'Dorsal Ring Server'
  
  # the default debug status
  DEFAULT_DEBUG = false


end











