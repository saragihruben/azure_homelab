FROM alpine:3.18

ENV TERRAFORM_VERSION=1.7.5

# Install dependencies
RUN apk update && apk add --no-cache \
    bash \
    curl \
    unzip \
    jq \
    python3 \
    py3-pip \
    python3-dev \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    make \
    git \
    libgcc \
    libstdc++ 

# Create virtual environment and install azure-cli inside it
RUN python3 -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install azure-cli termcolor

# Add venv to PATH
ENV PATH="/opt/venv/bin:$PATH"

# Install Terraform
RUN curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform \
    && rm terraform.zip

# Verify installs
RUN terraform -version && az version

# Set default shell
SHELL ["/bin/bash", "-c"]
CMD ["/bin/bash"]