#!/usr/bin/env bash
set -euo pipefail

TARGET_USER="devops"
TARGET_HOME="/home/${TARGET_USER}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "This image must start as root so it can switch to '${TARGET_USER}'." >&2
  echo "Remove '--user ...' and pass LOCAL_UID/LOCAL_GID instead." >&2
  exit 1
fi

current_uid="$(id -u "${TARGET_USER}")"
current_gid="$(id -g "${TARGET_USER}")"
desired_uid="${LOCAL_UID:-${current_uid}}"
desired_gid="${LOCAL_GID:-${current_gid}}"

if [[ "${desired_gid}" != "${current_gid}" ]]; then
  if getent group "${desired_gid}" >/dev/null 2>&1; then
    existing_group="$(getent group "${desired_gid}" | cut -d: -f1)"
    usermod -g "${existing_group}" "${TARGET_USER}"
  else
    groupmod -g "${desired_gid}" "${TARGET_USER}"
  fi
fi

if [[ "${desired_uid}" != "${current_uid}" ]]; then
  if getent passwd "${desired_uid}" >/dev/null 2>&1; then
    existing_user="$(getent passwd "${desired_uid}" | cut -d: -f1)"
    echo "UID ${desired_uid} already belongs to ${existing_user}; keeping ${TARGET_USER} uid ${current_uid}" >&2
  else
    usermod -u "${desired_uid}" "${TARGET_USER}"
  fi
fi

mkdir -p "${TARGET_HOME}/.ssh" "${TARGET_HOME}/.aws" "${TARGET_HOME}/.config" "${TARGET_HOME}/sbin"
target_group="$(id -gn "${TARGET_USER}")"
# Do not chown bind-mounted credential/work directories from the host.
find "${TARGET_HOME}" \
  \( \
    -path "${TARGET_HOME}/.ssh" -o \
    -path "${TARGET_HOME}/.aws" -o \
    -path "${TARGET_HOME}/sbin" -o \
    -path "${TARGET_HOME}/.config/gcloud" \
  \) -prune -o \
  -exec chown "${TARGET_USER}:${target_group}" {} +

export HOME="${TARGET_HOME}"
cd "${TARGET_HOME}"

if [[ "$#" -eq 0 ]]; then
  exec sudo -E -H -u "${TARGET_USER}" /bin/zsh
fi

exec sudo -E -H -u "${TARGET_USER}" "$@"
