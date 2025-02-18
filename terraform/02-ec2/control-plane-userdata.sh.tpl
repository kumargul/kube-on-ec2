#!/usr/bin/env bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# shellcheck disable=SC2269,SC2164

export AWS_DEFAULT_REGION="ap-southeast-2"
export AWS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

root_ca="${root_ca}"

root="/root"

_curl() {
  curl -fsSL "$@"
}

set_up_proxy() {
  cat >> /etc/environment <<EOF
HTTP_PROXY="http://infraproxy-ap2.aws.health.nsw.gov.au:3128"
HTTPS_PROXY="http://infraproxy-ap2.aws.health.nsw.gov.au:3128"
http_proxy="http://infraproxy-ap2.aws.health.nsw.gov.au:3128"
https_proxy="http://infraproxy-ap2.aws.health.nsw.gov.au:3128"
NO_PROXY="169.254.169.254,10.134.109.222,git.health.nsw.gov.au,s3.ap-southeast-2.amazonaws.com,ssm.ap-southeast-2.amazonaws.com,ssmmessages.ap-southeast-2.amazonaws.com,ec2messages.ap-southeast-2.amazonaws.com"
no_proxy="169.254.169.254,10.134.109.222,git.health.nsw.gov.au,s3.ap-southeast-2.amazonaws.com,ssm.ap-southeast-2.amazonaws.com,ssmmessages.ap-southeast-2.amazonaws.com,ec2messages.ap-southeast-2.amazonaws.com"
EOF
  # shellcheck disable=SC1091
  source /etc/environment
  export HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY no_proxy
}

apt_get_update_y() {
  apt-get update -qq
}

apt_get_packages() {
  apt-get install -qq \
    unzip \
    jq \
    net-tools
}

install_cert() {
  echo "$root_ca" | base64 --decode > /usr/local/share/ca-certificates/NSWHEALTH-RootCA.crt && update-ca-certificates
}

install_awscli_v2() {
  local zip_file
  zip_file=awscli-exe-linux-"$(uname -m)".zip
  _curl https://awscli.amazonaws.com/"$zip_file" -o "$zip_file"
  unzip -oq "$zip_file"
  aws/install
  rm -f "$zip_file"
}

_add_docker_apt_key() {
  local docker_asc="/etc/apt/keyrings/docker.asc"
  apt-get install -qq ca-certificates
  install -m 0755 -d /etc/apt/keyrings
  _curl https://download.docker.com/linux/ubuntu/gpg -o "$docker_asc"
  chmod a+r "$docker_asc"
}

_add_repo_to_apt_sources() {
  local arch version_codename
  arch="$(dpkg --print-architecture)"
  # shellcheck disable=SC1091,SC2153
  version_codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
  echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $version_codename stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
}

_install_docker() {
  apt-get install -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

_configure_docker_proxy() {
  local docker_service_d="/etc/systemd/system/docker.service.d"
  mkdir -p "$docker_service_d"
  cat > "$docker_service_d"/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=$http_proxy/" "HTTPS_PROXY=$http_proxy/" "NO_PROXY=$no_proxy"
EOF
}

install_docker() {
  _add_docker_apt_key
  _add_repo_to_apt_sources
  apt_get_update_y
  _install_docker
  _configure_docker_proxy
}

start_docker() {
  systemctl enable docker
  systemctl start docker
}

_account_id() {
  aws sts get-caller-identity | jq -r '.Account'
}

set_registry() {
  registry="$(_account_id)".dkr.ecr."$AWS_DEFAULT_REGION".amazonaws.com
}

docker_login() {
  aws ecr get-login-password | docker login --username "AWS" --password-stdin "$registry"
}

check_ports() {
  # Some quick checks that everything launched successfully.
  netstat -ntlp | grep -wq "0.0.0.0:3000" || exit 1
  netstat -ntlp | grep -wq "0.0.0.0:9090" || exit 1
}

disable_swap() {
  swapoff -a
  sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}

set_hostname() {
  TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
  HOSTNAME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-hostname)
  hostnamectl set-hostname $HOSTNAME
  systemctl restart systemd-logind.service
}
main() {
  cd "$root"
  disable_swap
  set_hostname
  set_up_proxy
  apt_get_update_y
  apt_get_packages
  install_awscli_v2
  install_docker
  start_docker
  set_registry
  docker_login
  check_ports
}

# shellcheck disable=SC2128
if [[ "$0" = "$BASH_SOURCE" ]] ; then
  main "$@"
fi

# vim: set ft=bash:
