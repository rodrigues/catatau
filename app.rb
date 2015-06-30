require 'sinatra'
require 'en/namespace'
require 'jenkins_api_client'
require 'ostruct'
require 'json'

EN.load
Catatau = EN::Namespace.new(:catatau)

lib = File.join(File.dirname(__FILE__), 'lib')
require File.join(lib, 'config')
require File.join(lib, 'pull_request')
require File.join(lib, 'jenkins')
require File.join(lib, 'status')

get '/webhook' do
  'in primis cogitationibus circa generationem animalium, ' +
  'de his omnibus non cogitavi.'
end

post '/webhook' do
  json = JSON.parse(request.body.read)
  pr = PullRequest.new(json)

  if pr.open?
    Jenkins.clear_build_queue(pr)
    Jenkins.build(pr)
    Status.new(pr).boot
  end

  status 200
end

post '/status' do
  # sha and secret
end
