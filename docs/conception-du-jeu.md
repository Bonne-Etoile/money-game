# Conception du jeu

Référence pour tout ce qui touche au gameplay. Chaque décision du joueur y entre datée ; les questions ouvertes restent visibles jusqu'à leur réponse.

## 1. Le jeu en une phrase

Un puzzle de blocs dont les pièces sont faites de tuiles de mahjong : on pose des pièces sur une grille, et on efface en complétant des lignes ou en réunissant des symboles. Deux prototypes sont comparés avant de choisir (`docs/backlog.md`, D2, G1 et G2). **Choix de Stelio (2026-11-09)** : le jeu est le prototype 1 « blocs de tuiles », avec un **mode infini** et un **mode à niveaux à objectifs** (`docs/backlog.md`, G17). Le prototype 5 « tampon sur la pile » pourrait devenir un jeu à part, plus tard.

## 2. Boucle de jeu

Ce que fait le joueur à la minute, à la session, sur toute la partie.

### Prototype 1 « blocs de tuiles » (G1, 2026-11-08)

- Grille 8 × 8. Trois pièces proposées sous la grille ; on les fait glisser sur la grille, dans l'ordre qu'on veut. **Retours de Stelio (2026-11-09)** : les pièces sont **les 7 formes du Tetris d'origine** (I, O, T, S, Z, J, L ; réglage `shape_keys`), **toucher une pièce la tourne** d'un quart de tour (`can_rotate`, aussi dans les prototypes 2, 4 et 5), et **une nouvelle pièce prend aussitôt la place** de celle qu'on vient de poser (`refill_each_slot`). La partie n'est perdue que si aucune pièce ne rentre dans aucun de ses sens.
- Chaque case d'une pièce porte un **symbole** (5 symboles : rond rouge, carré vert, triangle bleu, losange violet, étoile jaune ; forme **et** couleur, pour les daltoniens).
- **Effacement** : une ligne ou une colonne pleine, **ou** 3 symboles identiques (ou plus) qui se touchent par un côté. Tout ce qui est effacé en même temps compte une fois.
- Une pièce tirée au hasard ne contient jamais à elle seule 3 symboles identiques qui se touchent (sinon elle s'effacerait gratuitement en la posant).
- **Score** : 1 point par case posée ; 10 points par case effacée, +50 % par effacement en plus dans le même coup, +50 % par coup du combo (coups d'affilée qui effacent ; le combo survit à 2 coups sans effacement).
- **Fin** : quand aucune des pièces restantes ne rentre ; « Rejouer » relance une partie.
- **Continuer après une pub** (G3) : une fois par partie, l'écran de fin propose « Continuer (regarder une pub) ». Une pub récompensée vue jusqu'au bout dégage une croix de 3 lignes et 3 colonnes au centre de la grille (sans points), assez pour que toutes les formes rentrent, et la partie reprend avec les mêmes pièces. Pub fermée avant la fin : rien ne change. Bouton grisé tant qu'aucune pub n'est prête.
- **Difficulté adaptative** (G9, demande de Stelio, 2026-11-09 : « c'est beaucoup trop facile ») : chaque nouvelle pièce est tirée parmi plusieurs au hasard, et le jeu donne celle qui a **le moins de place** sur la grille (comptée dans tous ses sens). Le nombre de pièces tirées dépend d'un **niveau** affiché en haut (« Difficulté 0 » à 5) : +1 tous les 200 points de la partie, +1 tant que le combo atteint 3 (il enchaîne facilement), et jusqu'à +2 dès le départ selon la moyenne de ses 10 dernières parties (à partir de la 3ᵉ partie : un nouveau joueur commence au niveau 0, pur hasard). Niveaux 0 à 5 : 1, 2, 2, 3, 3, 4 pièces tirées. Pas de mur : n'importe quelle pièce peut toujours venir, on peut la tourner, et le jeu reste jouable sans pub. Réglages : `game/data/difficulty_rules.tres`.
- **Bonus** (G9) : deux boutons sous les pièces, **une utilisation gratuite par partie**, puis **une de plus par pub récompensée regardée jusqu'au bout** (au plus 3 pubs par bonus et par partie). Le bouton dit toujours ce qu'il fait : « Nouvelles pièces (1) » (gratuit) ou « Nouvelles pièces (pub) » (texte bleu), grisé si la pub n'est pas prête.
  - **Nouvelles pièces** : les 3 pièces sont remplacées ; pour chacune, le jeu tire 3 pièces et garde celle qui a **le plus** de place, pour que le bonus aide vraiment. Aussi proposé sur l'écran de fin.
  - **Miroir** : le prochain toucher sur une pièce la retourne de gauche à droite (S ↔ Z, J ↔ L) au lieu de la tourner ; toucher « Annuler » rend la main sans rien dépenser.
  - **Appel au bonus** : quand il ne reste qu'une pièce qui rentre (`trouble_fitting_pieces`), les boutons bonus clignotent en doré. C'est le moment où la pub vaut le plus aux yeux du joueur.
  - L'écran de fin montre aussi le **record**.
- **Suivi du joueur** (G9) : sessions, parties, record, 10 derniers scores, coups, et pour chaque emplacement de pub : offres montrées au bon moment, pubs vues jusqu'au bout, pubs fermées avant ; bonus utilisés. Gardé dans la sauvegarde (`PlayerStats`), lu par la difficulté adaptative.
- Réglages : `game/data/tile_blocks_rules.tres` (taille, symboles, pièces, score, bonus), formes dans `game/data/piece_shapes.tres` (25 formes, chacune avec un poids de tirage), difficulté dans `game/data/difficulty_rules.tres`.

### Prototype 2 « la pyramide fournit les pièces » (G2, 2026-11-08)

- En haut, une pile de tuiles de mahjong (2 ou 3 étages). Chaque tuile montre la **pièce** qu'elle donne. Une tuile se prend quand elle est **libre** (règle du mahjong) : rien posé dessus, et son côté gauche ou droit dégagé. Les tuiles qu'on ne peut pas prendre sont assombries.
- Toucher une tuile libre la met dans le **plateau** (2 places) ; on fait glisser la pièce sur la grille 8 × 8 du bas, comme dans le prototype 1. Les 2 places permettent de garder une pièce gênante pour plus tard.
- **Effacement** : lignes et colonnes pleines seulement. La règle du trio est réglable (`match_size`) mais coupée : une pièce porte ici un seul symbole, une pièce de 3 cases s'effacerait toute seule. À revoir selon le test du prototype 1.
- **Niveau gagné** quand la pile et le plateau sont vides ; **perdu** quand aucune pièce du plateau ne rentre et qu'on ne peut plus rien prendre (plateau plein, ou pile vide). Boutons « Niveau suivant », « Recommencer », « Menu ».
- **5 niveaux faits à la main** (`game/data/pyramid_rules.tres`) : de 8 à 29 tuiles ; les niveaux 3 à 5 commencent avec des tuiles déjà sur la grille. Chaque niveau est gagné par un robot simple (test `test_every_level_can_be_won`) : aucun n'est impossible. Le dessin d'une pile : un texte par étage, une lettre = le coin d'une tuile et sa forme (`legend`), en demi-tuiles comme au mahjong.
- Le score suit les mêmes règles que le prototype 1 (pas d'objectif de score pour l'instant).

### Prototype 3 « tuiles sur petite grille » (G5, piste 3, 2026-11-08)

- L'écran du prototype 2, mais chaque tuile de la pile est **une seule tuile à symbole**, posée sur une grille **5 × 5** ; le plateau n'a qu'une place.
- **Effacement** : 3 symboles identiques (ou plus) qui se touchent, ou une ligne/colonne pleine. Chaque symbole est présent par 3 dans la pile (`symbols_in_threes`), pour que tout puisse partir.
- **Gagné** : pile vide ; **perdu** : grille pleine avec une tuile en main. 3 niveaux (12, 18, 24 tuiles), `game/data/tray_grid_rules.tres`.

### Prototype 4 « paires » (G6, piste 4, 2026-11-08)

- Le prototype 1 avec **2** symboles identiques qui se touchent au lieu de 3, et 6 symboles au lieu de 5 pour compenser (`game/data/pairs_rules.tres`). Question à trancher : la partie devient-elle trop facile (infinie) ?

### Prototype 5 « tampon sur la pile » (G7, idée de Stelio, 2026-11-08)

- En haut à gauche, une **pile en colonnes** 6 × 6 (chaque case a de 0 à 4 tuiles empilées ; on voit la tuile du dessus). En haut à droite, la **forme de Tetris** à poser (vide, en bleu) et les 2 suivantes.
- On fait glisser la forme sur la pile : elle doit recouvrir des tuiles sur toutes ses cases ; elle **prend la tuile du dessus** de chaque case et devient une **pièce tuilée**, qui va dans la main.
- On fait glisser la pièce sur la grille 8 × 8 : lignes, colonnes et **trios** s'effacent. Choisir où poser la forme sur la pile permet donc de « ramasser » les bons symboles (une pièce peut même contenir un trio déjà fait, effacé dès la pose : une récompense pour qui l'a trouvé).
- Quand plus aucune forme de Tetris ne tient sur la pile (tuiles éparses à la fin), la forme est remplacée par la plus grande petite forme qui tient (3, 2 puis 1 case).
- **Gagné** : pile vide ; **perdu** : la pièce en main ne rentre plus. 3 niveaux (36, 56, 88 tuiles), `game/data/stamp_rules.tres`, chacun gagné par un robot simple dans les tests.

## 3. Contrôles

Un seul doigt : glisser-déposer les pièces (action `pointer` ; la souris sur PC). La pièce tirée est dessinée au-dessus du doigt (1,2 case) pour rester visible, et son emplacement apparaît en ombre sur la grille (blanche si elle rentre, rouge sinon). Retour (Échap, bouton « Menu ») : retour au menu.

## 4. Progression et économie

## 5. Contenu (niveaux, objets, personnages)

## 6. Interface

## 7. Son et musique

## 8. Direction artistique

Prototype : tout est dessiné par le code (`game/board/tile_drawing.gd`, couleurs dans `game/data/tile_art.tres`) : tuiles ivoire sur tranche dorée, symboles géométriques simples. Une vraie direction artistique viendra une fois le prototype choisi.

## 9. Plateformes, échelle visée, performance

Nombre maximal d'objets à l'écran, machine minimale : à décider ici dès le début.

## 10. Questions ouvertes
