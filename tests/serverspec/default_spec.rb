require "spec_helper"
require "serverspec"
require "nokogiri"

package = "hadoop"
extra_package = []

service = "namenode"
config_dir = "/etc/hadoop"
user    = "hdfs"
group   = "hadoop"
ports   = [50_070]
log_dir = "/var/log/hadoop"
db_dir  = "/var/db/hadoop"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  package = "hadoop2"
  extra_package = ["py27-lxml", "zookeeper"]
  config_dir = "/usr/local/etc/hadoop"
  default_group = "wheel"
end

describe package(package) do
  it { should be_installed }
end

extra_package.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe file("#{config_dir}/slaves") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  its(:content) { should match(/^localhost$/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file("#{config_dir}/dfs_hosts") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  # empty
end

describe file("#{db_dir}/dfs/name") do
  it { should exist }
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file("#{config_dir}/core-site.xml") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  describe "property" do
    let(:doc) { Nokogiri::XML(subject.content) }
    {
      "fs.defaultFS" => "hdfs://localhost:8020/",
      "hadoop.tmp.dir" => "/var/db/hadoop",
      "io.file.buffer.size" => "131072"
    }.each do |k, v|
      describe k do
        it { expect(doc.xpath("//property[name='#{k}']/value").text).to eq v }
      end
    end
  end
end

describe file("#{config_dir}/hdfs-site.xml") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  describe "property" do
    let(:doc) { Nokogiri::XML(subject.content) }
    {
      "dfs.namenode.name.dir" => "file:///var/db/hadoop/dfs/name",
      "dfs.blocksize" => "268435456",
      "dfs.namenode.handler.count" => "100",
      "dfs.datanode.data.dir" => "file:///var/db/hadoop/dfs/data"
    }.each do |k, v|
      describe k do
        it { expect(doc.xpath("//property[name='#{k}']/value").text).to eq v }
      end
    end
  end
end

describe file("#{config_dir}/mapred-site.xml") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  describe "property" do
    let(:doc) { Nokogiri::XML(subject.content) }
    {
      "mapreduce.framework.name" => "yarn",
      "mapreduce.map.java.opts" => "-Xmx512M"
    }.each do |k, v|
      describe k do
        it { expect(doc.xpath("//property[name='#{k}']/value").text).to eq v }
      end
    end
  end
end

describe file("#{config_dir}/yarn-site.xml") do
  it { should exist }
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  describe "property" do
    let(:doc) { Nokogiri::XML(subject.content) }
    {
      "yarn.resourcemanager.scheduler.class" => "org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler",
      "yarn.acl.enable" => "False",
      "yarn.admin.acl" => "*",
      "yarn.log-aggregation-enable" => "False",
      "yarn.resourcemanager.hostname" => "localhost",
      "yarn.scheduler.capacity.root.queues" => "default",
      "yarn.scheduler.capacity.root.default.capacity" => "100",
      "yarn.scheduler.capacity.root.default.state" => "RUNNING",
      "yarn.scheduler.capacity.root.default.user-limit-factor" => "1",
      "yarn.scheduler.capacity.root.default.maximum-capacity" => "100"
    }.each do |k, v|
      describe k do
        it { expect(doc.xpath("//property[name='#{k}']/value").text).to eq v }
      end
    end
  end
end

describe file("#{db_dir}/dfs/name/current") do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file("#{db_dir}/dfs/name/current/VERSION") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
