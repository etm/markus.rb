Gem::Specification.new do |s|
  s.name             = "markus"
  s.version          = "4.0.26"
  s.platform         = Gem::Platform::RUBY
  s.license          = "LGPL-3.0"
  s.summary          = "MarkUS - Markup UnderScore. Quick n' dirty templating in the spirit of markaby."

  s.description      = "MarkUS - Markup UnderScore. Quick n' dirty templating in the spirit of markaby."

  s.files            = Dir['{example/**/*,lib/*}'] + %w(COPYING Changelog Rakefile markus.gemspec README.md AUTHORS TODO)
  s.require_path     = 'lib'
  s.extra_rdoc_files = ['README.md']
  s.test_files       = Dir['{test/smartrunner.rb,test/tc_*.rb,test/*.mt_}']

  s.required_ruby_version = '>=1.9.3'

  s.authors          = ['Juergen eTM Mangler']
  s.email            = 'juergen.mangler@gmail.com'
  s.homepage         = 'https://github.com/etm/markus.rb'

  s.add_runtime_dependency 'minitest',  '~> 5.8'
  s.add_runtime_dependency 'escape_utils',  '~> 1.2'
end
