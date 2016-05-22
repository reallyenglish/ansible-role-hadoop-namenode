node {
  stage 'Checkout'
  checkout scm
  stage 'Syntax check'
  try {
    sh 'ansible-playbook --syntax-check -i localhost test/integration/default.yml'
    currentBuild.result = 'SUCCESS'
  } catch {
    currentBuild.result = 'FAILURE'
  }
  stage 'Notify'
  step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
}
