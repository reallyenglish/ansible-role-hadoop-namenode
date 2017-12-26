require "infrataster/rspec"
require "capybara"

ENV["VAGRANT_CWD"] = File.dirname(__FILE__)
ENV["LANG"] = "C"

if ENV["JENKINS_HOME"]
  # rubocop:disable Metrics/LineLength
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
  # rubocop:enable Metrics/LineLength
  vagrant_bin_dir = File.dirname(vagrant_real_path)
  ENV["PATH"] = "#{vagrant_bin_dir}:#{ENV['PATH']}"
end

Infrataster::Server.define(
  :namenode,
  "192.168.84.100",
  vagrant: true
)

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

# rubocop:disable Metrics/AbcSize,Metrics/MethodLength
def retry_and_sleep(options = {})
  opts = {
    tries: 10,
    sec: 10,
    on: [Exception],
    verbose: false
  }.merge(options)
  tries = opts[:tries]
  sec = opts[:sec]
  on = opts[:on]
  verbose = opts[:verbose]
  i = 1
  begin
    yield
  rescue *on => e
    warn format("rescue an excpetion %s", e.class) if verbose
    warn e.message if verbose
    if (tries -= 1) > 0
      warn format("retrying (remaining: %d)", tries)
      warn format("sleeping %d sec", sec * i) if verbose
      sleep sec * i
      i += 1
      retry
    end
  end
end
# rubocop:enable Metrics/AbcSize,Metrics/MethodLength

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
