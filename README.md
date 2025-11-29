# Mail Client Installer Monorepo

A production-ready, configurable repository to install official mail clients on Ubuntu/Debian and macOS.

Features
- Declarative YAML configuration to choose which clients to install and to override vendor download URLs and checksums.
- Idempotent, safe shell scripts with `dry-run` and `yes` modes.
- Ansible role for fleet automation.
- CI: shellcheck, lint, smoke-tests, conventional commits enforcement, semantic releases.
- GitOps-friendly with recommended branch protection and release strategy.

Quickstart
1. Clone the repository
```bash
git clone git@github.com:freddiedfre/mail-client-installer.git
cd mail-client-installer
```
2. Install dependencies
```bash
# Install yq (jq wrapper for YAML) and jq
# Ubuntu/Debian
sudo apt-get install jq
pip3 install yq
# macOS
brew install python-yq jq
```
3. Optionally copy and edit the local config
```bash
cp configs/defaults.yml configs/local.yml
# edit configs/local.yml to enable/disable clients or override URLs
```
4. Run installer (dry-run first)
```bash
chmod +x scripts/install_all.sh
./scripts/install_all.sh --config configs/local.yml --dry-run
# then run for real (on Linux with sudo)
sudo ./scripts/install_all.sh --config configs/local.yml --yes
```

Releases & Versioning
We follow **semantic versioning**. Use conventional commits when contributing; CI enforces commit messages. Merges to `main` trigger release workflow which creates GitHub Releases and tags.

Contributing
See CONTRIBUTING.md for branch/PR/release rules and commit message guidelines.
