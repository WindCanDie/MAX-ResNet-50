#
# Copyright 2018-2019 IBM Corp. All Rights Reserved.
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
#

FROM quay.io/codait/max-base:v1.4.0

ARG model_bucket=https://max-cdn.cdn.appdomain.cloud/max-resnet50/1.0.0
ARG model_file=assets.tar.gz
ARG use_pre_trained_model=true

RUN if [ "$use_pre_trained_model" = "true" ] ; then\
    wget -nv --show-progress --progress=bar:force:noscroll ${model_bucket}/${model_file} --output-document=assets/${model_file} && \
    tar -x -C assets/ -f assets/${model_file} -v && rm assets/${model_file}; fi

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

RUN if [ "$use_pre_trained_model" = "true" ] ; then \
      # validate downloaded pre-trained model assets
      sha512sum -c sha512sums.txt ; \
    else \
      # rename the directory that contains the custom-trained model artifacts
      if [ -d "./custom_assets/" ] ; then \
        rm -rf ./assets && ln -s ./custom_assets ./assets ; \
      fi \
    fi

EXPOSE 5000
USER infra


