require 'sinatra'
require 'en'
require 'jenkins_api_client'
require 'ostruct'

Catatau = EN::Namespace.new(:catatau)

Config = OpenStuct.new(
  jenkins_url:      Catatau.fetch(:jenkins_url),
  jenkins_username: Catatau.fetch(:jenkins_username),
  jenkins_password: Catatau.fetch(:jenkins_password),
  templates:        Catatau.fetch(:templates).split(',')
)

def jenkins_client
  JenkinsApi::Client.new(
    server_url: Config.jenkins_url,
    username:   Config.jenkins_username,
    password:   Config.jenkins_password
  )
end

get '/webhook' do
  'in primis cogitationibus circa generationem animalium, ' +
  'de his omnibus non cogitavi.'
end

post '/webhook' do
end
