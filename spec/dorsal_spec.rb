#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---
# Author : Romain GEORGES
# type : Rspec 
# obj : Dorsal Spec
#---
require 'dorsal'
require './spec/samples/dummy'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :should
  end
  config.mock_with :rspec do |c|
    c.syntax = :should
  end

  if $stdout.isatty then
    config.color = true
    config.tty = true
  end
  config.formatter = :documentation # :progress, :html, :textmate
end



describe "Dorsal" do
  before :all do
    File::unlink('/tmp/dorsal/ringserver.pid') if File::exist?('/tmp/dorsal/ringserver.pid')
    pid = `ps aux|grep ruby|grep -v grep |grep 'Dorsal Ring Server'|awk '{ print $2}'`
    unless pid.empty? then
      res = `kill -TERM #{pid.chomp}`
    end
    $controller = Dorsal::Controller::new
  end

  subject { Dorsal }
  it { should be_an_instance_of Module}
  context "Dorsal::Controller" do
    subject { $controller }
    it { should be_an_instance_of Dorsal::Controller } 
    context "#initialize" do

    end
    context "Attributs accessor" do
      context "#options (RO)" do
        it { should respond_to :options }
        it { should_not respond_to :options= }
        it { subject.options[:debug].should eq false }
        it { subject.options[:uri].should eq "druby://localhost:8686" }
        it { subject.options[:object].should be_an_instance_of Dorsal::ImplementationServer }
        it { subject.options[:pid_file].should eq "/tmp/dorsal/ringserver.pid" }
        it { subject.options[:name].should eq "ringserver" }
        it { subject.options[:description].should eq "Dorsal Ring Server" }
      end
    end
    context "Instance Methods" do
      context "#start_ring_server" do
        it { should respond_to :start_ring_server }
        it { subject.start_ring_server.should be_an_instance_of Fixnum }
        it "should return false if try to start twice" do
          subject.start_ring_server.should be false
        end
        it "should exist an instance process of the Ring server" do 
          pid = `ps aux|grep ruby|grep -v grep |grep 'Dorsal Ring Server'|awk '{ print $2}'`.chomp
          pid.should_not be_empty
        end
        
      end
      
      context "#bind_to_ring_server" do
        it { should respond_to :bind_to_ring }
        it "should be possible to bing distributed Ring Server" do
          $ring = subject.bind_to_ring
        end
        context "Ring server Instance" do
          it "should be an Instance of DRb::DRbObject" do 
            $ring.should be_an_instance_of DRb::DRbObject
          end
          it "should Ring server respond to start_service" do
            $ring.should respond_to :start_service 
          end
          it "should start a service" do 
            $ring.start_service({ :name => 'dummy', :object => Dummy::new, :description => 'A dummy distributed service' }).should  > 0
          end
          it "should exist an instance process of dummy service" do 
            pid = `ps aux|grep ruby|grep -v grep |grep 'A dummy distributed service'|awk '{ print $2}'`.chomp
            pid.should_not be_empty
          end
          it "should Ring server respond to list_services" do
            $ring.should respond_to :list_services 
          end
          it "should list_services return a Hash" do
            $ring.list_services.should be_an_instance_of Hash
          end
          it "should list_services include 'dummy' service" do
            $ring.list_services.should include 'dummy'
            $ring.list_services['dummy'][:description].should eq 'A dummy distributed service'
            $ring.list_services['dummy'][:pid_file].should eq '/tmp/dorsal/service-dummy.pid'
            $ring.list_services['dummy'][:uri].should =~  /druby:\/\/localhost:\d+/
          end
          it "should exist pid_file : /tmp/dorsal/service-dummy.pid" do
            File::exist?('/tmp/dorsal/service-dummy.pid').should be true
          end
          it "should ring server respond to bind_to_service" do
            $ring.should respond_to :bind_to_service 
          end
          it "should bind the dummy service" do
            $dummy = $ring.bind_to_service :name => 'dummy'
            $dummy.should be_an_instance_of DRb::DRbObject
            $dummy.test.should eq 'OK'
          end
          it "should have a running daemon instance of the service dummy" do
            pid = `ps aux|grep ruby|grep -v grep |grep 'A dummy distributed service'|awk '{ print $2}'`.chomp
            pid.should_not be_empty
          end

          it "should ring server respond to destroy_service" do
            $ring.should respond_to :destroy_service 
            
          end
         
          it "should be possible to stop the dummy_service" do
            res = $ring.destroy_service({ :name => 'dummy'})
            res.should be true
            $ring.list_services.should be_empty
            
          end
          it "should not exist pid_file : /tmp/dorsal/service-dummy.pid" do
            File::exist?('/tmp/dorsal/service-dummy.pid').should be false
          end

          it "should return false if trying to stop again the dummy_service" do
            $ring.destroy_service({ :name => 'dummy'}).should be false
          end


        end
      end
      context "#ring_server_status(running)" do
        it { should respond_to :ring_server_status }
        it "should respond true" do
          subject.ring_server_status.should be true
        end
      end
      
      context "#stop_ring_server" do
        it "should re-start a service dummy for testing auto_destroy when stop Ring Server" do 
          $ring.start_service({ :name => 'dummy', :object => Dummy::new, :description => 'A dummy distributed service' }).should  > 0
        end
        it { should respond_to :stop_ring_server }
        it { subject.stop_ring_server.should eq true }
        it "should no longer exist an instance process of the Ring server" do 
          pid = `ps aux|grep ruby|grep -v grep |grep 'Dorsal Ring Server'|awk '{ print $2}'`.chomp
          pid.should be_empty
        end
        it "should not exist an instance process of dummy service" do 
          pid = `ps aux|grep ruby|grep -v grep |grep 'A dummy distributed service'|awk '{ print $2}'`.chomp
          pid.should be_empty
        end
        it "should not exist pid_file : /tmp/dorsal/service-dummy.pid" do
          File::exist?('/tmp/dorsal/service-dummy.pid').should be false
        end
       end

      context "#ring_server_status(shutdown)" do
        it "should respond false" do
          subject.ring_server_status.should be false
        end
      end

    end
  end
end
