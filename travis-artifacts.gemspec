Gem::Specification.new do |s|
  s.name        = 'travis-artifacts'
  s.version     = '0.0.2'

  s.description = 'Travis build artifacts tools'
  s.summary     = s.description

  s.homepage    = 'https://github.com/travis-ci/travis-artifacts'
  s.authors     = ['admin@travis-ci.org']
  s.email       = 'admin@travis-ci.org'

  s.add_dependency 'fog'
  s.add_dependency 'faraday'
  s.add_dependency 'faraday_middleware'

  s.add_development_dependency 'rspec'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(/^bin/).map{|f| File.basename(f) }
  s.test_files    = s.files.grep(/^spec/)
  s.require_paths = ['lib']
end
