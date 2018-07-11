Gem::Specification.new do |s|
  s.name = "ejs"
  s.version = "2.0.0"
  s.summary = "EJS (Embedded JavaScript) template compiler"
  s.description = "Compile EJS (Embedded JavaScript) templates in Ruby."

  s.files = Dir["README.md", "LICENSE", "lib/**/*.rb"]

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "execjs"

  s.authors = ["Sam Stephenson"]
  s.email = ["sstephenson@gmail.com"]
  s.homepage = "https://github.com/sstephenson/ruby-ejs/"
end
