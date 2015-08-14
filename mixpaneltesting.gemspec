# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mixpaneltesting/version'

Gem::Specification.new do |s|
  s.name        = 'mixpaneltesting'
  s.version     = MixpanelTesting::VERSION
  s.date        = '2015-08-14'
  s.summary     = "Mixpanel integration testing with Selenium"
  s.description = "Mixpanel integration testing with Selenium Driver (local, docker, browserstack compatible)"
  s.authors     = ["Antonio Perez-Aranda Alcaide"]
  s.email       = ['ant30tx@gmail.com']
  s.license       = 'MIT'

  s.files       = [
      "lib/mixpaneltesting.rb",
      "lib/mixpaneltesting/version.rb",
      "lib/mixpaneltesting/selenium.rb",
      "lib/mixpaneltesting/mixpanel.rb",
      "lib/mixpaneltesting/docker.rb",
      "lib/mixpaneltesting/localsite.rb",
      "lib/mixpaneltesting/rspec_context.rb",
  ]
  s.homepage    =
    'http://rubygems.org/gems/mixpaneltesting'
  s.require_paths = ["lib"]

  s.add_dependency('selenium-webdriver', ">= 2.39.0")
  s.add_dependency('mixpanel_client')
  s.add_dependency('docker-api', ">= 1.22.0")
  
  s.add_development_dependency 'dotenv'

end

