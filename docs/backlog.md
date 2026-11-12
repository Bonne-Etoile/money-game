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
- ~~**D2. Genre du jeu**~~ — **tranchée le 2026-11-08** : un hybride **blocs + tuiles de mahjong**. Deux prototypes à comparer : piste 1 « blocs de tuiles » et piste 2 « la pyramide fournit les pièces » (`docs/etude-concurrence.md`, annexe B). On garde celle qui donne le plus envie de rejouer (test de Stelio). **Suite, 2026-11-09 : prototype retenu = G1 « blocs de tuiles »**, avec un mode infini et un mode à niveaux à objectifs dans le même jeu (G17, option C de l'étude Block Blast ; « Ok pour C »). G2, G5 et G6 sont mis de côté ; G7 « tampon sur la pile » pourrait devenir **un jeu à part entière**, à voir plus tard.
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

### G9. Difficulté adaptative, suivi du joueur et bonus contre pub (2026-11-09) — à tester (branche `claude/project-thread-ug2ilk`)

- **Ses mots** : « c'est beaucoup trop facile. Je n'ai eu aucune pub. La publicité est la clé centrale du jeu. Il nous faut un système de suivi du comportement du joueur, de la pub, et un système d'adaptation pour servir des pièces difficiles quand il enchaîne sans difficulté et surtout pour l'amener à regarder de la pub pour acheter un bonus. […] Pour le premier : retirer les 3 blocs et inverser symétriquement un bloc, ça me paraît la base. »
- **Périmètre** : prototype 1 (et 4, qui partage l'écran) : `PlayerStats` gardé dans la sauvegarde ; `DifficultyDirector` (pièces avec le moins de place quand il enchaîne) ; bonus « Nouvelles pièces » et « Miroir », 1 gratuit par partie puis 1 par pub récompensée ; appel au bonus quand une seule pièce rentre encore ; record sur l'écran de fin. Règles dans `docs/conception-du-jeu.md`, décision 19 de `docs/architecture.md`.
- **Critères** : tests unitaires (statistiques, difficulté, bonus, migration de sauvegarde) et de scénario (bonus gratuit puis pub, pub fermée avant la fin, miroir, appel au bonus, partie comptée) ; captures regardées.
- **À tester par Stelio** (APK) : la difficulté monte-t-elle assez vite (affichée en haut) ? Finit-on par vouloir un bonus ? Les bonus aident-ils assez pour valoir une pub ? Le miroir se comprend-il ?
- **Bonus suivants proposés** (après son test) : marteau (retirer une tuile), bombe 3 × 3, annuler le dernier coup, tuile joker, score ×2 en fin de partie (les interstitiels sont écartés : aucune pub forcée, décision D4 du 2026-11-09).

### G9b. Ne garder que G1 dans l'app (2026-11-09) — fait (PR #7)

- **Ses mots** : « Tu peux supprimer les autres jeux de l'app et ne garder que G1. »
- **Fait** : menu réduit à « Jouer » et « Quitter » ; scènes, logique, données, tests et textes des prototypes 2 à 5 retirés (`docs/conception-du-jeu.md`, section 2). Le code reste dans l'historique git (commit `8774f13`).

## Suite de l'étude Block Blast (2026-11-09)

**Demande de Stelio (2026-11-09)** : les 8 tickets proposés dans `docs/etude-block-blast.md` (section 8.4), « toutes ». Ils s'appliquent au prototype 1 (« blocs de tuiles »), retenu le 2026-11-09 (D2). Rappel : **aucune pub forcée** (décision D4) ; tout le revenu vient des récompensées.

### G10. Record au centre — à tester (PR #8, fusionnée)

- **Objectif** : faire du record le moteur de la partie et le moment fort de « Continuer » (étude, 8.1.1 et 8.2.1).
- **Périmètre** : record affiché en permanence ; barre « vers le record » qui se remplit pendant la partie ; animation et son quand il est battu ; sur l'écran de fin, l'offre « Continuer » dit ce qu'il manquait (« Il te manquait 120 points ») ou salue le record battu.
- **Critères** : logique (écart au record, record battu) dans `game/core/` avec tests ; test de scénario ; captures regardées.
- **Dépend de** : G9 (record et `PlayerStats`, PR #5).
- **Fait (2026-11-09)** : `RecordChase` (`game/core/`), ligne du record et barre dorée, « Nouveau record ! » qui grossit, ligne « Il vous manquait … » sur l'écran de fin. Son et feu d'artifice au record : avec G13. **À tester par Stelio** : la barre donne-t-elle envie d'aller au bout ? La phrase de l'écran de fin pousse-t-elle à « Continuer » ?

### G11. Difficulté dans les deux sens et garantie de jouabilité — à tester (PR #8, fusionnée)

- **Objectif** : garder le joueur moyen, et que toute défaite vienne d'un choix du joueur (étude, 8.1.2 et 8.1.3).
- **Périmètre** : après 2 parties d'affilée sous la moyenne, ou tant que le score est loin du record, tirer la pièce qui a **le plus** de place ; petites pièces pour les toutes premières parties ; le générateur ne propose jamais un lot impossible (aucune pièce ne rentre dans aucun sens) tant que la grille n'est pas pleine au-delà d'un seuil réglable. Le générateur ne lit jamais l'état des pubs. Réglages dans `game/data/difficulty_rules.tres`.
- **Critères** : tests unitaires (série d'échecs → niveau qui baisse ; jamais de lot impossible sur des grilles de test) ; description de PR : quoi tester (sensation de difficulté).
- **Dépend de** : G9.
- **Fait (2026-11-09)** : niveaux sous 0 (pièce avec le plus de place parmi 2 ou 3), 2 premières parties et partie après 2 parties sous la moyenne au niveau −1, garantie de jouabilité jusqu'à 70 % de grille remplie (`docs/conception-du-jeu.md`). « Petites pièces » des premières parties : obtenues par « le plus de place » plutôt que par une liste de formes. **À tester par Stelio** : les premières parties sont-elles trop faciles ? Après deux mauvaises parties, sent-on l'aide ? Y a-t-il encore des défaites « injustes » ?

### G12. Build de test « 3 pièces renouvelées ensemble » — à tester (PR #9, fusionnée)

- **Objectif** : savoir si attendre d'avoir posé les 3 pièces (comme Block Blast) répond au « trop facile » mieux que le remplacement immédiat de G8 (étude, 8.1.5).
- **Périmètre** : un choix dans le menu ou un réglage (`refill_each_slot` existe déjà) pour comparer les deux sur le même APK.
- **Critères** : test de scénario des deux modes ; APK de test par le workflow ; **à tester par Stelio**.
- **Dépend de** : G8.
- **Fait (2026-11-09)** : option du menu « Pièces : une à la fois / trois à la fois » (gardée dans les options du joueur). **À tester par Stelio** : laquelle donne le plus envie de rejouer ? Laquelle est assez difficile ?

### G13. Retours d'effacement — à tester (PR #9, fusionnée)

- **Objectif** : rendre chaque effacement satisfaisant et visible dans une vidéo de 5 secondes (étude, 8.1.4).
- **Périmètre** : mots d'encouragement qui montent avec le combo, explosion des cases, son qui monte à chaque coup du combo, effet qui grossit avec le nombre d'effacements, « grille vide ! » avec gros bonus, vibration courte (réglage dans les options), feu d'artifice au record. Sons par `docs/recettes/sons-et-musique.md` ; textes traduits.
- **Critères** : captures regardées ; vidéo ou build de test ; **à tester par Stelio** (Claude ne juge ni les sensations ni le son).
- **Dépend de** : G1.
- **Fait (2026-11-09)** : mots d'encouragement, éclats, tremblement, son qui monte avec le combo, « Grille vide ! +300 », vibration (option du menu, permission Android `VIBRATE`), feu d'artifice et fanfare au record. Sons faits par le code (pas de clé ElevenLabs dans la session) : à remplacer (`docs/avant-la-sortie.md`). **À tester par Stelio** : est-ce satisfaisant ? Trop chargé ? Les sons sont-ils supportables ? La vibration ?

### G14. Reprise offerte au retour — à tester (PR #10, fusionnée)

- **Objectif** : faire revenir le joueur qui décroche (étude, 8.2.5).
- **Périmètre** : si le joueur revient après plusieurs jours sans jouer (seuil réglable), la première reprise de la journée est gratuite, avec un bouton qui le dit (« Continuer (offert) »). Date de dernière session dans `PlayerStats` (migration de sauvegarde si besoin).
- **Critères** : tests unitaires (dates simulées, pas d'horloge réelle) ; test de scénario.
- **Dépend de** : G9.
- **Fait (2026-11-09)** : 3 jours d'absence → première reprise du jour gratuite, « Continuer (offert) », sans pub ; jours dans `PlayerStats` (sauvegarde version 3, migration testée). **À tester par Stelio** : difficile à tester sans attendre 3 jours ; le test de scénario le simule.

### G15. Aide à l'hésitation — à tester (PR #9, fusionnée)

- **Objectif** : aider le joueur bloqué sans casser le défi (étude, 8.1.6).
- **Périmètre** : après une dizaine de secondes sans coup (réglable), montrer en ombre un placement qui efface une ligne ou un trio, s'il y en a un. Plus tard, éventuellement, un bonus « Indice » contre pub récompensée.
- **Critères** : recherche du placement dans `game/core/` avec tests ; test de scénario en avançant image par image.
- **Dépend de** : G1.
- **Fait (2026-11-09)** : `MoveHint` (`game/core/`), tuiles pâles après 10 s sans geste. **À tester par Stelio** : l'aide arrive-t-elle trop tôt ou trop tard ? Gâche-t-elle le défi ?

### G16. Défi du jour — à tester (PR #10, fusionnée)

- **Objectif** : un rendez-vous quotidien que Block Blast n'a pas (étude, 8.1.8).
- **Périmètre** : une partie par jour avec la même graine pour tous (`RandomNumberGenerator` à graine tirée de la date) ; meilleur score du jour et série de jours joués gardés dans la sauvegarde ; bouton dans le menu. Classement entre joueurs plus tard (demande un serveur).
- **Critères** : tests unitaires (même date → mêmes pièces) ; test de scénario ; captures.
- **Dépend de** : G1.
- **Fait (2026-11-09)** : `DailyChallenge` (graine de la date), scène `game/proto_tiles/daily.tscn`, meilleur score du jour et série dans la sauvegarde, bouton du menu. **À tester par Stelio** : donne-t-il envie de revenir chaque jour ?

### G17. Mode à niveaux à objectifs — à tester (PR #11, fusionnée)

- **Décision de Stelio (2026-11-09)** : « Ok pour C » : un seul jeu (G1) avec deux modes, infini et à niveaux, plutôt qu'un second prototype.
- **Objectif** : donner un but, une fin et une progression au-delà du mode infini (étude, 8.1.7).
- **Périmètre** : les règles de G1 (grille 8 × 8, pièces de Tetris tournables, lignes et trios). Un niveau = une grille de départ dessinée à la main, un objectif affiché (« Effacer 5 trios d'étoiles », « Libérer les 3 tuiles dorées », « Atteindre 800 points ») et un nombre de pièces limité ; perdu quand il n'y a plus de pièces. Éléments de niveau : **tuiles dorées** (libérées par une ligne ou un trio), **pierres** (seulement par une ligne), **glace** (deux effacements) ; un élément nouveau tous les 10 niveaux environ. Carte des niveaux ; chaque niveau gagné colore une partie d'une grande tuile de mahjong, à partager une fois finie. Pub récompensée **« +5 pièces »** quand il en manque (aucune pub forcée, D4) ; bonus de G9 utilisables. Mode expert débloqué en battant son record (plus tard). Niveaux en `.tres`.
- **Critères** : chaque niveau gagné par un robot dans les tests ; test de scénario (gagner, perdre, « +5 pièces ») ; captures regardées ; **à tester par Stelio** (difficulté des niveaux).
- **Dépend de** : G10, G11. À redécouper si trop gros (moteur de niveaux et objectifs ; éléments ; carte et image).
- **Fait (2026-11-09)** : moteur de niveaux (`LevelGame`, `LevelBoard`), 3 objectifs (score, groupes d'un symbole, tuiles dorées), tuiles dorées, pierres, glace, 10 niveaux gagnés par un robot, carte avec la grande tuile qui se colore, « +5 pièces (pub) », bonus de G9, niveaux réussis dans la sauvegarde (version 4). Décision 20 de `docs/architecture.md`. **Reste (G17b)** : partager la grande tuile finie, mode expert débloqué en battant son record, plus de niveaux. **À tester par Stelio** : difficulté des niveaux (trop faciles, trop durs ?), objectifs clairs ? les pierres et la glace se comprennent-elles sans explication ?

### G17b. Suite du mode à niveaux — prêt

- **Objectif** : finir le périmètre de G17.
- **Périmètre** : partager l'image de la grande tuile une fois finie ; mode expert débloqué en battant son record ; 10 à 20 niveaux de plus, un élément nouveau tous les 10 niveaux environ.
- **Critères** : comme G17.
- **Dépend de** : G17 et le test de Stelio.

### G18. Dosage des pubs récompensées et autres réglages (2026-11-11) — à tester (branche `claude/project-thread-9qnqot`)

- **Demande de Stelio (2026-11-11)** : « Est-ce qu'il y a des réglages que l'on peut tirer des essais de Block Blast ? Concernant le nombre de pubs que l'on peut proposer aux joueurs avant qu'ils se lassent ? », puis « La fréquence des pubs, c'est un début. Étudie les autres réglages possibles. »
- **Fait** : étude et valeurs recommandées dans `docs/reglages-recommandes.md` (aucun code changé).
- **Accord de Stelio (2026-11-11)** : « ok pour tout ». Propositions de la section 9 du document : (1) plafonds de pubs récompensées (4 par partie, 5 pièces entre deux pubs de bonus, 15 par jour, pas de pub pendant les parties de débutant) ; (2) reprise offerte seulement à partir de 40 % du record ; (3) difficulté relative au record, après mesure ; (4) `comeback_days` 3 → 2 et `beginner_games` 2 → 3 ; (5) configuration à distance et envoi des mesures avant la sortie.

- **Fait (2026-11-11)** : (1) plafonds dans `game/data/ad_pacing_rules.tres` (`AdPacing`, `TileBlocksGame`), pubs du jour dans la sauvegarde (version 5, migration testée) ; (2) reprise à partir de 40 % du record ; (4) `comeback_days` = 2, `beginner_games` = 3 ; et la reprise en mode niveaux quand la grille est bloquée. **Reste** : (3) difficulté relative au record : faite en avance, voir G19 ; (5) configuration à distance et envoi des mesures, avant la sortie (`docs/avant-la-sortie.md`). **Ajout (2026-11-11, choix de Stelio « Montrer l'occasion »)** : le coup du miroir (`MirrorChance`) : le bouton Miroir clignote et le coup s'affiche quand un retournement ouvre un beau coup ; les pièces ne sont jamais truquées pour le provoquer. **Corrigé (retour de Stelio, 2026-11-11)** : en mode niveaux, la main montrait encore 3 pièces quand il n'en restait plus, et l'écran de fin proposait « Nouvelles pièces » ; la main ne montre plus que les pièces restantes, et le bouton est retiré de l'écran de fin des niveaux. **À tester par Stelio** : le coup du miroir se remarque-t-il, donne-t-il envie ? les 3 premières parties sans aucune pub se jouent-elles bien ? « Continuer » manque-t-il quand on perd loin du record ? La reprise en niveau aide-t-elle ?

### G19. Difficulté calée sur le record (2026-11-12) — en revue, à tester (branche `claude/project-thread-l9outg`)

- **Demande de Stelio (2026-11-12)** : après l'explication du mode infini de Block Blast (le record finit si haut qu'il faut longtemps pour y remonter), « ok » pour faire le point (3) de G18 tout de suite plutôt qu'après le test fermé.
- **Périmètre** : dès que le joueur a un record d'au moins 1 000 points, le score de la partie ne fait plus monter la difficulté par tranche de 200 points mais par part du record : rien sous 70 % du record, puis +1 niveau tous les 10 % (+1 à 70 %, +4 au record). Le niveau de départ (moyenne des parties) et le +1 du combo restent. Défi du jour inchangé (pas de record lu). Jamais de lot impossible, jamais de lien avec les pubs.
- **Fait** : `DifficultyDirector.record`, `_score_levels` ; réglages `record_points_from`, `record_calm_percent`, `record_percent_per_level` dans `game/data/difficulty_rules.tres` ; tests unitaires (`test/unit/difficulty_test.gd`) et de scénario (`test/scenario/difficulty_test.gd`).
- **À tester par Stelio** : le début de partie est-il assez calme une fois le record haut ? La tension monte-t-elle bien vers le record ? Les parties sont-elles trop longues ou trop courtes ? Les seuils se règlent dans le `.tres`.
- **Retour de Stelio (2026-11-12)** : « Je n'ai pas réussi à perdre. Donc, il faudrait un moyen de rendre le jeu perdant. Ce serait bien aussi que tu enregistres des données de mes parties pour que tu puisses ajuster. Je jouerais alors sur la version windows. »
- **Fait (2026-11-12)** : robot de simulation (`tools/simulate_endless.gd`) : avec la rotation, le robot ne perd jamais (8 sur 8 au-delà de 300 coups, même avec 6 symboles, des trios à 4 ou des pièces plus grosses) ; sans rotation, avec les pièces dans tous leurs sens, il perd après 170 coups en moyenne. D'où : plus de rotation en mode infini et défi du jour (`endless_can_rotate`, `turned_shape_keys`), les niveaux la gardent. Journal des parties `user://logs/games.jsonl` (`GameJournal`, `Diagnostics.log_game`, décision 22 de `docs/architecture.md`). **Choix de Stelio (2026-11-12)** : « Pas de rotation, toutes orientations » (plutôt que la rotation en bonus ou des pièces plus grosses).

### G20. Un jeu plus vivant à l'œil et à l'oreille (2026-11-12) — à tester (branche `claude/project-thread-c7anvu`)

- **Demande de Stelio (2026-11-12)** : « Le jeu est trop plat niveau graphique et sonore. Améliore ça. Inspire toi des effets graphiques de Block Blast. » Reprendre l'esprit des effets du genre (`docs/etude-block-blast.md`, § 3) sans copier les couleurs, les assets ni l'apparence de Block Blast.
- **Fait** :
  - **Écran** : fond en dégradé violet-bleu avec des lumières douces qui montent (`GameBackground`, aussi au menu et sur la carte des niveaux) ; grille dans un cadre arrondi, cases vides creusées ; tuiles en relief (tranche teintée de la couleur du symbole, reflet sur le dessus, symbole gravé) ; boutons arrondis en relief, bouton principal orange (thème `game/ui/game_theme.tres`, `PrimaryButton`) ; titre doré.
  - **Glisser** : ombre sous la pièce tenue ; aperçu de la pièce elle-même sur la grille ; **les cases qui seraient effacées s'illuminent** avant de lâcher (`TileGrid.clears_if_placed`).
  - **Poser** : les tuiles atterrissent en rebondissant ; les points du coup montent depuis la pièce (« +120 ») ; le score et le combo sautent ; les nouvelles pièces poussent dans le plateau.
  - **Effacer** : les tuiles s'allument en blanc puis rétrécissent ; un trait de lumière balaie chaque ligne ou colonne ; un anneau part de la pièce ; éclats qui tournoient et étoiles scintillantes pour un coup fort ; mots d'encouragement qui rebondissent, plus gros et plus colorés à chaque palier (arc-en-ciel au dernier) ; grille vide : grand anneau et feu d'artifice.
  - **Fin de partie** : la grille passe au gris, le panneau apparaît en fondu, petite phrase descendante.
  - **Sons** (toujours faits par le code, `SoundSynth`) : toc de bois à la prise et à la rotation, claquement de tuile à la pose (hauteur qui varie un peu), petit rebond quand la pièce revient, arpège d'effacement qui **monte la gamme pentatonique** à chaque coup du combo (`combo_semitones`), étoiles sonores pour un coup fort, arpège long pour la grille vide, fanfare du record, souffles des bonus ; écho léger.
  - **Musique** : une boucle calme de 42 s composée par le code (`tools/assets/compose_music.py` → `assets/sounds/music_calm.ogg`), jouée par l'autoload `Music` sur le bus `Music` ; boutons **Musique** et **Sons** dans le menu (réglages sauvegardés).
- **Refonte visuelle (2026-11-12)** : Stelio : « les visuels ne doivent pas être basiques, ils doivent aller bien au-delà du premier jet satisfaisant ». Une critique de direction artistique (`/mnt/project-files/notes/critique-visuels-g20.md`) a servi de cahier des charges ; captures avant/après dans `/mnt/project-files/captures/g20/galerie/` et `galerie-v2/`.
  - **Identité « laque et jade, la nuit »** (`tile_art.tres`) : fond bleu nuit, or pour les mises en valeur, vermillon pour l'action principale, encres sourdes pour les symboles (cinabre, jade, lapis, prune, ambre, sarcelle). Police d'affichage Fredoka (OFL, `assets/fonts/`), en graisse 500 pour l'interface et 700 pour les titres (`game/ui/text_font.tres`, `display_font.tres`).
  - **Tuiles** (`TileDrawing`) : un seul dos de jade pour toutes (lèvre plus sombre), face ivoire avec liseré, couture et lumière douce, symboles gravés et encrés (contour lissé, incrustation claire façon tuile imprimée), tailles optiques équilibrées. Pierres mouchetées et fissurées, cadre doré arrondi avec reflet, glace avec stries et liseré.
  - **Grille** : boîte laquée (lèvre de bronze, biseau doré, fond sombre) dont les coins suivent ceux des cases, cases vides creusées en léger damier. Plateau : une plaque par pièce, pièces plus grandes (0,72), réduites seulement si elles ne tiennent pas.
  - **Glisser** : silhouette dorée de l'endroit où la pièce va tomber, pièce tenue agrandie et relevée avec son ombre, liseré doré qui bat autour des cases qui seraient effacées (dessinés sur un calque à part : la grille n'est pas redessinée à chaque image).
  - **Effacer** (`ClearEffects`, lumière en mode additif) : faisceau doré qui part de la pièce et court le long de la ligne, éclats de tuile (ivoire sur jade), étincelles à l'encre du symbole, anneau doré coupé au cadre ; grille vide : vague de lumière en diagonale et halo qui sort du cadre. Mot d'encouragement doré sur un ruban dont la couleur monte avec la force du coup (nuit → jade → vermillon → vermillon avec reflet), **un seul nombre de points à la fois**, au-dessus de la pièce. Plafond de 150 particules.
  - **Interface** : score en grand au centre, record dans une pastille à couronne, jauge dorée, combo en pastille vermillon, bouton de menu rond à icône (`GameIcons`, `IconButton` : icônes dessinées par le code), « Difficulté N » gardé mais petit et pâle. Boutons de bonus avec icône ; quand ils appellent, ils passent au vermillon cerclé d'or et battent doucement ; une icône « vidéo » marque tout bouton qui lance une pub (le texte le dit toujours).
  - **Fin de partie et niveau réussi** : une carte en forme de tuile (ivoire, bandeau de jade, liseré doré) qui grandit, score qui défile, une seule action principale ; les effets en cours sont retirés à l'ouverture ; grille refroidie en bleu nuit plutôt que grisée. Niveau réussi : **étoiles** (1 pour la réussite, +1 à partir de 1 pièce restante, +1 à partir de 3 : `LevelGame.stars`, `LevelSet.star_pieces` ; affichées sur la carte seulement, pas encore sauvegardées) et feu d'artifice derrière la carte.
  - **Record battu** : bandeau doré « Nouveau record » qui glisse du haut, score doré jusqu'à la fin de la partie, feu d'artifice en traits (or, vermillon, jade).
  - **Menu** : logo en tuiles, « Jouer » en grand, « Niveaux » et « Défi du jour » en deux cartes, réglages derrière la roue dentée (« Quitter » y est rangé, caché sur téléphone). **Carte des niveaux** : titre centré, boutons en forme de tuile (étoile si réussi, cadenas si fermé, liseré qui bat sur le niveau à jouer).
  - **Icône de l'application (2026-11-12)** : une tuile d'ivoire sur son dos de jade, penchée, gravée d'une pièce de blocs (trois carrés vermillon et un rond doré), sur le bleu nuit ; dessinée par le code (`tools/assets/make_icon.py` → `assets/icon/`), branchée dans `project.godot` (`config/icon`) et le préréglage Android (`launcher_icons/…` : icône classique, adaptative et monochrome). Aperçu : `/mnt/project-files/captures/icone/apercu.png`.
  - **Laissé de côté** : le trait lumineux reliant les tuiles identiques d'un groupe pendant l'aperçu (il faudrait que `clears_if_placed` dise quelles cases forment un groupe) ; les étoiles par niveau sur la carte des niveaux (demande une sauvegarde et sa migration) ; le reflet qui balaie en continu les tuiles dorées (redessinerait la grille à chaque image).
- **Critères** : `make lint check test build` verts ; captures regardées ; tests unitaires (synthèse, aperçu d'effacement, hauteur du combo, réglages, étoiles) et de scénario (aperçu, points en un seul nombre, lumière, carte de fin sur une grille nette, bandeau du record, boutons qui appellent, réglages du menu, boutons de la carte).
- **À tester par Stelio** : le jeu paraît-il vivant sans être chargé ? les sons et la musique plaisent-ils (trop forts, trop aigus, lassants) ? l'aperçu des lignes aide-t-il ? fluidité sur son téléphone (beaucoup d'effets).
- **Dépend de** : G13.

### G4. …

- **Objectif** :
- **Périmètre** :
- **Critères** :
- **Dépend de** :
