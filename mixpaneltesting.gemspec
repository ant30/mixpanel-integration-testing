require './lib/version'

Gem::Specification.new do |s|
  s.name        = 'mixpaneltesting'
  s.version     = VERSION
  s.date        = '2015-08-03'
  s.summary     = "Mixpanel integration testing with Selenium"
  s.description = "Mixpanel integration testing with Selenium Driver (local, docker, browserstack compatible)"
  s.authors     = ["Antonio Perez-Aranda Alcaide"]
  s.email       = 'ant30tx@gmail.com'
  s.files       = [
      "lib/version.rb",
      "lib/mixpaneltesting.rb",
  ]
  s.homepage    =
    'http://rubygems.org/gems/mixpaneltesting'
  s.license       = 'MIT'
end

