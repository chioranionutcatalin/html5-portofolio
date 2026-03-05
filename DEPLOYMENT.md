# CI/CD Deploy pe GCP VM (Cloudflare + Nginx Proxy Manager)

Acest repo are acum deploy automat din GitHub Actions către VM-ul tău.

## Ce face pipeline-ul
- La orice push pe `main`, workflow-ul `Deploy to GCP VM` rulează.
- Se conectează prin SSH pe VM.
- Clonează/actualizează repo-ul în `/opt/html5-portofolio`.
- Repornește containerul `portfolio-site` pe portul `8081`.

Nginx Proxy Manager poate rămâne configurat spre `172.17.0.1:8081` pentru `me.aionbit.net`.

## 1) GitHub Secrets necesare
În `GitHub Repo -> Settings -> Secrets and variables -> Actions`, adaugă:

- `VM_HOST` = `34.59.101.32`
- `VM_PORT` = `22`
- `VM_USER` = utilizatorul SSH de pe VM (ex: `catalin`)
- `VM_SSH_KEY` = cheia privată SSH (conținut complet)

## 2) Cerințe pe VM
Asigură-te că sunt instalate:
- `git`
- `docker`

Comenzi rapide (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install -y git docker.io
sudo systemctl enable --now docker
```

## 3) Nginx Proxy Manager
Pentru `me.aionbit.net`:
- Domain Names: `me.aionbit.net`
- Scheme: `http`
- Forward Hostname / IP: `172.17.0.1`
- Forward Port: `8081`
- SSL: activează certificat Let's Encrypt + Force SSL

## 4) Cloudflare DNS
În zona `aionbit.net`:
- `A` record pentru `me` -> `34.59.101.32`
- Proxy status: `Proxied` (portocaliu)

## 5) Deploy manual (opțional)
Dacă vrei deploy manual direct pe VM:

```bash
bash scripts/vm_deploy.sh
```

## 6) Cum actualizezi site-ul
- Faci modificări în repo
- `git add . && git commit -m "..." && git push`
- GitHub Actions face deploy automat
