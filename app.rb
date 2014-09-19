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
  puts "received: #{json}"
  pr = PullRequest.new(json)
  puts "pr attributes: #{pr.attributes}"
  Jenkins.build(pr) if pr.mergeable?
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
  attr_reader :action, :sha, :number

  def initialize(params)
    @action     = params['action']
    @merged     = params['pull_request']['merged']
    @mergeable  = params['pull_request']['mergeable']
    @sha        = params['pull_request']['head']['sha']
    @number     = params['pull_request']['number']
    @branch_url = params['pull_request']['repo']['branches_url']
  end

  def merged?
    @merged
  end

  def mergeable?
    @mergeable
  end

  def branch
    @branch ||= @branch_url.gsub(/\A(.*)\/branches\//, '')
  end

  def attributes
    {
      action: action,
      sha: sha,
      number: number,
      branch_url: @branch_url,
      branch: branch,
      mergeable: mergeable?,
      merged: merged?
    }
  end
end

module Jenkins
  extend self

  def build(pr)
    jenkins = client

    Config.templates.each do |template|
      name   = job_name(template, pr)
      puts "new job name: #{name}"
      config = jenkins.job.get_config(template)
      puts "new job config: #{config}"
      jenkins.job.create_or_update(name, config)
      puts "created job"
      jenkins.job.build(name, sha: pr.sha)
      puts "built job"
    end
  end

  def templates
    Config.templates
  end

  def job_name(template, pr)
    "pr_#{pr.number}_template_#{pr.branch}"
  end

  def client
    JenkinsApi::Client.new(
      server_url: Config.jenkins_url,
      username:   Config.jenkins_username,
      password:   Config.jenkins_password
    )
  end
end
