# coding: utf-8

Gem::Specification.new do |spec|
  spec.name        = 'activerecord-jdbcas400-adapter'
  spec.version     = '1.3.18'
  spec.platform    = Gem::Platform::RUBY
  spec.authors = ['Nick Sieger, Ola Bini, Pierrick Rouxel and JRuby contributors']
  spec.description = %q{Install this gem to use AS/400 with JRuby on Rails.}
  spec.email = %q{nick@nicksieger.com, ola.bini@gmail.com}

  spec.homepage = %q{https://github.com/pierrickrouxel/activerecord-jdbcas400-adapter}
  spec.rubyforge_project = %q{jruby-extras}
  spec.summary = %q{AS/400 JDBC adapter for JRuby on Rails.}
  spec.license = ''

  spec.require_paths = ['lib']
  spec.files = [
    'Rakefile', 'README.md', 'LICENSE.txt',
    *Dir['lib/**/*'].to_a
    ]
  spec.test_files = *Dir['test/**/*'].to_a

  spec.add_dependency 'activerecord', '>= 3.0.0'
  spec.add_dependency 'activerecord-jdbc-adapter', '>= 1.3.17'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'test-unit'
end
