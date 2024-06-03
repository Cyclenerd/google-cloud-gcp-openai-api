# Copyright 2023-2024 Nils Knieling
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

# The python:3.12-slim tag points to the latest release based on Debian 12 (bookworm)
FROM python:3.12-slim

# Labels
LABEL org.opencontainers.image.title         "OpenAI API for Google Cloud Vertex AI"
LABEL org.opencontainers.image.description   "Drop-in replacement REST API for Google Cloud Vertex AI that is compatible with the OpenAI API specifications"
LABEL org.opencontainers.image.url           "https://github.com/Cyclenerd/google-cloud-gcp-openai-api"
LABEL org.opencontainers.image.authors       "https://github.com/Cyclenerd/google-cloud-gcp-openai-api/graphs/contributors"
LABEL org.opencontainers.image.documentation "https://github.com/Cyclenerd/google-cloud-gcp-openai-api/blob/master/README.md"
LABEL org.opencontainers.image.source        "https://github.com/Cyclenerd/google-cloud-gcp-openai-api/blob/master/Dockerfile"

# Log Python messages immediately instead of being buffered
ENV PYTHONUNBUFFERED True

# Disable any healthcheck inherited from the base image
HEALTHCHECK NONE

# Default HTTP port
EXPOSE 8000

# Copy app to container
WORKDIR /app
COPY requirements.txt ./
COPY vertex.py ./
RUN pip install -r requirements.txt; \
    pip cache purge
CMD ["python", "vertex.py"]

# If you're reading this and have any feedback on how this image could be
# improved, please open an issue or a pull request so we can discuss it!
#
#   https://github.com/Cyclenerd/google-cloud-gcp-openai-api