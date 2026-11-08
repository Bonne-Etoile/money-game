# Faire tester un lot par le joueur

Ce que Claude ne peut pas juger (sensations, son, fluidité sur une vraie machine) est regroupé en lots, testés sur un build.

1. Quand le lot est mergé dans `dev` : créer une branche `claude/test-build-<n>` depuis ce commit et la pousser. `build.yml` construit l'export Windows (environ 10 à 20 minutes) et le publie en artefact (14 jours).
2. Message au joueur : le lien de l'exécution GitHub Actions, l'artefact à télécharger, et **une liste précise de quoi tester** (« lancer 20 objets à 5 m de la poubelle : le geste est-il agréable ? »).
3. Chaque retour devient un ticket daté, avec les mots du joueur, dans `docs/backlog.md`.
4. Supprimer les anciennes branches `claude/test-build-*` de temps en temps (elles s'accumulent : plus de trente sur River Cleaner).

Limites connues :

- La session cloud ne peut pas télécharger les artefacts (stockage Azure bloqué) : la vérification de l'export se fait dans la CI (`tools/smoke_test.sh`).
- Un export Linux sorti d'un artefact perd son bit d'exécution (`chmod +x`).
- Le bouton « Run workflow » n'existe qu'une fois le workflow sur la branche par défaut.
