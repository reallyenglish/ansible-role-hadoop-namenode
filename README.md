ansible-role-hadoop-namenode
============================

Install namenode of hadoop.

Requirements
------------

None

Role Variables
--------------

| variable | description | default |
|----------|-------------|---------|
| hadoop\_namenode\_user | namenode user name | "{{ \_\_hadoop\_namenode\_user }}" |
| hadoop\_namenode\_group | name node group name | "{{ \_\_hadoop\_namenode\_group }}" |
| hadoop\_namenode\_log\_dir | path to log dir | /var/log/hadoop |
| hadoop\_namenode\_db\_dir | path to DB dir | "{{ \_\_hadoop\_namenode\_db\_dir }}" |
| hadoop\_namenode\_service | namenode service name | "{{ \_\_hadoop\_namenode\_service }}" |
| hadoop\_namenode\_resourcemanager\_service | resourcemanager service name | "{{ \_\_hadoop\_namenode\_resourcemanager\_service }}" |
| hadoop\_namenode\_conf\_dir | path to config dir | "{{ \_\_hadoop\_namenode\_conf\_dir }}" |
| hadoop\_namenode\_flags | not used | "" |
| hadoop\_namenode\_dfs\_namenode\_name\_dir | path to namenode db dir  | "{{ hadoop\_namenode\_db\_dir }}/dfs/name" |
| hadoop\_namenode\_core\_site\_file | path to core-site.xml | "{{ hadoop\_namenode\_conf\_dir }}/core-site.xml" |
| hadoop\_namenode\_hdfs\_site\_file | path to hdfs-site.xml | "{{ hadoop\_namenode\_conf\_dir }}/hdfs-site.xml" |
| hadoop\_namenode\_mapred\_site\_file | path to mapred-site.xml | "{{ hadoop\_namenode\_conf\_dir }}/mapred-site.xml" |
| hadoop\_config | a hash of xml config (see the example below) | {} |


Dependencies
------------

dict2xml is bundled in the role, with modifications, mostly removing six dependency. dict2xml is available at https://github.com/delfick/python-dict2xml.

Example Playbook
----------------

  - hosts: all
    pre_tasks:
      # XXX java.net.InetAddress.getLocalHost throws an exception without this
      - shell: echo "127.0.0.1 localhost {{ ansible_hostname }}" > /etc/hosts
        changed_when: False
    roles:
      - ansible-role-hadoop-namenode
    vars:
      hadoop_config:
        slaves:
          - localhost
        core_site:
          - 
            - name: fs.defaultFS
            - value: 'hdfs://localhost/'
          -
            - name: hadoop.tmp.dir
            - value: /var/db/hadoop
          -
            - name: io.file.buffer.size
            - value: 131072
        hdfs_site:
          -
            - name: dfs.namenode.name.dir
            - value: "${hadoop.tmp.dir}/dfs/name"
          - 
            - name: dfs.blocksize
            - value: 268435456
          -
            - name: dfs.namenode.handler.count 
            - value: 100
          -
            - name: dfs.datanode.data.dir
            - value: "${hadoop.tmp.dir}/dfs/data"
        yarn_site:
          -
            - name: yarn.resourcemanager.scheduler.class
            - value: org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler
          -
            - name: yarn.acl.enable
            - value: false
          -
            - name: yarn.admin.acl
            - value: "*"
          -
            - name: yarn.log-aggregation-enable
            - value: false
          -
            - name: yarn.resourcemanager.hostname
            - value: localhost
          -
            - name: yarn.scheduler.capacity.root.queues
            - value: default
          -
            - name: yarn.scheduler.capacity.root.default.capacity
            - value: 100
          -
            - name: yarn.scheduler.capacity.root.default.state
            - value: RUNNING
          -
            - name: yarn.scheduler.capacity.root.default.user-limit-factor
            - value: 1
          -
            - name: yarn.scheduler.capacity.root.default.maximum-capacity
            - value: 100

        mapred_site:
          -
            - name: mapreduce.framework.name
            - value: yarn
          -
            - name: mapreduce.map.java.opts
            - value: "-Xmx512M"

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
