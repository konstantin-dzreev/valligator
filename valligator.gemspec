Gem::Specification.new do |spec|
  spec.name                  = 'valligator'
  spec.version               = File.read("VERSION").strip
  spec.author                = 'Konstantin Dzreev'
  spec.email                 = 'k.dzreyev@gmail.com'
  spec.platform              = Gem::Platform::RUBY
  spec.license               = 'MIT'
  spec.summary               = 'Ruby objects validator'
  spec.description           = 'Allows one to implement object validations without writing too much code'
  spec.homepage              = 'https://github.com/konstantin-dzreev/valligator'
  spec.files                 = Dir['README.md', 'VERSION', 'HISTORY.md', 'Gemfile', 'Rakefile', '{lib,test}/**/*']
  spec.require_paths         = 'lib'
  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency 'minitest'
end
