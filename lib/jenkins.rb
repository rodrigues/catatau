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

  def clear_build_queue(pr)
    jenkins = client
    jobs = jenkins.queue.list.select { |j| j.split('_')[1] == pr.number.to_s }

    jobs.each do |job|
      uri = jenkins.queue.get_details(job)['url']
      abort_queue_job(uri)
    end
  end

  def abort_queue_job(uri)
    api = client.queue.instance_variable_get(:@client)
    api.api_get_request("#{uri}cancelQueue")
  rescue Net::HTTPBadResponse
    nil
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
