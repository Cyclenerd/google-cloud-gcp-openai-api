#!/usr/bin/env bash

# Copyright 2023 Nils Knieling
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

MY_VECTOR_BUCKET=${VECTOR_BUCKET:-"vector-bucket-missing"}
MY_VECTOR_DIR=${VECTOR_DIR:-"/vector"}

# Create mount directory for vector store and mount read-only
mkdir -p "$MY_VECTOR_DIR" || exit 9
gcsfuse --app-name "vector" -o "ro" "$MY_VECTOR_BUCKET" "$MY_VECTOR_DIR" || exit 9
ls -lah "$MY_VECTOR_DIR" || exit 9

# Run the web app
python vertex.py || exit 9