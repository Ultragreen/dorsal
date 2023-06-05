# frozen_string_literal: true

require_relative "dorsal/version"
require 'carioca'

Carioca::Registry.configure do |spec|
  spec.filename = './config/carioca.registry'
  spec.debug = true
  spec.init_from_file = true
  spec.log_file = '/tmp/test.rge'
  spec.config_file = './config/settings.yml'
  spec.config_root = :dorsal
  spec.environment = :development
  spec.default_locale = :en
  spec.log_level = :debug
  spec.output_mode = :dual
  spec.output_emoji = true
  spec.output_colors = true
  spec.locales_load_path << Dir["#{File.expand_path('./config/locales')}/*.yml"]
  spec.debugger_tracer = :output
end



logger = Carioca::Registry.get.get_service name: :logger
logger.info "Initialisation of Dorsal"


class Service

  def initialize
    puts 'init'
  end

  def action(*args,  &block)
    $stderr.puts 'action'
    puts args
    block.call
    $stderr.puts 'end'
    return 'myret'
  end
  
end
require_relative 'dorsal/dependencies'
