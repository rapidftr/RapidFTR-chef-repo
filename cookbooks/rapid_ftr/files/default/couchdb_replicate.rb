#!/usr/bin/env ruby
require 'optparse'
require 'uri'
require 'net/http'
require 'rubygems'
require 'json'

local_forwarding_port = '5985'
remote_couch_port = '5984'
local_couch_port = '5984'
ssh_user_and_port = nil
databases = nil
quiet = false
identity_file_option = nil

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"
  opts.separator ""
  opts.separator "Options:"

  opts.on("-s", "--source USER@HOST",
          "Required. User and host from which data should be pulled.") do |o|
    ssh_user_and_port = o
  end

  opts.on("-i", "--identity-file /path/to/file",
          "Private key to use. Defaults to ssh default of ~/.ssh/id_rsa or ~/.ssh/id_dsa") do |identity|
    identity_file_option = "-i #{identity}"
  end

  opts.on("-f", "--forwarding-port 5985",
          "Local port to forward to the origin system.",
          "Default 5985.") do |p|
    local_forwarding_port = p
  end

  opts.on("-l", "--local-couch-port 5984",
          "Local CouchDB port.",
          "Default 5984.") do |p|
    local_couch_port = p
  end

  opts.on("-r", "--remote-couch-port 5984",
          "Remote CouchDB port.",
          "Default 5984.") do |p|
    local_couch_port = p
  end

  opts.on("-d", "--databases x,y,z",
          Array,
          "Required. Comma-separated list of database names to replicate.") do |list|
    databases = list
  end

  opts.on("-q", "--quiet",
          "Be quiet.") do |q|
    quiet = q
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end

parser.parse! ARGV

if ssh_user_and_port.nil? || databases.nil?
  puts "Missing required options."
  puts parser
  exit 1
end

unless quiet
  puts "Replicating #{databases.join(', ')}\n from #{ssh_user_and_port} couch on #{remote_couch_port}\n to local couch on #{local_couch_port} via local port #{local_forwarding_port}."
end

ssh_pid = fork do
  exec "ssh -N #{identity_file_option} -L #{local_forwarding_port}:localhost:#{remote_couch_port} #{ssh_user_and_port}"
end

begin
  sleep 5 # for ssh to get connected

  request = Net::HTTP::Post.new '/_replicate'
  request.content_type = 'application/json'

  databases.each do |database|
    puts database unless quiet
    request.body = {
      "source" => "http://localhost:#{local_forwarding_port}/#{database}",
      "target" => database
      }.to_json
    response = Net::HTTP.new("localhost", local_couch_port).start {|http| http.request(request) }
    puts response.body unless quiet
  end
ensure
  system "kill #{ssh_pid}"
end
