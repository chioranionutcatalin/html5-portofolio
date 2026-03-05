This project was previously based on Astral by HTML5 UP and has been customized to fit a minimalistic portfolio, CV-style profile, and projects showcase page.

Deployment (GitHub Actions -> VM)
- CI/CD runs on every push to `main` using `.github/workflows/deploy.yml`.
- Add these repository secrets in GitHub (`Settings -> Secrets and variables -> Actions`):
	- `VM_HOST` = your VM public IP or hostname (example: `<VM_HOST>`)
	- `VM_PORT` = SSH port 
	- `VM_USER` = SSH user on VM (example: `<VM_USER>`)
	- `VM_SSH_KEY` = full private SSH key content (OpenSSH format)
- One-time SSH key setup (local machine):
	- `ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_actions_vm`
	- Add `~/.ssh/github_actions_vm.pub` into VM user `~/.ssh/authorized_keys`
	- Put `~/.ssh/github_actions_vm` (private key) into GitHub secret `VM_SSH_KEY`
- VM prerequisites:
	- `git`, `docker`, `curl` installed
	- User must be able to run Docker (`sudo usermod -aG docker <VM_USER>`), then logout/login
- Nginx Proxy Manager for app traffic:
	- Forward your domain/subdomain to docker container address
	- Enable SSL certificate + Force SSL
- Test flow:
	- Run workflow manually once from `Actions -> Deploy to GCP VM -> Run workflow`
	- After that, every `git push` on `main` deploys automatically

Credits:
- Astral by HTML5 UP (html5up.net)
- Demo Images: Unsplash (unsplash.com)
- Icons: Font Awesome (fontawesome.io)
- Other: jQuery (jquery.com), Responsive Tools (github.com/ajlkn/responsive-tools)

Check the final result here: https://me.aionbit.net/