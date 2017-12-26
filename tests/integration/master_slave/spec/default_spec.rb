require "spec_helper"
require "json"

class ServiceNotReady < StandardError
end

context "when manual failover" do
  describe server(:namenode1) do
    it "should be ready", retry: 10, retry_wait: 10 do
      response = fetch "http://#{server(:namenode1).server.address}:5070/jmx"
      expect(response.class).to eq(Net::HTTPOK)
    end

    it "should return NameNodeStatus == active", retry: 10, retry_wait: 10 do
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
      http_res = fetch "http://#{server(:namenode1).server.address}:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
      json = JSON.parse(http_res.body)
      res = json["beans"].first
      raise ServiceNotReady if res["State"] == "initializing"
      expect(res["name"]).to eq("Hadoop:service=NameNode,name=NameNodeStatus")
      expect(res["NNRole"]).to eq("NameNode")
      expect(res["State"]).to eq("active")
    end
  end

  describe server(:namenode2) do
    s = server(:namenode2)
    it "should be ready" do
      response = fetch "http://#{s.server.address}:5070/jmx"
      expect(response.class).to eq(Net::HTTPOK)
    end

    it "should return NameNodeStatus == standby" do
      http_res = fetch "http://#{s.server.address}:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
      json = JSON.parse(http_res.body)
      res = json["beans"].first
      expect(res["name"]).to eq("Hadoop:service=NameNode,name=NameNodeStatus")
      expect(res["NNRole"]).to eq("NameNode")
      expect(res["State"]).to eq("standby")
    end

    it "should become master" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs haadmin -failover namenode1 namenode2")
      # Failover to NameNode at /192.168.84.101:8020 successful
      expect(result.chomp).to match(/Failover to NameNode at .* successful/)
    end

    it "should report it is the master" do
      http_res = fetch "http://#{s.server.address}:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
      json = JSON.parse(http_res.body)
      res = json["beans"].first
      expect(res["name"]).to eq("Hadoop:service=NameNode,name=NameNodeStatus")
      expect(res["NNRole"]).to eq("NameNode")
      expect(res["State"]).to eq("active")
    end
  end

  describe server(:namenode1) do
    it "should become master" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs haadmin -failover namenode2 namenode1")
      expect(result.chomp).to match(/Failover to NameNode at .* successful/)
    end

    it "should report it is the master" do
      http_res = fetch "http://#{server(:namenode1).server.address}:5070/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
      json = JSON.parse(http_res.body)
      res = json["beans"].first
      expect(res["name"]).to eq("Hadoop:service=NameNode,name=NameNodeStatus")
      expect(res["NNRole"]).to eq("NameNode")
      expect(res["State"]).to eq("active")
    end
  end
end

context "when everything ok" do
  describe server(:datanode1) do
    it "should create a directory /foo" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -mkdir /foo && echo OK")
      expect(result.chomp).to match(/OK/)
    end

    it "should create a file /foo/hosts" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -put /etc/hosts /foo/hosts && echo OK")
      expect(result.chomp).to match(/OK/)
    end

    it "should create delete /foo/hosts" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -rm /foo/hosts && echo OK")
      expect(result.chomp).to match(/OK/)
    end

    it "should rmdir /foo" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -rmdir /foo && echo OK")
      expect(result.chomp).to match(/OK/)
    end
  end
end

describe server(:namenode1) do
  it "should be killed" do
    result = current_server.ssh_exec("sudo service namenode stop >/dev/null 2>&1 && echo OK")
    expect(result.chomp).to match(/OK/)
  end
end

context "when namenode1 is dead" do
  describe server(:datanode1) do
    it "should create a directory /foo" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -mkdir /foo && echo OK")
      expect(result.chomp).to match(/OK/)
    end

    it "should rmdir /foo" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -rmdir /foo && echo OK")
      expect(result.chomp).to match(/OK/)
    end
  end
end

describe server(:namenode1) do
  it "should be started" do
    result = current_server.ssh_exec("sudo service namenode start >/dev/null 2>&1 && echo OK")
    expect(result.chomp).to match(/OK/)
  end
end

describe server(:datanode1) do
  it "should be killed" do
    result = current_server.ssh_exec("sudo service datanode stop >/dev/null 2>&1 && echo OK")
    expect(result.chomp).to match(/OK/)
  end
end

context "when datanode1 is dead" do
  describe server(:datanode2) do
    it "should create a file /hosts" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -put /etc/hosts /hosts && echo OK")
      expect(result.chomp).to match(/OK/)
    end

    it "should rm /hosts" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs dfs -rm /hosts && echo OK")
      expect(result.chomp).to match(/OK/)
    end
  end
end

describe server(:datanode1) do
  it "should be started" do
    result = current_server.ssh_exec("sudo service datanode start >/dev/null 2>&1 && echo OK")
    expect(result.chomp).to match(/OK/)
  end
end

context "when the test finishes" do
  describe server(:namenode1) do
    it "should become master" do
      result = current_server.ssh_exec("sudo -u hdfs hdfs haadmin -failover namenode2 namenode1")
      expect(result.chomp).to match(/Failover to NameNode at .* successful/)
    end
  end
end
