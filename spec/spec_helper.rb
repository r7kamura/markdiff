RSpec.configure do |config|
  config.filter_run :focus
  config.disable_monkey_patching!
  config.run_all_when_everything_filtered = true
end
