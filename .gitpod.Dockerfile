FROM python:3.8-slim
RUN apt update -y && apt install  vim curl -y && rm -rf /var/lib/apt/lists/* \
&& curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
&& mv /tmp/eksctl /usr/local/bin && chmod +x /usr/local/bin && pip install awscli --no-cache-dir && rm -f /tmp/*