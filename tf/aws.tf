provider "aws" {
  region              = "us-west-2"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project = "rko-router"
    }
  }
}

provider "aws" {
  alias               = "apne1"
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project = "rko-router"
    }
  }
}

provider "aws" {
  alias               = "use1"
  region              = "us-east-1"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project = "rko-router"
    }
  }
}

data "aws_caller_identity" "current" {}
