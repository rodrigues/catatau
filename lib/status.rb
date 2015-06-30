class Status
  attr_reader :pr

  def initialize(pr)
    @pr = pr
  end

  def boot
    Config.templates.each do |template|
    end
  end
end
