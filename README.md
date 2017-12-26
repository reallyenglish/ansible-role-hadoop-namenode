# ansible-role-hadoop-namenode

Install namenode of hadoop.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `hadoop_namenode_user` | user name of `namenode` | `{{ __hadoop_namenode_user }}` |
| `hadoop_namenode_group` | group name of `namenode` | `{{ __hadoop_namenode_group }}` |
| `hadoop_namenode_log_dir` | path to log directory | `/var/log/hadoop` |
| `hadoop_namenode_db_dir` | path to database directory | `{{ __hadoop_namenode_db_dir }}` |
| `hadoop_namenode_service` | service name of `namenode` | `{{ __hadoop_namenode_service }}` |
| `hadoop_namenode_resourcemanager_service` | name of `resourcemanager` | `{{ __hadoop_namenode_resourcemanager_service }}` |
| `hadoop_namenode_flags` | (not yet implemented) | `""` |
| `hadoop_namenode_host` | hostname `namenode` binds to (see below) | `localhost` |
| `hadoop_namenode_port` | port `namenode` binds to (see below) | `8020` |
| `hadoop_namenode_dfs_namenode_name_dir` | path to `dfs.namenode.name.dir` | `{{ hadoop_namenode_db_dir }}/dfs/name` |
| `hadoop_conf_dir` | path to configuration directory | `{{ __hadoop_conf_dir }}` |
| `hadoop_core_site_file` | path to `core-site.xml` | `{{ hadoop_conf_dir }}/core-site.xml` |
| `hadoop_hdfs_site_file` | path to `hdfs-site.xml` | `{{ hadoop_conf_dir }}/hdfs-site.xml` |
| `hadoop_mapred_site_file` | path to `mapred-site.xml` | `{{ hadoop_conf_dir }}/mapred-site.xml` |
| `hadoop_yarn_site_file` | path to `yarn-site.xml` | `{{ hadoop_conf_dir }}/yarn-site.xml` |
| `hadoop_config` | dict of XML  configuration (see below) | `{}` |
| `hadoop_namenode_enable_ha` | enable HA configuration when `true` | `false` |
| `hadoop_namenode_zookeeper_nodes` | list of `zookeeper` nodes | `[]` |
| `hadoop_namenode_dfs_nameservices` | `dfs.nameservices` | `mycluster` |
| `hadoop_namenode_master` | hostname of master  | `""` |
| `hadoop_namenode_slave` | hostname of slave | `""` |
| `hadoop_namenode_dfs_hosts_file` | path to `dfs_hosts` | `{{ hadoop_conf_dir }}/dfs_hosts` |
| `hadoop_namenode_dfs_hosts` | | `[]` |

## `hadoop_namenode_host` and `hadoop_namenode_port`

Due to a usual issue with Java application, the role checks if the service is
really running after (re)starting `hadoop_namenode_service` with `wait_for`
`ansible` module, which requires IP address/hostname, and port the service
binds to. Thus, `fs.defaultFS` must match `hadoop_namenode_host` and
`hadoop_namenode_port`. If your `fs.defaultFS` does not include host
`localhost` and/or port 8020, set `hadoop_namenode_host` and/or
`hadoop_namenode_port`.

## FreeBSD

| Variable | Default |
|----------|---------|
| `__hadoop_namenode_user` | `hdfs` |
| `__hadoop_namenode_group` | `hadoop` |
| `__hadoop_namenode_db_dir` | `/var/db/hadoop` |
| `__hadoop_namenode_service` | `namenode` |
| `__hadoop_namenode_resourcemanager_service` | `resourcemanager` |
| `__hadoop_conf_dir` | `/usr/local/etc/hadoop` |


# Dependencies

dict2xml is bundled in the role, with modifications, mostly removing six
dependency. dict2xml is available at
https://github.com/delfick/python-dict2xml.

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - name: reallyenglish.hosts
    - name: ansible-role-hadoop-namenode
  vars:
    hosts_map:
      "192.168.84.100":
        - "{{ ansible_hostname }}"
        - "{{ ansible_fqdn }}"
    hadoop_config:
      slaves:
        - localhost
      core_site:
        - 
          - name: fs.defaultFS
          - value: "hdfs://{{ hadoop_namenode_host }}:{{ hadoop_namenode_port }}/"
        -
          - name: hadoop.tmp.dir
          - value: /var/db/hadoop
        -
          - name: io.file.buffer.size
          - value: 131072
      hdfs_site:
        -
          - name: dfs.namenode.name.dir
          - value: "file://{{ hadoop_namenode_dfs_namenode_name_dir }}"
        - 
          - name: dfs.blocksize
          - value: 268435456
        -
          - name: dfs.namenode.handler.count 
          - value: 100
        -
          - name: dfs.datanode.data.dir
          - value: "file://{{ hadoop_namenode_db_dir }}/dfs/data"
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
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
