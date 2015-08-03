require './lib/mixpaneltesting/version'

Gem::Specification.new do |s|
  s.name        = 'mixpaneltesting'
  s.version     = MixpanelTesting::VERSION
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

  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'mixpanel_client'
end

