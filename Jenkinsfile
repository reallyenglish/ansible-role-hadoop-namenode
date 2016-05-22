node ('virtualbox') {
  stage 'Checkout'
  checkout scm
  sh '( cd .. && if [ ! -h ansible-role-hadoop-namenode ]; then ln -s workspace ansible-role-hadoop-namenode; fi )'
  stage 'bundle'
  sh 'bundle install --path vendor/bundle'
  sh 'if vagrant box list | grep trombik/ansible-freebsd-10.3-amd64 >/dev/null; then echo "installed"; else vagrant box add trombik/ansible-freebsd-10.3-amd64; fi'
  sh 'id'
  stage 'Syntax check'
  try {
    sh 'ansible-playbook --syntax-check -i localhost test/integration/default.yml'
    currentBuild.result = 'SUCCESS'
  } catch (err) {
    currentBuild.result = 'FAILURE'
  }
  stage 'bundle exec kitchen test'
  sh 'bundle exec kitchen test'
  stage 'Notify'
  step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
}
