node {
  stage 'Checkout'
  checkout scm
  sh 'env > env.txt'
  readFile('env.txt').split("\r?\n").each {
    println it
  }
  stage 'Syntax check'
  try {
    sh 'ansible-playbook --syntax-check -i localhost test/integration/default.yml'
    currentBuild.result = 'SUCCESS'
  } catch (err) {
    currentBuild.result = 'FAILURE'
  }
  stage 'Notify'
  step([$class: 'GitHubCommitNotifier', resultOnFailure: 'FAILURE'])
}
