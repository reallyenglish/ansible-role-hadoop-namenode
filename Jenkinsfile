node {
  stage 'bundle'
  sh 'bundle install --path vendor/bundle'
  stage 'Checkout'
  checkout scm
  sh '( cd .. && ln -s workspace ansible-role-hadoop-namenode )'
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
