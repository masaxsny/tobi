guard 'rspec', cli: '-c', all_after_pass: false, all_on_start: false do
  watch(%r{spec/.+_spec\.rb$})
  watch(%r{^lib/tobi/(.+)\.rb$}) {|m| "spec/#{m[1]}_spec.rb"}
  watch(%r{^lib/tobi\.rb}) { "spec" }
end

