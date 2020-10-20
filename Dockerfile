FROM python:3.8-slim
RUN apt update -y && apt install  vim curl -y && rm -rf /var/lib/apt/lists/* \
&& curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
&& mv /tmp/eksctl /usr/local/bin && chmod +x /usr/local/bin && pip install awscli --no-cache-dir && rm -f /tmp/* 

ADD https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.7/2020-07-08/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod a+x /usr/local/bin/kubectl