# copyright: 2021, Tracy Holmes & Rosemary Wang

title "security and policy for fake-service"

# Check if the fake-service binary exists
# and its owner is not root.
describe file("/usr/local/bin/fake-service") do
  it { should exist }
  its('owner') { should_not eq 'root'}
end

# Ensure that the ubuntu user exists
# in the container
describe user('ubuntu') do
  it { should exist }
  its('groups') { should eq ['ubuntu']}
  its('shell') { should eq '/bin/sh' }
end


