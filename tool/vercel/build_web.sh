#!/usr/bin/env bash
set -euo pipefail

readonly flutter_version="3.50.1"
readonly flutter_archive="flutter_linux_${flutter_version}-stable.tar.xz"
readonly flutter_sha256="4ad17fc8462fbcef2ba19ff4a78c0a16b7147fde1add8578e267ea62cdb92678"
readonly flutter_archive_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${flutter_archive}"
readonly project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly flutter_cache_root="${HOME}/.cache/cadence-tasks"
flutter_root="${flutter_cache_root}/flutter-${flutter_version}"
temp_dir="$(mktemp -d)"
firebase_config_file="${temp_dir}/firebase-web-config.json"
trap 'rm -rf "${temp_dir}"' EXIT

if [[ -n "${CADENCE_FLUTTER_SDK_ROOT:-}" ]]; then
  flutter_root="${CADENCE_FLUTTER_SDK_ROOT}"
elif [[ ! -x "${flutter_root}/bin/flutter" ]]; then
  mkdir -p "${flutter_cache_root}"
  curl --fail --location --retry 3 --silent --show-error \
    "${flutter_archive_url}" \
    --output "${temp_dir}/${flutter_archive}"
  printf '%s  %s\n' \
    "${flutter_sha256}" \
    "${temp_dir}/${flutter_archive}" \
    | sha256sum --check --status
  tar -xJf "${temp_dir}/${flutter_archive}" -C "${temp_dir}"
  mv "${temp_dir}/flutter" "${flutter_root}"
fi

export PATH="${flutter_root}/bin:${PATH}"
cd "${project_root}"

node - "${firebase_config_file}" <<'NODE'
const fs = require('node:fs');

const requiredKeys = [
  'FIREBASE_API_KEY',
  'FIREBASE_PROJECT_ID',
  'FIREBASE_MESSAGING_SENDER_ID',
  'FIREBASE_WEB_APP_ID',
  'FIREBASE_AUTH_DOMAIN',
];
const optionalKeys = [
  'FIREBASE_ANDROID_APP_ID',
  'FIREBASE_STORAGE_BUCKET',
  'GOOGLE_SERVER_CLIENT_ID',
];

for (const key of requiredKeys) {
  if (!process.env[key]?.trim()) {
    console.error(`Missing required Vercel environment variable: ${key}`);
    process.exit(1);
  }
}

const config = Object.fromEntries(
  [...requiredKeys, ...optionalKeys].map((key) => [
    key,
    process.env[key] ?? '',
  ]),
);
fs.writeFileSync(process.argv[2], JSON.stringify(config), { mode: 0o600 });
NODE

flutter --version
flutter pub get
flutter build web \
  --release \
  --base-href=/ \
  --dart-define-from-file="${firebase_config_file}"
