#!/usr/bin/ruby
#simple port scanner by metasplotto

require 'socket' #socket library
require 'timeout'

$host = ARGV[0]
$sport = ARGV[1].to_i
$eport = ARGV[2].to_i   #vars

def help
  puts "#{$0} <target-ip> <start-port> <end-port>"
end

def openport(host,port)
  begin
    
    status = Timeout::timeout(1) {
      aSock = Socket.new(:INET, :STREAM)        #build the socket
      raw = Socket.sockaddr_in(port, host)    
      if aSock.connect(raw)                    #if the socket connects...
        puts "Port: #{port} open!"
      end
    }
  rescue (Errno::ECONNREFUSED) #check if the port is closed
    puts "DEBUG: #{port} Closed"
  rescue (Errno::ETIMEDOUT)
    puts "DEBUG: Timed out"
    
  rescue Timeout::Error
    puts "DEBUG: Timed out"
    
  end
end

if ARGV.length < 3
    help()
else

begin
    while $sport <= $eport
        openport($host,$sport)    #call procedure openport
        $sport += 1                #increase $sport
    end
    
rescue (Interrupt)        #rescue CTRL+C instead of printing a lot of useless errors
    puts "Interrupt!!"
end        #begin - END
end        # IF end

#TODO:
#threads!!!
#service discovery
#buh..!
