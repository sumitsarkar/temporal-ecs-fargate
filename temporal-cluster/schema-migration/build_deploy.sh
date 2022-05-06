ENVIRONMENT="dev"

SERVICE_NAME="temporal/sql-migration"
IMAGE_TAG=$(node -e "console.log(require('./package.json').version);")

SERVICE_NAME=${SERVICE_NAME} IMAGE_TAG=${IMAGE_TAG} bash push_image.sh
IMAGE_URI=$(cat ecr_image_url)

cd deployment || exit
envsubst < terraform.tfvars.template > terraform.tfvars
terraform init -backend-config ./backend/${ENVIRONMENT}.tf
terraform apply -auto-approve
cd .. || exit
