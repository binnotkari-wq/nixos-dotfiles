regroupe le contenu des 4 nix de base. Cela constitue le coeur de l'OS, commun à tous les rôles. Ce contenu ne bougera pas : l'OS fonctionnera toujours de la même façon quelle que soit sa variante.


Pour l'installateur :
Il faut qu'on choisisse
- le disque
- le nom de l'utilisateur
- le mot de passe
Le scénario doit se mettre en place tout seul.
Si on détecte un volume encrypté, avec un sous volume nix dedans, ça veut dire qu'on a déjà la structure d'une installation nixos custom, et qu'on peut faire une simple suppression et récréation des volumes systèmes.




Au moment de télécharger les llm et zims :
Si il n'y a pas de dossier local_cahe dans cargo,on ne télécharge pas les llm et les zims.


