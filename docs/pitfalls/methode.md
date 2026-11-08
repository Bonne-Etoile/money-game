# Leçons de méthode

Ce qui a fait gagner ou perdre du temps dans la façon de travailler, pas dans un outil précis. Valable pour tout jeu. Format : **leçon**, **ce qui s'est passé** (l'épisode de River Cleaner qui l'a apprise), **pratique**.

## Mesurer avant d'optimiser, et mesurer le bon chiffre

- **Ce qui s'est passé** : avant G48, on pensait que le nombre de triangles des modèles serait le problème avec des milliers de déchets. La mesure a montré que c'était notre code : la rivière qui parcourait tous ses déchets à chaque image, une zone d'eau qui surveillait chaque déchet, deux scripts par déchet immobile. Sans ces trois postes, 10 000 déchets passaient de 226 ms à 0,2 ms par image, sans dessin. Ensuite, côté dessin, ce n'étaient pas les triangles mais une surcouche transparente (la crasse) qui empêchait de regrouper les objets.
- **Pratique** :
  - une scène de mesure dès qu'une échelle est en jeu (`make benchmark`) : paliers de quantité, temps d'image (moyenne, 95e centile, pire), comptes d'objets et d'appels de dessin ;
  - des **variantes qui retirent un poste à la fois** : c'est elles qui désignent le coupable, pas l'intuition ;
  - se fier au temps entre deux images, pas aux compteurs internes du moteur (`TIME_PROCESS`, `TIME_PHYSICS_PROCESS` donnaient des valeurs absurdes) ;
  - consigner chaque mesure avant/après dans un document (`docs/performance.md`) ;
  - **lire le journal de la mesure** (erreurs du moteur) avant d'en croire les chiffres : à 30 000 déchets, Jolt refusait silencieusement les corps au-delà de 10 240, et le rendu manquait de place pour les paramètres par instance au-delà de 4 000 objets (G57) ;
  - **pousser la mesure bien au-delà de la cible** (100 000 pour une cible de 10 000) : c'est là qu'apparaissent les limites fixes du moteur.

## Mesurer sur la machine du joueur

