# CI/CD Deploy on GCP VM (Cloudflare + Nginx Proxy Manager)

This repository now has automatic deployment from GitHub Actions to your VM.

## What the pipeline does
- On every push to `main`, the `Deploy to GCP VM` workflow runs.
- It connects to your VM over SSH.
- It clones/updates the repository in `$HOME/html5-portofolio`.
- It recreates the `portfolio-site` container on port `8081`.

Nginx Proxy Manager can stay configured to forward `me.aionbit.net` to `172.17.0.1:8081`.

## 1) Required GitHub Secrets
In `GitHub Repo -> Settings -> Secrets and variables -> Actions`, add:

- `VM_HOST` = `34.59.101.32`
- `VM_PORT` = `22`
- `VM_USER` = VM SSH user (example: `catalin`)
- `VM_SSH_KEY` = private SSH key (full content)

## 1.1) One-time SSH setup (if not done yet)
Run on your local machine (or any trusted machine):

```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_vm
```

Copy the public key to VM:

```bash
ssh-copy-id -i ~/.ssh/github_actions_vm.pub <VM_USER>@34.59.101.32
```

Use the private key content from `~/.ssh/github_actions_vm` as `VM_SSH_KEY` in GitHub Secrets.

## 2) VM requirements
Make sure these are installed:
- `git`
- `docker`

The SSH user used by GitHub Actions must be able to run Docker.

```bash
sudo usermod -aG docker <VM_USER>
```

Then logout/login (or reboot) before running the workflow again.

Quick commands (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install -y git docker.io
sudo systemctl enable --now docker
```

## 3) Nginx Proxy Manager
For `me.aionbit.net`:
- Domain Names: `me.aionbit.net`
- Scheme: `http`
- Forward Hostname / IP: `172.17.0.1`
- Forward Port: `8081`
- SSL: enable Let's Encrypt certificate + Force SSL

## 4) Cloudflare DNS
In the `aionbit.net` zone:
- `A` record for `me` -> `34.59.101.32`
- Proxy status: `Proxied`

## 5) Manual deploy (optional)
If you want to deploy manually directly on the VM:

```bash
cd ~/html5-portofolio
bash scripts/vm_deploy.sh
```

## 6) How to update the site
- Make changes in the repository
- `git add . && git commit -m "..." && git push`
- GitHub Actions deploys automatically

## 7) Validation after each deploy
- The deploy script now checks that `index.html` exists.
- It also runs an HTTP health check on `http://127.0.0.1:8081/` and fails the workflow if the site is not responding with `200`.
