require 'rubygems'
require 'bundler'
Bundler.require

require './app.rb'

Thread.new do
  loop do
    Jenkins.launch_slave_agents
    sleep 300
  end
end

run Sinatra::Application
