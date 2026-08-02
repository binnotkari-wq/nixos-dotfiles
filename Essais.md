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

## Installation wipe système seulement :

- Script deploy.sh : ok
- Build selon .nix vm : ok
- Impermanence tmpfs : ok

## Déploiement par rebuild :

- Script deploy.sh : ok
- Build selon .nix vm : ok
- Impermanence tmpfs : ok

## Script cargo

- config sans disque secondaire : OK
Créé bien un sous-volume cargo si pas de disque cargo ou pas de sous-volume cargo existant.
Intègre dans cargo.nix et importe ce fichier, rebuild ok, le sous-volume est monté.
Les données se téléchargent

- config avec disque secondaire :
Pas de sous-volume cargo créé (c'est bien le comportement attendu lorsqu'il y a un disque dédié)
Intègre dans cargo.nix et importe ce fichier, rebuild ok, le disque est monté.
Les données se téléchargent

Pour plus de lisibilité, découper en plusieurs fonctions plus ciblées.
!! adapter les alias shell pour correspondre seulement au LLM téléchargées de ce script
---> faire le point sur les meilleures LLM à prendre.

## Impermanence

- Wipe root automatique sur dépoiement par installation scriptée : ok
- Tmpfs sur déploiement par rebuild : ok

Nettoyer commentaires.