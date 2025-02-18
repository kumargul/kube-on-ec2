# vars defined with ?= can be overwritten by passing new values when running a target
# I.e.: make plan ENV=dev or make plan ENV=poc TF_LOG=debug
ENV ?=
COMP ?=
TF_LOG ?= error

# vars defined with := can not be overwritten
# do not change anything below this point
AWS_DEFAULT_REGION := ap-southeast-2

AWS_PROFILE=$(shell echo $$AWS_PROFILE)
VARS1="../envs/$(ENV)/$(COMP)/$(COMP).tfvars"
BACKEND="../envs/$(ENV)/$(COMP)/backend.tfvars"
#VARS2="environments/$(ENV)/$(ENV)-sg-values.tfvars"
AWS_PERMISSION=$(shell aws sts get-caller-identity > /dev/null 2>&1; echo $$?)
INFRACOST_API=$(shell aws ssm get-parameters --name infracost_api --with-decryption --query "Parameters[*].Value" --output text)
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
BLUE=$(shell tput setaf 6)
RESET=$(shell tput sgr0)

#export INFRACOST_API_KEY=$(INFRACOST_API)

ifeq (, $(shell which aws))
	$(error "No aws in $(PATH), go to https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html, pick your OS, and follow the instructions")
endif
ifeq (, $(shell which terraform))
	$(error "No terraform in $(PATH), get it from https://www.terraform.io/downloads.html")
endif
# ifeq (, $(shell which infracost))
# 	$(error "No infracost in $(PATH), get it from https://www.infracost.io/docs/")
# endif

default: help
help: ## Print help (this) menu
	@printf "\033[32mTerraform-makefile help menu\033[0m\n"
	@printf "$(GREEN)Make file can be used as $(BOLD)$(BLUE)make plan ENV=dev$(RESET)\n\n"
	@printf "Available functions and what they do:\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
ifndef ENV
	@echo "$(BOLD)$(RED)ENV was not set$(RESET)"
	@exit 1
endif

prep: set-env _creds fmt ## Prepare a new environment if needed, configure the tfstate backend, update any modules
	@echo "$(BOLD)$(YELLOW)Running using 'AWS_PROFILE=$(AWS_PROFILE)'$(RESET)"
	@echo "$(BOLD)$(GREEN)Running terraform init using backend from $(BACKEND)$(RESET)"
	@cd $(COMP); rm -rf .terraform && terraform init -backend-config=$(BACKEND)

init: prep ## Run terraform init with backend

fmt: ## Rewrites all Terraform configuration files to a canonical format.
	@echo "$(BOLD)$(YELLOW)Running Terraform fmt on following files:$(RESET)"
	@cd $(COMP); terraform fmt
	@cd envs/$(ENV)/; terraform fmt
#	@terraform fmt environments/poc
#	@terraform fmt environments/dev
#	@terraform fmt environments/sit
#	@terraform fmt environments/uat
#	@terraform fmt environments/prodsupp
#	@terraform fmt environments/prod

plan: prep ## Show what terraform thinks it will do
	@echo "$(BOLD)$(YELLOW)Running terraform plan for $(ENV) using -var-file as $(VARS1) and $(VARS2)$(RESET)"
	@cd $(COMP); terraform plan -var-file="$(VARS1)" -input=false
# @echo "Infracost breakdown"
# @cd $(COMP); infracost breakdown -p . --terraform-plan-flags "-var-file=$(VARS1)"
# @echo "Infracost difference"
# @cd $(COMP); infracost diff -p . --terraform-plan-flags "-var-file=$(VARS1)"

apply: prep ## Have terraform do the things.
	@echo "$(BOLD)$(YELLOW)Terraform will apply all the changes automatically for $(ENV)$(RESET)"
	@cd $(COMP); terraform apply -var-file="$(VARS1)" -input=false -auto-approve

refresh: prep ## Refresh terraform state
	@cd $(COMP); terraform apply -refresh-only -var-file="$(VARS1)" -input=false -auto-approve

output: prep ## Print terraform output for environment
	@cd $(COMP); terraform output

destroy: prep ## Destroy all things Terraform
	@cd $(COMP); terraform destroy -var-file="$(VARS1)"

state-list: prep ## Print list of AWS resources managed by terraform
	@terraform state list

_creds:
	@echo "$(BOLD)Verifying that the AWS Credentials are valid$(RESET)"
ifneq ($(AWS_PERMISSION),0)
	@echo "$(BOLD)$(RED)FAILED...Please login to AWS or attach a valid IAM Profile$(RESET)"
	@exit 1
else
	@echo "$(BOLD)$(GREEN)Found valid AWS Credentials$(RESET)"
endif
