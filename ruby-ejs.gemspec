Gem::Specification.new do |s|
  s.name = "ruby-ejs"
  s.version = "1.2.0"
  s.licenses    = ['MIT']
  s.summary = "EJS (Embedded JavaScript) template compiler"
  s.description = "Compile EJS (Embedded JavaScript) templates in Ruby."

  s.files = Dir["README.md", "LICENSE", "lib/**/*.{rb,js}"]

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "execjs"

  s.authors = ["Jonathan Bracy"]
  s.email = ["jonbracy@gmail.com"]
  s.homepage = "https://github.com/malomalo/ruby-ejs"
end