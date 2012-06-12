if defined?(RSpec) then
  require 'transloadit/rspec/request_spec_helper'
else
  raise "RSpec doesn't appear to be loaded!"
end
