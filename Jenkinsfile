node ('virtualbox') {
  stage 'Checkout'
  sh 'mkdir ansible-role-hadoop-namenode'
  dir('ansible-role-hadoop-namenode') {
    checkout scm
  }
  stage 'bundle'
  dir('ansible-role-hadoop-namenode') {
    sh 'bundle install --path vendor/bundle'
    sh 'if vagrant box list | grep trombik/ansible-freebsd-10.3-amd64 >/dev/null; then echo "installed"; else vagrant box add trombik/ansible-freebsd-10.3-amd64; fi'
    sh 'id'
  }
  stage 'Syntax check'
  dir('ansible-role-hadoop-namenode') {
    try {
      sh 'ansible-playbook --syntax-check -i localhost test/integration/default.yml'
      currentBuild.result = 'SUCCESS'
    } catch (err) {
      currentBuild.result = 'FAILURE'
    }
  }
  stage 'bundle exec kitchen test'
  dir('ansible-role-hadoop-namenode') {
    sh 'bundle exec kitchen test'
    stage 'Notify'
    step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
  }
}
