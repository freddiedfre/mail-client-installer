# Architecture

This repo is structured to support both local workstation bootstrapping and fleet automation via Ansible.

- scripts/: idempotent shell installers (OS-aware)
- configs/: declarative YAML for installation choices and overrides
- ansible/: role & playbook for automated fleet installs
- .github/: CI, release workflows, commit checks
