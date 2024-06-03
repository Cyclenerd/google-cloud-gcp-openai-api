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

# Google Cloud project
MY_PROJECT_ID=$(gcloud config get-value project --quiet)
echo "Google Cloud project ID: $MY_PROJECT_ID"

# Set location
MY_GOOGLE_CLOUD_LOCATION=${GOOGLE_CLOUD_LOCATION:-"us-central1"}
echo "Google Cloud location: $MY_GOOGLE_CLOUD_LOCATION"

# Set API key
MY_OPENAI_API_KEY=${OPENAI_API_KEY:-""}
if [ -z "$MY_OPENAI_API_KEY" ]; then
    echo "❌ API key 'OPENAI_API_KEY' missing!"
    exit 1
fi
echo "API key: $MY_OPENAI_API_KEY"

# Set API host
MY_OPENAI_API_HOST=${OPENAI_API_HOST:-""}
if [ -z "$MY_OPENAI_API_HOST" ]; then
    echo "❌ API host 'OPENAI_API_HOST' missing!"
    exit 1
fi
echo "API host: $MY_OPENAI_API_HOST"

gcloud builds submit "https://github.com/mckaywrigley/chatbot-ui.git" \
    --git-source-revision="main" \
    --tag="$MY_GOOGLE_CLOUD_LOCATION-docker.pkg.dev/$MY_PROJECT_ID/docker-openai-api/chatbot-ui:latest" \
    --timeout="1h" \
    --region="$MY_GOOGLE_CLOUD_LOCATION" \
    --default-buckets-behavior="regional-user-owned-bucket" \
    --quiet

# Deploy Cloud Run service
gcloud run deploy "chatbot-ui" \
    --image="$MY_GOOGLE_CLOUD_LOCATION-docker.pkg.dev/$MY_PROJECT_ID/docker-openai-api/chatbot-ui:latest" \
    --description="Chatbot UI" \
    --region="$MY_GOOGLE_CLOUD_LOCATION" \
    --set-env-vars="OPENAI_API_KEY=$MY_OPENAI_API_KEY,OPENAI_API_HOST=$MY_OPENAI_API_HOST" \
    --max-instances=2 \
    --allow-unauthenticated \
    --quiet