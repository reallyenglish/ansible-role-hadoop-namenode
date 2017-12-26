require "infrataster/rspec"
require "capybara"
require "rspec/retry"

ENV["VAGRANT_CWD"] = File.dirname(__FILE__)
ENV["LANG"] = "C"

if ENV["JENKINS_HOME"]
  # rubocop:disable Metrics/LineLength:
  # XXX "bundle exec vagrant" fails to load.
  # https://github.com/bundler/bundler/issues/4602
  #
  # > bundle exec vagrant --version
  # bundler: failed to load command: vagrant (/usr/local/bin/vagrant)
  # Gem::Exception: can't find executable vagrant
  #   /usr/local/lib/ruby/gems/2.2/gems/bundler-1.12.1/lib/bundler/rubygems_integration.rb:373:in `block in replace_bin_path'
  #   /usr/local/lib/ruby/gems/2.2/gems/bundler-1.12.1/lib/bundler/rubygems_integration.rb:387:in `block in replace_bin_path'
  #   /usr/local/bin/vagrant:23:in `<top (required)>'
  #
  # this causes "vagrant ssh-config" to fail, invoked in a spec file, i.e. when
  # you need to ssh to a vagrant host.
  #
  # include the path of bin to vagrant
  vagrant_real_path = `pkg info -l vagrant | grep -v '/usr/local/bin/vagrant' | grep -E 'bin\/vagrant$'| sed -e 's/^[[:space:]]*//'`
  # rubocop:enable Metrics/LineLength:
  vagrant_bin_dir = File.dirname(vagrant_real_path)
  ENV["PATH"] = "#{vagrant_bin_dir}:#{ENV['PATH']}"
end

Infrataster::Server.define(
  :namenode1,
  "192.168.84.101",
  vagrant: true
)

Infrataster::Server.define(
  :namenode2,
  "192.168.84.102",
  vagrant: true
)

Infrataster::Server.define(
  :namenode3,
  "192.168.84.103",
  vagrant: true
)

1.upto(3).each do |i|
  hostname = "datanode#{i}"
  Infrataster::Server.define(
    hostname.to_sym,
    "192.168.84.12#{i}",
    vagrant: true
  )
end

# rubocop:disable Metrics/MethodLength
def fetch(uri_str, limit = 10)
  raise ArgumentError, "too many HTTP redirects" if limit.zero?
  response = Net::HTTP.get_response(URI(uri_str))
  case response
  when Net::HTTPSuccess then
    response
  when Net::HTTPRedirection then
    location = response["location"]
    warn "redirected to #{location}"
    fetch(location, limit - 1)
  else
    raise "HTTP response is not success nor redirect (value: #{response.value})"
  end
end
# rubocop:enable Metrics/MethodLength

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.verbose_retry = true
  config.display_try_failure_messages = true
end
