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
