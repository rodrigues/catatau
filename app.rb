require 'sinatra'
require 'en/namespace'
require 'jenkins_api_client'
require 'ostruct'
require 'pry'

get '/webhook' do
  'in primis cogitationibus circa generationem animalium, ' +
  'de his omnibus non cogitavi.'
end

post '/webhook' do
  pr = PullRequest.new(params)
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
    @action     = params[:action]
    @merged     = params[:pull_request][:merged]
    @mergeable  = params[:pull_request][:mergeable]
    @sha        = params[:pull_request][:head][:sha]
    @number     = params[:pull_request][:number]
    @branch_url = params[:repo][:branches_url]
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
