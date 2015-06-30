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

  def open?
    state == 'open'
  end
end
