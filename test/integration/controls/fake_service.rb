# copyright: 2021, Tracy Holmes & Rosemary Wang

title "security and policy for fake-service"

# Check if the fake-service binary exists
# and its owner is not root.
describe file("/usr/local/bin/fake-service") do
  it { should_not exist }
end

# Ensure that the ubuntu user exists
# in the container
describe user('ubuntu') do
  it { should exist }
end


