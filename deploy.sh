#!/usr/bin/env bash

# Copyright 2023-2024 Nils Knieling
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Check commands
command -v gcloud >/dev/null 2>&1 || { echo >&2 "❌ Google Cloud CLI 'gcloud' it's not installed. Please install!"; exit 1; }
command -v openssl >/dev/null 2>&1 || { echo >&2 "❌ OpenSSL 'openssl' it's not installed. Please install!"; exit 1; }

# Check Dockerfile
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile does not exist!"
    exit 1
fi

# Google Cloud project
MY_PROJECT_ID=$(gcloud config get-value project --quiet)
echo "Google Cloud project ID: $MY_PROJECT_ID"

# Enable APIs
echo "Enable APIs..."
# Define the list of GCP services to enable
MY_GCP_SERVICES=(
    'aiplatform.googleapis.com'  # Vertex AI Platform
    'run.googleapis.com'  # Cloud Run
    'artifactregistry.googleapis.com'  # Artifact Registry
    'cloudbuild.googleapis.com'  # Cloud Build
    'containeranalysis.googleapis.com'  # Container Analysis
    'containerscanning.googleapis.com'  # Container Scanning
)
# Enable each GCP service
for MY_GCP_SERVICE in "${MY_GCP_SERVICES[@]}"; do
    gcloud services enable "$MY_GCP_SERVICE" --quiet
done

# Generate a random string for the OpenAI API key
MY_RANDOM=$(openssl rand -hex 21)
# Set the OpenAI API key from environment variable
# or generate one if not set
MY_OPENAI_API_KEY=${OPENAI_API_KEY:-"sk-$MY_RANDOM"}
echo
# Output a line with API key
echo "🔑 API key: $MY_OPENAI_API_KEY"
# Check if macOS clipboard is available
if command -v pbcopy >/dev/null 2>&1; then
    # Copy API key to macOS clipboard
    echo "$MY_OPENAI_API_KEY" | pbcopy
    # Output a line with emoji
    echo "(📋 Copied to macOS clipboard)"
fi
echo

# Set location
MY_GOOGLE_CLOUD_LOCATION=${GOOGLE_CLOUD_LOCATION:-"us-central1"}
echo "Google Cloud location: $MY_GOOGLE_CLOUD_LOCATION"

# Create Artifact Registry for Docker cointainer images
gcloud artifacts repositories create "docker-openai-api" \
  --repository-format="docker"\
  --description="Docker contrainer registry for OpenAI API" \
  --location="$MY_GOOGLE_CLOUD_LOCATION" \
  --quiet

# Create container
gcloud builds submit \
    --tag="$MY_GOOGLE_CLOUD_LOCATION-docker.pkg.dev/$MY_PROJECT_ID/docker-openai-api/vertex:latest" \
    --timeout="30m" \
    --region="$MY_GOOGLE_CLOUD_LOCATION" \
    --default-buckets-behavior="regional-user-owned-bucket" \
    --quiet

# Deploy Cloud Run service
gcloud run deploy "openai-api-vertex" \
    --image="$MY_GOOGLE_CLOUD_LOCATION-docker.pkg.dev/$MY_PROJECT_ID/docker-openai-api/vertex:latest" \
    --description="OpenAI API for Google Cloud Vertex AI" \
    --region="$MY_GOOGLE_CLOUD_LOCATION" \
    --set-env-vars="OPENAI_API_KEY=$MY_OPENAI_API_KEY,GOOGLE_CLOUD_LOCATION=$MY_GOOGLE_CLOUD_LOCATION" \
    --max-instances=4 \
    --allow-unauthenticated \
    --quiet