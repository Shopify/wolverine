# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wolverine/version"

Gem::Specification.new do |s|
  s.name        = "wolverine"
  s.version     = Wolverine::VERSION
  s.authors     = ["Burke Libbey"]
  s.email       = ["burke@burkelibbey.org"]
  s.homepage    = ""
  s.summary     = %q{Wolverine provides a simple way to run server-side redis scripts from a rails app}
  s.description = %q{Wolverine provides a simple way to run server-side redis scripts from a rails app}

  s.rubyforge_project = "wolverine"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'redis'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
end
