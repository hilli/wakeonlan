#!/usr/bin/env ruby
# $Id: wakeonlan.rb 4 2009-11-01 21:46:25Z hilli $
# Jens Hilligsoe <jens@hilli.dk>, 2009
#
# Based on work by
# Kevin R. Bullock <kbullock@ringworld.org>, K.Kodama <kodama@math.kobe-u.ac.jp>,
# Jose Pedro Oliveira <jpo@di.uminho.pt> and Ico Doornekamp <ico@edd.dhs.org>
#
# Licensed under the Ruby licence

require "socket"

class WakeOnLan

  GEM = "wakeonlan"
  NAME = "WakeOnLan"
  VERSION = "0.0.3"

  attr_reader :socket
  attr_accessor :ethers
  attr_accessor :verbose
  
  # Exceptions
  class AddressException < RuntimeError; end
  class SetupException < RuntimeError; end

  def initialize
    @ethers = "/etc/ethers"
    # Create socket and set options
    @socket = UDPSocket.open
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
    if "".respond_to?(:lines) then # Ruby 1.9 check
      @@Regexp_MAC_addr = Regexp.new( '^' + (('[0-9A-Fa-f]' * 2).lines.to_a * 6).join(':') + '$' )
      @@Regexp_IP_addr = Regexp.new( '^' + ('(([0-9][0-9]?)|([01][0-9][0-9])|(2[0-4][0-9])|(2[0-5][0-5]))'.lines.to_a * 4).join('\.') + '$' )
    else
      @@Regexp_MAC_addr = Regexp.new( '^' + (('[0-9A-Fa-f]' * 2).to_a * 6).join(':') + '$' )
      @@Regexp_IP_addr = Regexp.new( '^' + ('(([0-9][0-9]?)|([01][0-9][0-9])|(2[0-4][0-9])|(2[0-5][0-5]))'.to_a * 4).join('\.') + '$' )
    end
  end

  # Do the waking up bits
  def wake(mac, ip="255.255.255.255", port=9)
    # Validate mac
    raise AddressException, 'Invalid MAC address' unless self.valid_mac?( mac )
    # Validate ip
    raise AddressException, 'Invalid IP address' unless self.valid_ip?( ip )
    # Create Magic Packet
    magic = 0xFF.chr * 6 + (mac.split(/:/).pack("H*H*H*H*H*H*") * 16)
    @socket.connect(ip,port)
    puts "Sending magic packet to #{ip}:#{port} with #{mac}" if @verbose
    3.times{ socket.send(magic,0) }
    return nil
  end

  # Shorthand class method to facilitate WakeOnLan.wake!(MAC) kind of action
  def self.wake!(mac, ip="255.255.255.255", port=9)
    wol = WakeOnLan.new
    wol.wake(resolve_to_mac(mac), ip, port)
    wol.close
    return nil
  end
  
  # Try to resolve the input given to a MAC address. Input can be either a hostname, IP or MAC address
  def resolve_to_mac(input)
    if valid_mac?(input)
      return input
    end
    lookup_in_ethers(input)
  end

  # Given a hostname or IP, look it up in the ethers file and return the associated MAC address
  def lookup_in_ethers(input)
    if File.exist?(@ethers) and File.readable?(@ethers)
      File.open(@ethers,'r') do |f|
        f.each_line do |line|
          next if line.match(/^#/)
          next if line.match(/^\s$/)
          mac, host = line.chomp.split
          if /^#{input}$/.match(host)
            return mac
          end
        end
      end
      return nil
    end
  end

  # MAC address validation
  def valid_mac?(mac)
    if mac =~ @@Regexp_MAC_addr
      true
    else 
      false  
    end
  end

  # IP address validation
  def valid_ip?( ip )
    if ip =~ @@Regexp_IP_addr
      true
    else 
      false
    end
  end

  # Close the socket after use
  def close
    @socket.close
    @socket=""
  end
end # WakeOnLan

