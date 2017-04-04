Gem::Specification.new do |s|
  s.name = "ejs"
  s.version = "1.1.1"
  s.summary = "EJS (Embedded JavaScript) template compiler"
  s.description = "Compile and evaluate EJS (Embedded JavaScript) templates from Ruby."

  s.files = Dir["README.md", "LICENSE", "lib/**/*.rb"]

  s.add_development_dependency "execjs", "~> 0.4"
  s.add_development_dependency "rake", "~> 12.0.0"
  s.add_development_dependency "test-unit", "~> 3.2.3"

  s.authors = ["Sam Stephenson"]
  s.email = ["sstephenson@gmail.com"]
  s.homepage = "https://github.com/sstephenson/ruby-ejs/"
end
