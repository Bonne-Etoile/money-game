# Conception du jeu

Référence pour tout ce qui touche au gameplay. Chaque décision du joueur y entre datée ; les questions ouvertes restent visibles jusqu'à leur réponse.

## 1. Le jeu en une phrase

Un puzzle de blocs dont les pièces sont faites de tuiles de mahjong : on pose des pièces sur une grille, et on efface en complétant des lignes ou en réunissant des symboles. Deux prototypes sont comparés avant de choisir (`docs/backlog.md`, D2, G1 et G2). **Choix de Stelio (2026-11-09)** : le jeu est le prototype 1 « blocs de tuiles », avec un **mode infini** et un **mode à niveaux à objectifs** (`docs/backlog.md`, G17). Le prototype 5 « tampon sur la pile » pourrait devenir un jeu à part, plus tard.

## 2. Boucle de jeu

Ce que fait le joueur à la minute, à la session, sur toute la partie.

### Prototype 1 « blocs de tuiles » (G1, 2026-11-08)

- Grille 8 × 8. Trois pièces proposées sous la grille ; on les fait glisser sur la grille, dans l'ordre qu'on veut. **Retours de Stelio (2026-11-09)** : les pièces sont **les 7 formes du Tetris d'origine** (I, O, T, S, Z, J, L ; réglage `shape_keys`), **toucher une pièce la tourne** d'un quart de tour (`can_rotate`), et **une nouvelle pièce prend aussitôt la place** de celle qu'on vient de poser (`refill_each_slot`). La partie n'est perdue que si aucune pièce ne rentre dans aucun de ses sens.
- Chaque case d'une pièce porte un **symbole** (5 symboles : rond rouge, carré vert, triangle bleu, losange violet, étoile jaune ; forme **et** couleur, pour les daltoniens).
- **Effacement** : une ligne ou une colonne pleine, **ou** 3 symboles identiques (ou plus) qui se touchent par un côté. Tout ce qui est effacé en même temps compte une fois.
- Une pièce tirée au hasard ne contient jamais à elle seule 3 symboles identiques qui se touchent (sinon elle s'effacerait gratuitement en la posant).
- **Score** : 1 point par case posée ; 10 points par case effacée, +50 % par effacement en plus dans le même coup, +50 % par coup du combo (coups d'affilée qui effacent ; le combo survit à 2 coups sans effacement).
- **Fin** : quand aucune des pièces restantes ne rentre ; « Rejouer » relance une partie.
- **Continuer après une pub** (G3) : une fois par partie, l'écran de fin propose « Continuer (regarder une pub) ». Une pub récompensée vue jusqu'au bout dégage une croix de 3 lignes et 3 colonnes au centre de la grille (sans points), assez pour que toutes les formes rentrent, et la partie reprend avec les mêmes pièces. Pub fermée avant la fin : rien ne change. Bouton grisé tant qu'aucune pub n'est prête.
- **Difficulté adaptative** (G9, demande de Stelio, 2026-11-09 : « c'est beaucoup trop facile ») : chaque nouvelle pièce est tirée parmi plusieurs au hasard, et le jeu donne celle qui a **le moins de place** sur la grille (comptée dans tous ses sens). Le nombre de pièces tirées dépend d'un **niveau** affiché en haut (« Difficulté 0 » à 5) : +1 tous les 200 points de la partie, +1 tant que le combo atteint 3 (il enchaîne facilement), et jusqu'à +2 dès le départ selon la moyenne de ses 10 dernières parties (à partir de la 3ᵉ partie : un nouveau joueur commence au niveau 0, pur hasard). Niveaux 0 à 5 : 1, 2, 2, 3, 3, 4 pièces tirées. Pas de mur : n'importe quelle pièce peut toujours venir, on peut la tourner, et le jeu reste jouable sans pub. Réglages : `game/data/difficulty_rules.tres`.
- **Record au centre** (G10, 2026-11-09) : le record est affiché en permanence sous la barre du haut, avec une barre dorée qui se remplit vers lui. Quand le score le dépasse, le texte devient « Nouveau record ! » et grossit un instant. Sur l'écran de fin, au-dessus de « Continuer », une ligne dit ce qu'il manquait (« Il vous manquait 121 points pour battre votre record ») ou salue le record battu. Le record qui compte est celui du début de la partie (`RecordChase`).
- **Difficulté dans les deux sens** (G11, 2026-11-09) : sous le niveau 0, le jeu tire 2 (niveau −1) ou 3 (niveau −2) pièces et donne celle qui a **le plus** de place. Les 2 premières parties d'un nouveau joueur commencent au niveau −1, comme la partie qui suit 2 parties d'affilée sous sa moyenne ; le score de la partie fait remonter le niveau comme d'habitude (+1 tous les 200 points). **Garantie de jouabilité** : tant que la grille est remplie à 70 % au plus, une nouvelle pièce (ou une nouvelle main) ne laisse jamais le joueur sans coup : si aucune pièce ne rentre, la dernière tirée est remplacée par une pièce qui rentre. Au-delà, perdre est juste. La difficulté ne lit jamais l'état des pubs. Réglages : `help_candidates_per_level`, `help_level`, `poor_games_for_help`, `playable_until_fill_percent` dans `game/data/difficulty_rules.tres`.
- **Pièces une à une ou par trois** (G12, 2026-11-09) : une option du menu, « Pièces : une à la fois » (une nouvelle pièce prend la place de chaque pièce posée, retour de Stelio du 2026-11-09) ou « trois à la fois » (trois nouvelles pièces quand les trois sont posées, comme Block Blast). Pour comparer les deux sur le même APK (option de test, `GameSettings.refill_together`).
- **Retours d'effacement** (G13, 2026-11-09) : à chaque effacement, un son (plus aigu à chaque coup du combo), des éclats aux couleurs des symboles qui jaillissent des cases, la grille qui tremble et une courte vibration (option « Vibration » du menu), d'autant plus forts que le coup est fort (effacements du coup + combo). Mots d'encouragement : « Bien ! » (force 2), « Super ! » (3), « Génial ! » (5), « Incroyable ! » (7). **Grille vide** : « Grille vide ! +300 », 300 points de bonus (`empty_grid_bonus`) et un arpège. **Record battu** : feu d'artifice et fanfare. Sons faits par le code en attendant de vrais sons. Réglages : `game/data/juice_rules.tres`.
- **Aide à l'hésitation** (G15, 2026-11-09) : après 10 s sans rien faire (`hint_after_seconds`), le placement qui efface le plus de cases apparaît en tuiles pâles sur la grille, déjà tourné si besoin (`MoveHint`). Rien ne s'affiche si aucun placement n'efface : le défi reste. Le moindre geste fait disparaître l'aide.
- **Bonus** (G9) : deux boutons sous les pièces, **une utilisation gratuite par partie**, puis **une de plus par pub récompensée regardée jusqu'au bout** (au plus 3 pubs par bonus et par partie). Le bouton dit toujours ce qu'il fait : « Nouvelles pièces (1) » (gratuit) ou « Nouvelles pièces (pub) » (texte bleu), grisé si la pub n'est pas prête.
  - **Nouvelles pièces** : les 3 pièces sont remplacées ; pour chacune, le jeu tire 3 pièces et garde celle qui a **le plus** de place, pour que le bonus aide vraiment. Aussi proposé sur l'écran de fin.
  - **Miroir** : le prochain toucher sur une pièce la retourne de gauche à droite (S ↔ Z, J ↔ L) au lieu de la tourner ; toucher « Annuler » rend la main sans rien dépenser.
  - **Appel au bonus** : quand il ne reste qu'une pièce qui rentre (`trouble_fitting_pieces`), les boutons bonus clignotent en doré. C'est le moment où la pub vaut le plus aux yeux du joueur.
  - L'écran de fin montre aussi le **record**.
- **Suivi du joueur** (G9) : sessions, parties, record, 10 derniers scores, coups, et pour chaque emplacement de pub : offres montrées au bon moment, pubs vues jusqu'au bout, pubs fermées avant ; bonus utilisés. Gardé dans la sauvegarde (`PlayerStats`), lu par la difficulté adaptative.
- Réglages : `game/data/tile_blocks_rules.tres` (taille, symboles, pièces, score, bonus), formes dans `game/data/piece_shapes.tres` (25 formes, chacune avec un poids de tirage), difficulté dans `game/data/difficulty_rules.tres`.

### Prototypes 2 à 5 (G2, G5, G6, G7) — retirés le 2026-11-09

**Demande de Stelio (2026-11-09)** : « Tu peux supprimer les autres jeux de l'app et ne garder que G1. » Les prototypes 2 « pyramide », 3 « tuiles sur petite grille », 4 « paires » et 5 « tampon sur la pile » sont retirés du menu et du code. Leurs règles et leur code restent dans l'historique git (dernier commit qui les contient : `8774f13`, fusion de la PR #6), pour reprendre le 5 comme jeu à part s'il le faut.

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
