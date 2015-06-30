config = -> (k) { Catatau.fetch(k) }

Config = OpenStruct.new(
  jenkins_url:      config[:jenkins_url],
  jenkins_username: config[:jenkins_username],
  jenkins_password: config[:jenkins_password],
  templates:        config[:templates].split(','),
  secret:           config[:secret]
)
