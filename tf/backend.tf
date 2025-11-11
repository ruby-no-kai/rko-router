terraform {
  backend "s3" {
    bucket       = "rk-infra"
    region       = "ap-northeast-1"
    key          = "terraform/rko-router.tfstate"
    use_lockfile = true
  }
}
