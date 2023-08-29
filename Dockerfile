# Copyright 2023 Nils Knieling
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The python:3.11-slim-bookworm tag points to the latest release based on Debian 12 (bookworm)
FROM python:3.11-slim-bookworm
# Cloud Storage FUSE
# https://github.com/GoogleCloudPlatform/gcsfuse
ENV GCSFUSE_REPO="gcsfuse-bookworm"

# Labels
LABEL org.opencontainers.image.title         "Vertex AI ob Kölsch"
LABEL org.opencontainers.image.description   "REST API for Google Cloud Vertex AI that compatible with the OpenAI API specifications"
LABEL org.opencontainers.image.url           "https://hub.docker.com/r/cyclenerd/google-cloud-gcp-openai-api"
LABEL org.opencontainers.image.authors       "https://github.com/Cyclenerd/google-cloud-gcp-openai-api/graphs/contributors"
LABEL org.opencontainers.image.documentation "https://github.com/Cyclenerd/google-cloud-gcp-openai-api/blob/master/README.md"
LABEL org.opencontainers.image.source        "https://github.com/Cyclenerd/google-cloud-gcp-openai-api/pkgs/container/google-cloud-gcp-openai-api"

# Log Python messages immediately instead of being buffered
ENV PYTHONUNBUFFERED True

# Disable any healthcheck inherited from the base image
HEALTHCHECK NONE

# Copy app to container
WORKDIR /app
COPY requirements.txt ./
COPY vertex.py ./
COPY start.sh ./

RUN set -eux ;\
# Update list of available packages
	apt-get update -yqq ;\
# Install packages
	apt-get install -yqq curl gnupg ;\
	echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee "/etc/apt/sources.list.d/gcsfuse.list" ;\
	curl "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | apt-key add - ;\
	apt-get update -yqq ;\
	apt-get install -yqq gcsfuse ;\
	pip install -r requirements.txt ;\
# Delete cache
	apt-get clean ;\
	rm -rf /var/lib/apt/lists/* ;\
	pip cache purge

# Default HTTP port
EXPOSE 8000
CMD ["bash", "start.sh"]

# If you're reading this and have any feedback on how this image could be
# improved, please open an issue or a pull request so we can discuss it!
#
#   https://github.com/Cyclenerd/google-cloud-gcp-openai-api