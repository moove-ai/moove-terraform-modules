GCLOUD_LOCATION=$(command -v gcloud)
echo "Using gcloud from $GCLOUD_LOCATION"

gcloud --project $PROJECT_ID alpha services api-keys create --api-target=service="$SERVICE_API" --display-name="$KEY_NAME" &&
export KEY_NAME=$(gcloud --project $PROJECT_ID alpha services api-keys list --format="value(name)" --sort-by createTime --limit 1) &&
export API_KEY=$(gcloud --project $PROJECT_ID alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)") &&
printf $API_KEY | gcloud --project $PROJECT_ID secrets versions add "$SECRET_NAME" --data-file=-