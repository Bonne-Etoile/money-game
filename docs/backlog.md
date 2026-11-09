# Backlog

Feuille de route (`docs/feuille-de-route.md`) découpée en tickets de la taille d'une PR, pour le travail autonome de Claude (règles dans `CLAUDE.md`, « Travail autonome »). Les tickets sont dans l'ordre de priorité : le prochain à prendre est le premier ticket **prêt** dont les dépendances sont **faites**.

Statuts :

- **prêt** : peut être fait sans attendre personne ;
- **décision requise** : attend une réponse (section « Décisions à prendre ») ;
- **action requise** : attend une action du joueur (compte, achat, test sur sa machine) ;
- **en cours** : branche ouverte (indiquer la branche) ;
- **en revue** : PR ouverte vers `dev` (indiquer la PR) ;
- **à tester** : PR de gameplay prête, en attente du test du joueur (indiquer la PR et quoi tester) ;
- **fait** : mergé dans `dev` (indiquer la PR) ;
- **bloqué** : mis de côté après échec, avec la raison.

Chaque ticket : objectif, périmètre, critères d'acceptation, dépendances. Un ticket trop gros en cours de route est redécoupé ici avant d'être poursuivi. Chaque retour du joueur devient un ticket daté, avec ses mots.

## Décisions à prendre

