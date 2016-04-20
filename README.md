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
| hadoop\_namenode\_conf\_dir | path to config dir | "{{ \_\_hadoop\_namenode\_conf\_dir }}" |
| hadoop\_namenode\_flags | not used | "" |
| hadoop\_namenode\_dfs\_namenode\_name\_dir | path to namenode db dir  | "{{ hadoop\_namenode\_db\_dir }}/dfs/name" |
| hadoop\_namenode\_core\_site\_file | path to core-site.xml | "{{ hadoop\_namenode\_conf\_dir }}/core-site.xml" |
| hadoop\_namenode\_hdfs\_site\_file | path to hdfs-site.xml | "{{ hadoop\_namenode\_conf\_dir }}/hdfs-site.xml" |
| hadoop\_namenode\_mapred\_site\_file | path to mapred-site.xml | "{{ hadoop\_namenode\_conf\_dir }}/mapred-site.xml" |
| hadoop_config | a hash of xml config (see the example below) | {} |


Dependencies
------------

dict2xml is bundled in the role, with modifications, mostly removing six dependency. dict2xml is available at https://github.com/delfick/python-dict2xml.

Example Playbook
----------------

    - hosts: all
      pre_tasks:
        # env COMPRESSION=NONE HBASE_HOME=/usr/local/hbase /usr/local/share/opentsdb/tools/create_table.sh
        # XXX java.net.InetAddress.getLocalHost throws an exception without this
        - shell: echo "127.0.0.1 localhost {{ ansible_hostname }}" > /etc/hosts
          changed_when: False
      roles:
        - ansible-role-hadoop-namenode
      vars:
        hadoop_config:
          core_site:
            - [ name: fs.default.name, value: 'hdfs://localhost/' ]
          hdfs_site:
            - [ name: dfs_nameservices, value: mycluster ]
            - [ name: dfs_ha_namenodes_mycluster, value: "{{ ansible_hostname }}" ]
            - [ name: dfs_replication,value: 1 ]
            - 
              - name: dfs.namenode.name.dir
              - value: "file://{{ hadoop_namenode_dfs_namenode_name_dir }}"
          mapred_site:
            - [ name: mapred_job_tracker, value: "localhost:9001" ]

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
