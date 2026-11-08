# Conception du jeu

Référence pour tout ce qui touche au gameplay. Chaque décision du joueur y entre datée ; les questions ouvertes restent visibles jusqu'à leur réponse.

## 1. Le jeu en une phrase

Un puzzle de blocs dont les pièces sont faites de tuiles de mahjong : on pose des pièces sur une grille, et on efface en complétant des lignes ou en réunissant des symboles. Deux prototypes sont comparés avant de choisir (`docs/backlog.md`, D2, G1 et G2).

## 2. Boucle de jeu

Ce que fait le joueur à la minute, à la session, sur toute la partie.

### Prototype 1 « blocs de tuiles » (G1, 2026-11-08)

- Grille 8 × 8. Trois pièces proposées sous la grille, sans rotation ; on les fait glisser sur la grille, dans l'ordre qu'on veut. Trois nouvelles pièces quand les trois sont posées.
- Chaque case d'une pièce porte un **symbole** (5 symboles : rond rouge, carré vert, triangle bleu, losange violet, étoile jaune ; forme **et** couleur, pour les daltoniens).
- **Effacement** : une ligne ou une colonne pleine, **ou** 3 symboles identiques (ou plus) qui se touchent par un côté. Tout ce qui est effacé en même temps compte une fois.
- Une pièce tirée au hasard ne contient jamais à elle seule 3 symboles identiques qui se touchent (sinon elle s'effacerait gratuitement en la posant).
- **Score** : 1 point par case posée ; 10 points par case effacée, +50 % par effacement en plus dans le même coup, +50 % par coup du combo (coups d'affilée qui effacent ; le combo survit à 2 coups sans effacement).
- **Fin** : quand aucune des pièces restantes ne rentre ; « Rejouer » relance une partie.
- Réglages : `game/data/tile_blocks_rules.tres` (taille, symboles, pièces, score), formes dans `game/data/piece_shapes.tres` (25 formes, chacune avec un poids de tirage).

### Prototype 2 « la pyramide fournit les pièces » (G2, 2026-11-08)

- En haut, une pile de tuiles de mahjong (2 ou 3 étages). Chaque tuile montre la **pièce** qu'elle donne. Une tuile se prend quand elle est **libre** (règle du mahjong) : rien posé dessus, et son côté gauche ou droit dégagé. Les tuiles qu'on ne peut pas prendre sont assombries.
- Toucher une tuile libre la met dans le **plateau** (2 places) ; on fait glisser la pièce sur la grille 8 × 8 du bas, comme dans le prototype 1. Les 2 places permettent de garder une pièce gênante pour plus tard.
- **Effacement** : lignes et colonnes pleines seulement. La règle du trio est réglable (`match_size`) mais coupée : une pièce porte ici un seul symbole, une pièce de 3 cases s'effacerait toute seule. À revoir selon le test du prototype 1.
- **Niveau gagné** quand la pile et le plateau sont vides ; **perdu** quand aucune pièce du plateau ne rentre et qu'on ne peut plus rien prendre (plateau plein, ou pile vide). Boutons « Niveau suivant », « Recommencer », « Menu ».
- **5 niveaux faits à la main** (`game/data/pyramid_rules.tres`) : de 8 à 29 tuiles ; les niveaux 3 à 5 commencent avec des tuiles déjà sur la grille. Chaque niveau est gagné par un robot simple (test `test_every_level_can_be_won`) : aucun n'est impossible. Le dessin d'une pile : un texte par étage, une lettre = le coin d'une tuile et sa forme (`legend`), en demi-tuiles comme au mahjong.
- Le score suit les mêmes règles que le prototype 1 (pas d'objectif de score pour l'instant).

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
