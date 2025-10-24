# frozen_string_literal: true

require_relative "lib/fat_date/version"

Gem::Specification.new do |spec|
  spec.name = "fat_date"
  spec.version = FatDate::VERSION
  spec.authors = ["Daniel E. Doherty"]
  spec.email = ["ded@ddoherty.net"]

  spec.summary = "Useful extensions to the Date class."
  spec.description = <<~DESC
    FatDate provides useful extensions to the Date class including a way to
    specify dates via a number of rich 'specs', strings that allow specifying
    dates using calendar-based concepts, such as years, quarters, months,
    semimonths, biweeks, weeks, and days.  Also, provide methods for determining
    whether a given Date is a federal or NYSE holidays, and more.
  DESC
  spec.homepage      = 'https://github.com/ddoherty03/fat_date.git'
  spec.license       = 'MIT'
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ spec/ .git .github Gemfile])
    end
  end
  # spec.bindir = "exe"
  spec.executables   = spec.files.grep(%r{^bin/easter}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'activesupport'
  spec.add_dependency 'fat_core'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
