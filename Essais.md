# Essais de déploiement

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'fr')]"
curl -fsSL https://raw.githubusercontent.com/binnotkari-wq/nixos-dotfiles/main/nixos_deploy/deploy.sh -o deploy.sh
chmod +x deploy.sh
sudo ./deploy.sh
```

> 01/08/2026 23:30

## Installation wipe total :

- Script deploy.sh : ok
- Build selon .nix vm : ok
- Impermanence tmpfs : ok
- script cargo : 

## Installation wipe système seulement :

- Script deploy.sh : ok
- Build selon .nix vm : ok
- Impermanence tmpfs : ok
- script cargo : 

## Déploiement par rebuild :