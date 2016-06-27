require 'spec_helper'
require 'json'

class ServiceNotReady < StandardError
end
describe server(:namenode1) do

  it 'should be ready' do
    response = nil
    retry_and_sleep do
      response = fetch "http://#{ server(:namenode1).server.address }:5070/jmx"
    end
    expect(response.class).to eq(Net::HTTPOK)
  end

  it 'should return NameNodeStatus == active' do
    # {
    #   "beans" : [ {
    #     "name" : "Hadoop:service=NameNode,name=NameNodeStatus",
    #     "modelerType" : "org.apache.hadoop.hdfs.server.namenode.NameNode",
    #     "State" : "active",
    #     "NNRole" : "NameNode",
    #     "HostAndPort" : "localhost:8020",
    #     "SecurityEnabled" : false,
    #     "LastHATransitionTime" : 0
    #   } ]
    # }
    res = nil
    retry_and_sleep do
      http_res = fetch "http://#{ server(:namenode1).server.address }:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
      json = JSON.parse(http_res.body)
      res = json['beans'].first
      raise ServiceNotReady if res['State'] == 'initializing'
    end
    expect(res['name']).to eq('Hadoop:service=NameNode,name=NameNodeStatus')
    expect(res['NNRole']).to eq('NameNode')
    expect(res['State']).to eq('active')
  end
end

describe server(:namenode2) do

  s = server(:namenode2)
  it 'should be ready' do
    response = nil
    retry_and_sleep do
      response = fetch "http://#{ s.server.address }:5070/jmx"
    end
    expect(response.class).to eq(Net::HTTPOK)
  end

  it 'should return NameNodeStatus == standby' do
    res = nil
    retry_and_sleep do
      http_res = fetch "http://#{ s.server.address }:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
      json = JSON.parse(http_res.body)
      res = json['beans'].first
      raise ServiceNotReady if res['State'] == 'initializing'
    end
    expect(res['name']).to eq('Hadoop:service=NameNode,name=NameNodeStatus')
    expect(res['NNRole']).to eq('NameNode')
    expect(res['State']).to eq('standby')
  end

  it 'should become master' do
    result = current_server.ssh_exec('sudo -u hdfs hdfs haadmin -failover namenode1 namenode2')
    expect(result.chomp).to match /Failover from .* to .* successful/
  end

  it 'should report it is the master' do
    http_res = fetch "http://#{ s.server.address }:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
    json = JSON.parse(http_res.body)
    res = json['beans'].first
    expect(res['name']).to eq('Hadoop:service=NameNode,name=NameNodeStatus')
    expect(res['NNRole']).to eq('NameNode')
    expect(res['State']).to eq('active')
  end

end

describe server(:namenode1) do
  it 'should become master' do
    result = current_server.ssh_exec('sudo -u hdfs hdfs haadmin -failover namenode2 namenode1')
    expect(result.chomp).to match /Failover from .* to .* successful/
  end

  it 'should report it is the master' do
    http_res = fetch "http://#{ server(:namenode1).server.address }:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
    json = JSON.parse(http_res.body)
    res = json['beans'].first
    expect(res['name']).to eq('Hadoop:service=NameNode,name=NameNodeStatus')
    expect(res['NNRole']).to eq('NameNode')
    expect(res['State']).to eq('active')
  end

end