- **Ce qui s'est passé** : la session cloud n'a pas de carte graphique (rendu logiciel) : ses temps de rendu ne veulent rien dire. Le bouton « Mesure de performance » du menu, qui copie un rapport texte à coller dans la conversation, a donné en quelques minutes les vrais temps sur le PC de Stelio, à chaque étape.
- **Pratique** : tout ce qui se mesure ou se règle sur de vraies parties passe par un bouton du jeu qui **copie un rapport texte** (mesure de performance, journal de partie pour l'équilibrage, G39). Le joueur colle, Claude lit. Ces boutons sont listés dans `docs/avant-la-sortie.md` pour être retirés.

## Concevoir pour l'échelle visée dès le premier jour

- **Ce qui s'est passé** : le jeu a été écrit pour 150 déchets ; passer à 10 000 a demandé six tickets (G48 à G52, G54).
- **Pratique**, pour tout objet qui existera en milliers d'exemplaires :
  - pas de script appelé à chaque image sur un objet immobile (couper `_process`/`_physics_process` et les rallumer sur événement) ;
  - pas de boucle « sur tous les objets » à chaque image : tenir les états à jour par événements, et une liste des seuls objets qui bougent ;
  - pas de transparence ni de surcouche par objet (elles empêchent le regroupement) : l'effet dans la matière opaque, une matière partagée par source ;
  - ombres et petits détails coupés au-delà d'une distance où ils ne font que quelques pixels, niveaux de détail des modèles ;
  - placements et recherches de voisins en grille, jamais en comparant tout à tout.

## Toute optimisation sans coût visible se fait

- **Ce qui s'est passé** : règle de Stelio (03/11/2026), après G52 : couper les ombres et ondulations trop lointaines pour être vues, même quand la version actuelle tient déjà.
- **Pratique** : si un gain de performance ne change rien de ce que voit ou ressent le joueur, on le prend sans demander. Si ça change quelque chose de visible, on montre des captures avant/après et c'est le joueur qui décide.

## Un test qui échoue sur une seule machine n'est pas forcément du hasard

- **Ce qui s'est passé** : `poc_river_test` échouait sur le runner de Stelio et sur GitHub, jamais dans la session. La même valeur exacte (-0,14011) sur deux machines prouvait que c'était déterministe : un test lancé juste avant (`statues_test`) changeait l'état interne de Jolt, et un déchet se coinçait sous le plancher d'un amas. C'était un vrai bug, celui que Stelio avait vu en jeu (G45, G54).
- **Pratique** : avant de conclure à un test instable, comparer les valeurs d'échec entre machines ; relancer localement les suites **dans l'ordre de la CI** (journal du job) ; chercher l'état partagé (autoload, ressource modifiée, moteur physique, générateur aléatoire global). Puis corriger la cause dans le jeu, pas seulement le test.

## Voir le résultat dans le jeu, pas dans l'outil

- **Ce qui s'est passé** : le Ganesh fait dans Blender était lisse et rose dans Blender, froissé et lilas dans le jeu : l'éclairage « peint » des animaux ne lui convenait pas. Un réglage du moteur, pas du modèle.
- **Pratique** : toute production visuelle (modèle, shader, interface) se juge sur une **capture du jeu** (`make screenshot`), regardée par Claude, comparée avant/après dans les mêmes conditions (même vue, même saleté). Un rendu dans l'outil d'origine ne prouve rien.

## Des références pour tout ce qui se voit, et un critique séparé

- **Ce qui s'est passé** : Ganesh refait d'après des images de référence générées par Stelio, comparé à l'aveugle à la version sans référence par un critique séparé : 7/6/6/6/8 contre 4/4/5/4/6.
- **Pratique** : pour un modèle ou un visuel important, obtenir d'abord des images de référence (voir `modeles-3d.md`), puis faire juger à l'aveugle par un agent séparé, avec la référence (skill `/gauntlet-loop`).

## Les décisions du joueur, datées et à leur place

- **Ce qui s'est passé** : beaucoup de décisions de Stelio ne vivaient que dans la conversation (passer à Blender, Tripo pour les personnages, plus de CI sur les PR vers `dev`, l'équilibrage reporté). Une session suivante ne les aurait pas connues.
- **Pratique** : chaque décision va, le jour même, là où on la cherchera : une règle de travail dans `CLAUDE.md`, un choix structurant dans `docs/architecture.md`, un choix de ticket dans `docs/backlog.md`, une leçon dans `docs/pitfalls/`. Avec la date et, si possible, les mots du joueur.

## Les essais gardés sur une branche à leur nom

- **Ce qui s'est passé** : les essais Blender (Ganesh, bouteille, paquet de chips) étaient sur la branche de travail de la session, qui est remise à zéro à chaque ticket : ils ont failli être écrasés.
- **Pratique** : un essai qu'on n'intègre pas tout de suite part sur sa propre branche (`claude/essais-<sujet>`), notée dans le backlog.

## Ce que Claude ne peut pas juger

- **Ce qui s'est passé** : la fluidité, les sensations du lancer et le son ont toujours demandé le test de Stelio ; les à-coups à 10 000 déchets ne se voyaient que sur sa machine.
- **Pratique** : grouper ce qui demande le joueur en lots, avec un build de test et une liste précise de quoi tester ; tout le reste (tests, captures, mesures) se vérifie sans lui.

## Une optimisation « évidente » se mesure avant d'être gardée

- **Ce qui s'est passé** : supprimer le jumeau d'ombre des déchets semblait diviser par deux les objets à préparer (G59). Mesuré, c'était l'inverse : sans le jumeau, l'ombre n'était plus coupée à 25 m, et chaque déchet se redessinait dans toutes les cascades d'ombre (183 000 objets au lieu de 135 000).
- **Pratique** : chaque optimisation passe par la mesure avant/après (`make benchmark`, mêmes paliers, mêmes variantes) avant d'être gardée ; une idée qui empire les chiffres est retirée et notée dans le ticket, pour ne pas la refaire.
