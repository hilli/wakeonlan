require File.dirname(__FILE__) + '/../lib/wakeonlan'
require 'test/unit'

class TestWakeOnLan < Test::Unit::TestCase
  
  def setup
    @wol = WakeOnLan.new
    @wol.ethers = File.dirname(__FILE__) + "/ethers"
  end
  
  def teardown
    @wol.close
  end
  
  def test_lookup_in_ethers
    assert_equal("00:25:4b:b0:98:8e", @wol.lookup_in_ethers("hilli")) 
  end
  
  def test_valid_mac
    assert(@wol.valid_mac?("00:25:4b:b0:98:8e"), "Valid MAC is an invalid MAC")
    assert(!@wol.valid_mac?("0:25:4b:b0:98:8e"), "Invalid MAC is a valid MAC")
    assert(!@wol.valid_mac?("00:25:4b:b0:98:8G"), "Invalid MAC is a valid MAC")
  end
  
  def test_valid_ip
    assert(@wol.valid_ip?("10.0.0.111"), "Should be valid IP")
    assert(!@wol.valid_ip?("10.0.0.256"), "Should NOT be valid IP")
    assert(!@wol.valid_ip?("hilli"), "Should NOT be valid IP")
  end
  
  def test_resolve_to_mac
    assert_equal("00:25:4b:b0:98:8e", @wol.resolve_to_mac("00:25:4b:b0:98:8e"))
    assert_equal("00:25:4b:b0:98:8e", @wol.resolve_to_mac("hilli"))
    assert_equal("00:25:4b:b0:98:8e", @wol.resolve_to_mac("10.0.0.111"))
    assert_equal(nil, @wol.resolve_to_mac("na-host"))    
  end
  
  def test_wake
    assert_equal(nil, @wol.wake("00:25:4b:b0:98:8e"))
    assert_equal(nil, @wol.wake("00:25:4b:b0:98:8e","10.0.0.255",9))
  end
  
end