- ~~**D1. Technologie du jeu**~~ — **tranchée le 2026-11-08 : Godot 4.7** (le modèle actuel), avec le plugin AdMob de poingstudios. Voir `docs/architecture.md`, décision 16.
- ~~**D2. Genre du jeu**~~ — **tranchée le 2026-11-08** : un hybride **blocs + tuiles de mahjong**. Deux prototypes à comparer : piste 1 « blocs de tuiles » et piste 2 « la pyramide fournit les pièces » (`docs/etude-concurrence.md`, annexe B). On garde celle qui donne le plus envie de rejouer (test de Stelio).
- ~~**D4. Pubs forcées**~~ — **tranchée le 2026-11-09 : aucune pub forcée pour le moment** (ni interstitiel, ni bannière) ; seulement des pubs récompensées choisies par le joueur (« J'aimerais aussi qu'il n'y ait pas de pub forcée pour le moment »).
- **D3. Public cible** (2026-11-08) : 13 ans et plus recommandé, pour éviter le programme Familles qui interdit la plupart des leviers pub (`docs/deploiement-android.md`, section 6).

## Actions attendues du joueur

- **A1. Créer le compte développeur Google Play personnel** (25 $, pièce d'identité, téléphone Android) et le compte AdMob : `docs/deploiement-android.md`, sections 1 et 2.
- **A2. Réunir 15 à 20 testeurs** (téléphone Android, adresse Gmail) pour le test fermé obligatoire de 14 jours : `docs/deploiement-android.md`, section 7. À lancer tôt : c'est l'étape la plus longue.
- **A3. Choisir un nom de domaine** pour la politique de confidentialité et `app-ads.txt` : `docs/deploiement-android.md`, section 3.

## Socle technique (fourni par le modèle)

### T1. Projet, commandes, session cloud, CI — fait (modèle `Bonne-Etoile/godot-template`)

- Renommer le jeu (`tools/new-game.sh`), `make lint check test build` verts dans la session.

## Phase 0 — Proof of concept

### G0. Préparer le dépôt pour un jeu mobile 2D — en revue (branche `claude/project-thread-yrd89m`)

- **Objectif** : un projet qui se lance en portrait, en 2D, avec le rendu mobile, et des entrées tactiles.
- **Périmètre** : renommer le jeu (`tools/new-game.sh`) ; rendu Mobile ou Compatibility ; fenêtre portrait (720 × 1280 par exemple) avec étirement adapté aux écrans de téléphone ; actions de l'Input Map pour le toucher et la souris ; retirer ce qui ne sert qu'à la 3D sur PC ; créer la branche `dev`.
- **Critères** : `make lint check test build` verts ; capture d'écran du menu en portrait.
- **Dépend de** : rien.
- **Fait (2026-11-08)** : titre de travail « Block Tiles » (`block_tiles`) ; décision 17 de `docs/architecture.md`. La branche `dev` n'est pas créée : la session ne peut pousser que sur sa branche ; G0 à G2 sont dans une seule PR empilée sur la PR #1, un commit par ticket.

### G1. Prototype piste 1 « blocs de tuiles » — à tester (branche `claude/project-thread-yrd89m`)

- **Objectif** : savoir si la règle « ligne pleine **ou** 3 symboles identiques qui se touchent » donne envie de rejouer.
- **Périmètre** : grille 8 × 8, 3 pièces proposées sans rotation, glisser-déposer, chaque case de pièce porte un symbole (4 à 6 symboles, formes simples) ; effacement des lignes, colonnes et trios ; score et combos ; fin de partie quand aucune pièce ne rentre ; rejouer. Pas de pub, pas de sauvegarde. Logique dans `game/core/` avec tests unitaires ; réglages (taille, symboles, pièces) en `.tres`.
- **Critères** : tests unitaires de la logique, test de scénario d'une partie, captures regardées ; export Linux/Windows pour le test de Stelio (puis Android dès que G3 est fait).
- **Dépend de** : G0.
- **Fait (2026-11-08)** : règles dans `docs/conception-du-jeu.md`, section 2. **À tester par Stelio** : est-ce qu'on a envie de rejouer ? La règle du trio se comprend-elle vite ? Trop facile ou trop dur (nombre de symboles, formes) ? Le glisser-déposer au doigt est-il confortable ?

### G2. Prototype piste 2 « la pyramide fournit les pièces » — à tester (branche `claude/project-thread-yrd89m`)

- **Objectif** : savoir si vider une pile de mahjong en posant ses tuiles sur une grille de blocs est plus prenant que la piste 1.
- **Périmètre** : en haut, une petite pile de tuiles (règle « libre » du mahjong) ; une tuile retirée devient une pièce à poser sur la grille du bas ; effacement par ligne (et par trio si la piste 1 l'a validé) ; niveau gagné quand la pile est vide, perdu quand la pièce ne rentre plus ; 3 à 5 niveaux faits à la main.
- **Critères** : comme G1.
- **Dépend de** : G0 (réutilise la grille de G1 si elle existe).
- **Fait (2026-11-08)** : règles dans `docs/conception-du-jeu.md`, section 2. Plateau de 2 places (une tuile prise attend d'être posée). Trios coupés (une pièce = un symbole). **À tester par Stelio**, en comparaison avec G1 : lequel donne le plus envie de rejouer ? La règle « tuile libre » se comprend-elle sans explication ? Les niveaux sont-ils trop faciles (un robot simple les gagne tous) ?

### G3. Export Android et pubs de test — fait, pub à vérifier sur le téléphone de Stelio

- **Objectif** : installer le prototype sur le téléphone de Stelio, avec des pubs de test.
- **Périmètre** : décision 16 de `docs/architecture.md` : SDK Android, JDK, modèles d'export et préréglage Android (APK de test, AAB plus tard) ; plugin AdMob de poingstudios derrière un autoload `Ads` avec une version factice pour les tests ; une pub récompensée de test (« continuer ») dans le prototype retenu.
- **Critères** : APK installable ; pub de test affichée ; tests verts avec la version factice.
- **Dépend de** : G0.
- **Fait (2026-11-08)**, sans accès à `dl.google.com` : autoload `Ads`, `FakeAdsBackend` et `AdMobAdsBackend` (décision 18) ; plugin AdMob 5.1.0 dans `addons/admob` ; pub récompensée « Continuer (regarder une pub) » sur l'écran de fin de G1 (une fois par partie, dégage une croix de 3 lignes et 3 colonnes au centre : toutes les formes rentrent), testée avec la version factice ; préréglage d'export « Android », `tools/setup-android.sh`, `make android`. Le prototype n'étant pas encore choisi, la pub est dans G1 seulement (G1 est sans fin, c'est là que « continuer » a le plus de sens).
- **Fait (2026-11-08, suite)** : greffon AdMob activé ; binaires du plugin installés par `tools/install-admob-binaries.sh` (accord de Stelio) ; `make android` produit un APK de test (debug, arm64 et armv7, 174 Mo) dont le manifeste contient l'identifiant d'application AdMob de test et le plugin. Corrigé en route : chemins du SDK et du JDK 17 dans les réglages de l'éditeur, compression ETC2/ASTC, `make check` qui lisait `android/build` (voir `docs/pitfalls/godot-ligne-de-commande-et-export.md`). APK déposé dans les fichiers du projet (`builds/g3-android/`), et produit aussi par le workflow GitHub `android.yml` (2026-11-09 : l'app Claude sur mobile ne télécharge pas un fichier de 174 Mo).
- **À tester par Stelio** (pas d'émulateur possible dans la session : pas de KVM) : installer l'APK ; dans G1, perdre une partie, toucher « Continuer (regarder une pub) » : une pub récompensée marquée « Test Ad » doit passer, puis la croix centrale se libère. Si le bouton reste grisé : pas de réseau, ou la pub de test ne charge pas (me le dire).

### G5. Prototype piste 3 « le bac devient une grille » — à tester (branche `claude/project-thread-yrd89m`)

- **Demande de Stelio (2026-11-08)** : « peux-tu créer les 2 autres jeux proposés dans la phase d'étude ? »
- **Objectif** : comparer la piste 3 (`docs/etude-concurrence.md`, annexe B) aux autres.
- **Périmètre** : la pile de mahjong de G2, mais chaque tuile est une seule tuile à symbole ; on la pose sur une petite grille 5 × 5 ; 3 symboles identiques qui se touchent ou une ligne pleine s'effacent ; grille pleine = perdu, pile vide = gagné ; 3 niveaux faits à la main.
- **Critères** : comme G1.
- **Dépend de** : G2 (réutilise la pile et son écran).

### G6. Prototype piste 4 « paires sur la grille » — à tester (branche `claude/project-thread-yrd89m`)

- **Demande de Stelio (2026-11-08)** : idem G5.
- **Objectif** : savoir si les paires (règle du mahjong) rendent la partie trop facile ou plus agréable que les trios.
- **Périmètre** : le prototype G1 avec 2 symboles identiques qui se touchent au lieu de 3, et un symbole de plus pour compenser.
- **Critères** : comme G1.
- **Dépend de** : G1.

### G7. Prototype « tampon sur la pile » (idée de Stelio) — à tester (branche `claude/project-thread-yrd89m`)

- **Idée de Stelio (2026-11-08)**, ses mots : « on a des formes de Tetris qui arrivent les unes après les autres, puis on déplace ces formes sur une pile style mahjong, puis on prend les tuiles que recouvre le bloc, puis on obtient un bloc avec des tuiles. On place ensuite ces blocs tuilés sur une grille façon block blast. »
- **Périmètre** : une pile de tuiles en colonnes (6 × 6, plusieurs étages) ; une forme de Tetris vide arrive (et on voit les suivantes) ; on la pose sur la pile, là où chaque case recouvre une tuile ; elle prend la tuile du dessus de chaque case et devient une pièce tuilée ; on la pose sur la grille 8 × 8 où lignes et trios s'effacent. Pile vide = gagné ; pièce qui ne rentre plus = perdu. 3 niveaux.
- **Critères** : comme G1.
- **Dépend de** : G1, G2.
- **Fait (2026-11-08)** : G5, G6 et G7 sont dans le menu (boutons 3, 4 et 5), règles dans `docs/conception-du-jeu.md`, section 2. **À tester par Stelio** avec G1 et G2 : lequel donne le plus envie de rejouer ?

### G8. Retours de Stelio sur les prototypes (2026-11-09) — à tester (branche `claude/project-thread-yrd89m`)

- **Ses mots** : « 1 - je voudrais pour commencer exactement les mêmes pièces que pour Tetris original. 2 - j'aimerais pouvoir tourner les pièces. 3 - quand il m'est proposé 3 pièces et que j'en prends une, je voudrais qu'une nouvelle prenne sa place une fois que je l'ai posée. »
- **Fait** : prototypes 1 et 4 avec les 7 tétrominos (sans le nom, le visuel ni la musique de Tetris), rotation par un toucher (prototypes 1, 2, 4, 5 ; formes du prototype 5 aussi réduites aux 7 de base), remplacement immédiat de la pièce posée (prototypes 1 et 4). Règles dans `docs/conception-du-jeu.md`.

## Suite de l'étude Block Blast (2026-11-09)

**Demande de Stelio (2026-11-09)** : les 8 tickets proposés dans `docs/etude-block-blast.md` (section 8.4), « toutes ». Ils s'appliquent au prototype 1 (« blocs de tuiles », le seul qui a la pub « Continuer » et la difficulté de G9) en attendant le choix du prototype ; à reporter sur celui qui sera retenu. Rappel : **aucune pub forcée** (décision D4) ; tout le revenu vient des récompensées.

### G10. Record au centre — prêt

- **Objectif** : faire du record le moteur de la partie et le moment fort de « Continuer » (étude, 8.1.1 et 8.2.1).
- **Périmètre** : record affiché en permanence ; barre « vers le record » qui se remplit pendant la partie ; animation et son quand il est battu ; sur l'écran de fin, l'offre « Continuer » dit ce qu'il manquait (« Il te manquait 120 points ») ou salue le record battu.
- **Critères** : logique (écart au record, record battu) dans `game/core/` avec tests ; test de scénario ; captures regardées.
- **Dépend de** : G9 (record et `PlayerStats`, PR #5).

### G11. Difficulté dans les deux sens et garantie de jouabilité — prêt

- **Objectif** : garder le joueur moyen, et que toute défaite vienne d'un choix du joueur (étude, 8.1.2 et 8.1.3).
- **Périmètre** : après 2 parties d'affilée sous la moyenne, ou tant que le score est loin du record, tirer la pièce qui a **le plus** de place ; petites pièces pour les toutes premières parties ; le générateur ne propose jamais un lot impossible (aucune pièce ne rentre dans aucun sens) tant que la grille n'est pas pleine au-delà d'un seuil réglable. Le générateur ne lit jamais l'état des pubs. Réglages dans `game/data/difficulty_rules.tres`.
- **Critères** : tests unitaires (série d'échecs → niveau qui baisse ; jamais de lot impossible sur des grilles de test) ; description de PR : quoi tester (sensation de difficulté).
- **Dépend de** : G9.

### G12. Build de test « 3 pièces renouvelées ensemble » — prêt

- **Objectif** : savoir si attendre d'avoir posé les 3 pièces (comme Block Blast) répond au « trop facile » mieux que le remplacement immédiat de G8 (étude, 8.1.5).
- **Périmètre** : un choix dans le menu ou un réglage (`refill_each_slot` existe déjà) pour comparer les deux sur le même APK.
- **Critères** : test de scénario des deux modes ; APK de test par le workflow ; **à tester par Stelio**.
- **Dépend de** : G8.

### G13. Retours d'effacement — prêt

- **Objectif** : rendre chaque effacement satisfaisant et visible dans une vidéo de 5 secondes (étude, 8.1.4).
- **Périmètre** : mots d'encouragement qui montent avec le combo, explosion des cases, son qui monte à chaque coup du combo, effet qui grossit avec le nombre d'effacements, « grille vide ! » avec gros bonus, vibration courte (réglage dans les options), feu d'artifice au record. Sons par `docs/recettes/sons-et-musique.md` ; textes traduits.
- **Critères** : captures regardées ; vidéo ou build de test ; **à tester par Stelio** (Claude ne juge ni les sensations ni le son).
- **Dépend de** : G1.

### G14. Reprise offerte au retour — prêt

- **Objectif** : faire revenir le joueur qui décroche (étude, 8.2.5).
- **Périmètre** : si le joueur revient après plusieurs jours sans jouer (seuil réglable), la première reprise de la journée est gratuite, avec un bouton qui le dit (« Continuer (offert) »). Date de dernière session dans `PlayerStats` (migration de sauvegarde si besoin).
- **Critères** : tests unitaires (dates simulées, pas d'horloge réelle) ; test de scénario.
- **Dépend de** : G9.

### G15. Aide à l'hésitation — prêt

- **Objectif** : aider le joueur bloqué sans casser le défi (étude, 8.1.6).
- **Périmètre** : après une dizaine de secondes sans coup (réglable), montrer en ombre un placement qui efface une ligne ou un trio, s'il y en a un. Plus tard, éventuellement, un bonus « Indice » contre pub récompensée.
- **Critères** : recherche du placement dans `game/core/` avec tests ; test de scénario en avançant image par image.
- **Dépend de** : G1.

### G16. Défi du jour — prêt

- **Objectif** : un rendez-vous quotidien que Block Blast n'a pas (étude, 8.1.8).
- **Périmètre** : une partie par jour avec la même graine pour tous (`RandomNumberGenerator` à graine tirée de la date) ; meilleur score du jour et série de jours joués gardés dans la sauvegarde ; bouton dans le menu. Classement entre joueurs plus tard (demande un serveur).
- **Critères** : tests unitaires (même date → mêmes pièces) ; test de scénario ; captures.
- **Dépend de** : G1.

### G17. Mode à objectifs avec image révélée — décision requise

- **Objectif** : donner un but et une progression au-delà du mode infini (étude, 8.1.7).
- **Périmètre** : niveaux courts (effacer N trios, libérer des tuiles « gemmes », grille de départ avec obstacles) ; une image de tuiles de mahjong révélée niveau après niveau ; bouton Partager à la fin ; un mode expert débloqué en battant son record.
- **Critères** : niveaux gagnables par un robot dans les tests ; captures.
- **Dépend de** : le choix du prototype par Stelio (G1 à G7), puis G10 et G11.

### G4. …

- **Objectif** :
- **Périmètre** :
- **Critères** :
- **Dépend de** :
