require 'spec_helper'
require 'json'

class ServiceNotReady < StandardError
end
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
describe server(:namenode) do

  it 'should be ready' do
    response = nil
    retry_and_sleep do
      response = fetch "http://#{ server(:namenode).server.address }:50070/jmx"
    end
    expect(response.class).to eq(Net::HTTPOK)
  end

  it 'should return NameNodeStatus == active' do
    http_res = fetch "http://#{ server(:namenode).server.address }:50070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
    json = JSON.parse(http_res.body)
    expect(json.class).to eq(Hash)
    res = json['beans'].first
    expect(res['name']).to eq('Hadoop:service=NameNode,name=NameNodeStatus')
    expect(res['NNRole']).to eq('NameNode')
    expect(res['State']).to eq('active')
  end

end
