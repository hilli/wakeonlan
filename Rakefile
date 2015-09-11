$:.unshift(File.dirname(__FILE__) + "/lib")

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'echoe'
require 'wakeonlan'


# Common package properties
PKG_NAME    = ENV['PKG_NAME']    || WakeOnLan::GEM
PKG_VERSION = ENV['PKG_VERSION'] || WakeOnLan::VERSION
RUBYFORGE_PROJECT = 'wakeonlan'

if ENV['SNAPSHOT'].to_i == 1
  PKG_VERSION << "." << Time.now.utc.strftime("%Y%m%d%H%M%S")
end


Echoe.new(PKG_NAME, PKG_VERSION) do |p|
  p.author        = "Jens Hilligsoe"
  p.email         = "jens@hilli.dk"
  p.summary       = "A Wake On LAN (WOL) client and library."
  p.url           = "http://wakeonlan.rubyforge.com/"
  p.project       = RUBYFORGE_PROJECT
  p.description   = <<-EOD
    WakeOnLAN is a WOL client and library written in pure Ruby.
  EOD
  p.ignore_pattern = [ "nbproject/**/*", "docs/**/*"]
  p.need_zip = true
  #p.has_rdoc = true
  p.files = FileList["{bin,lib,docs}/**/*"].exclude("rdoc").to_a

  p.development_dependencies += ["rake  ~>0.8",
                                 "echoe ~>3.1"]
end


desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r wakeonlan.rb"
end

begin
  require 'code_statistics'
  desc "Show library's code statistics"
  task :stats do
    CodeStatistics.new(["WakeOnLan", "lib"]).to_s
  end
rescue LoadError
  puts "CodeStatistics (Rails) is not available"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
