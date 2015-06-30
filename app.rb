require 'sinatra'
require 'en/namespace'
require 'jenkins_api_client'
require 'ostruct'
require 'json'
require 'pry'

get '/webhook' do
  'in primis cogitationibus circa generationem animalium, ' +
  'de his omnibus non cogitavi.'
end

post '/webhook' do
  json = JSON.parse(request.body.read)
  pr = PullRequest.new(json)
  puts "pr attributes: #{pr.attributes}"
  Jenkins.build(pr) if pr.opened?
  status 200
end

EN.load

Catatau = EN::Namespace.new(:catatau)

Config = OpenStruct.new(
  jenkins_url:      Catatau.fetch(:jenkins_url),
  jenkins_username: Catatau.fetch(:jenkins_username),
  jenkins_password: Catatau.fetch(:jenkins_password),
  templates:        Catatau.fetch(:templates).split(','),
  secret:           Catatau.fetch(:secret)
)

class PullRequest
  attr_reader :action, :sha, :number, :branch, :state

  def initialize(params)
    @action = params['action']
    @merged = params['pull_request']['merged']
    @sha    = params['pull_request']['head']['sha']
    @number = params['pull_request']['number']
    @branch = params['pull_request']['head']['label'].split(':').last
    @state  = params['pull_request']['state']
  end

  def merged?
    @merged
  end

  def attributes
    {
      action: action,
      sha: sha,
      number: number,
      branch: branch,
      merged: merged?
    }
  end

  %i(opened labeled closed).each do |action|
    define_method("#{action}?") { self.action == action.to_s }
  end
end

module Jenkins
  extend self

  def build(pr)
    jenkins = client

    Config.templates.each do |template|
      name   = job_name(template, pr)
      config = jenkins.job.get_config(template)
      jenkins.job.create_or_update(name, config)
      jenkins.job.build(name, sha: pr.sha)
    end
  end

  def templates
    Config.templates
  end

  def job_name(template, pr)
    branch = pr.branch.gsub('/', '-')
    "pr_#{pr.number}_#{template}_#{branch}"
  end

  def client
    JenkinsApi::Client.new(
      server_url: Config.jenkins_url,
      username:   Config.jenkins_username,
      password:   Config.jenkins_password
    )
  end
end
