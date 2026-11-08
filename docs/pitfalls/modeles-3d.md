# Pièges : modèles 3D (références, Blender, Tripo, import dans Godot)

Format : **symptôme**, **cause**, **bonne pratique** (voir `README.md`). Décisions sur les outils : `docs/architecture.md`, décision 31.

## Générer des images de référence : le service compte

- **Symptôme** : Pollinations.ai (gratuit, sans clé) donne des images floues, avec filigrane, et un modèle imposé dont la licence n'est pas claire.
- **Cause** : service gratuit de faible qualité.
- **Bonne pratique** : Claude ne génère pas d'images lui-même ; il écrit le prompt, le joueur génère (Nano Banana a très bien marché). Les images ne servent que de **références** : elles ne vont jamais dans le jeu. Prompt type : une planche de **quatre vues** (face, dos, côté, trois quarts) du même objet, fond gris uni, lumière douce, style « accessoire de jeu indépendant », marque fictive à écrire exactement, aucun logo réel (voir la conversation du 02/11/2026 reprise dans le ticket de chaque déchet). Vérifier à chaque image qu'aucune vraie marque n'est imitée.

## Tripo pour les personnages et les statues, Blender pour les accessoires

- **Symptôme** : un Ganesh modélisé par script Blender (formes simples fusionnées) reste loin d'une référence riche, même après plusieurs tours de critique.
- **Cause** : un personnage ou une statue demande un modelé fin qu'un script ne produit pas en temps raisonnable.
- **Bonne pratique** (décision de Stelio, 02/11/2026) : Tripo Studio pour le héros et les statues ; scripts Blender (`tools/assets/blender/`) pour les accessoires simples (déchets) ; `SurfaceTool` dans Godot pour le très simple ou le procédural.

## Blender téléchargé : exécution refusée dans la session

- **Symptôme** : le binaire officiel de Blender téléchargé ne peut pas être lancé (refusé par la sécurité de la session).
- **Bonne pratique** : `apt-get install -y blender python3-numpy` (paquet Ubuntu), lancé sans interface : `blender -b --factory-startup -P script.py -- arguments`.

## Rendus Cycles et export glTF sans interface

- **Symptôme** : « Build without OpenImageDenoiser » au rendu ; l'export glTF échoue sans `numpy`.
- **Bonne pratique** : `scene.cycles.use_denoising = False` ; installer `python3-numpy`.

## Couleurs de sommets perdues à l'export glTF

- **Symptôme** : dans Godot, le modèle est blanc (le bouchon bleu de la bouteille aussi).
- **Cause** : l'exporteur ne prend que l'attribut de couleur « de rendu » ; un calque créé par `bmesh` ne l'est pas.
- **Bonne pratique** : après `bm.to_mesh(mesh)`, `mesh.color_attributes.active_color_index = 0` et `render_color_index = 0` ; exporter avec `export_colors=True`. Voir aussi les deux entrées ci-dessous (matière, sRGB).

## Modèle blanc dans Godot malgré ses couleurs de sommets

- **Symptôme** : un glb exporté de Blender avec ses couleurs de sommets (calque marqué pour le rendu, `export_colors=True`) s'affiche blanc dans Godot.
- **Cause** : l'import glTF de Godot garde les couleurs dans le maillage, mais la matière importée ne s'en sert pas comme couleur de base.
- **Bonne pratique** : donner à la surface une matière avec `vertex_color_use_as_albedo` (fait par `tools/assets/import_glb_mesh.gd`) ; vérifier sur `make model-view`.

## Couleurs de sommets de Blender assombries

- **Symptôme** : un tonneau fait dans Blender sort bien plus sombre et plus rouge qu'une caisse de la même couleur faite dans Godot (08/11/2026, modèle Godot).
- **Cause** : le calque de couleur créé par `bmesh` (`bm.loops.layers.color`) est un attribut en octets, stocké en sRGB ; l'exporteur glTF le convertit en linéaire. Convertir soi-même avant donne une double conversion.
- **Bonne pratique** : dans Blender, donner les couleurs sRGB telles quelles ; dans Godot (`SurfaceTool`), les passer par `srgb_to_linear()`. Comparer sur une capture les deux modèles côte à côte.

## Repères de Blender et de Godot

- **Symptôme** : modèle couché ou tourné de 180° dans Godot.
- **Cause** : Blender a z en haut et regarde vers -y ; Godot a y en haut et regarde vers +z.
- **Bonne pratique** : une fonction de conversion dans chaque script (`godot(x, y, z) -> (x, -z, y)`), et toutes les mesures écrites en repère Godot.

## Métaballes : le rayon visible n'est pas le rayon donné

- **Symptôme** : des métaballes voisines ne fusionnent pas.
- **Cause** : la surface visible est à environ 0,6 × le rayon.
- **Bonne pratique** : diviser les rayons voulus par ce facteur (`BLOB_SURFACE` dans `build_ganesh.py`).

## Décimer froisse les formes fines

- **Symptôme** : après `Decimate`, des facettes et des pétales déchiquetés.
- **Cause** : la décimation écrase surtout les parties fines et courbées.
- **Bonne pratique** : réduire la densité à la source (subdivisions, résolution des métaballes) plutôt que décimer fort ; décimer à part en excluant les parties fines (`export()` de `build_ganesh.py`).

## Un modèle propre dans Blender, froissé dans le jeu

- **Symptôme** : pétales lisses et roses dans Blender, froissés et lilas dans Godot.
- **Cause** : l'éclairage « peint » à deux tons des animaux (bord très court, ombre bleutée) découpait les surfaces creusées. Ni la décimation ni le modèle n'y étaient pour rien.
- **Bonne pratique** : juger un modèle sur une capture du jeu (`STATUE=… make screenshot SCENE=res://test/fixtures/statue_view.tscn`), et donner aux familles d'objets leur propre matière si besoin (`statue_paint.tres` sur la branche d'essais).

## Garder la structure attendue par le jeu

- **Symptôme** : les marques ne s'appliquent plus, ou sur la mauvaise partie.
- **Cause** : le jeu attend la surface 0 = étiquette (coordonnées de texture qui font le tour), surface 1 = le reste (couleurs de sommets).
- **Bonne pratique** : deux matières dans Blender, dans cet ordre (`export_materials="PLACEHOLDER"`), puis `tools/assets/import_blender_trash.gd` qui reconstruit la ressource du jeu avec ses matières et ses niveaux de détail. Même taille et même encombrement que le modèle remplacé.

## Des milliers d'exemplaires : opaque, peu de triangles, niveaux de détail

- **Symptôme** : une bouteille transparente, jolie de près, aurait été dessinée à part pour chacun des milliers de déchets.
- **Cause** : un objet transparent n'est pas regroupé avec les autres ; il passe dans un rendu trié à part (voir `rendu-et-performance.md`).
- **Bonne pratique** : pour un objet en milliers d'exemplaires, opaque, environ 1 500 triangles, niveaux de détail générés (`ImporterMesh.generate_lods`). Une pièce unique (statue) peut aller à 40 000 triangles ; au-delà, l'écart ne se voit plus à distance de jeu.

## Couleurs de sommets lues comme linéaires

- **Symptôme** : le pneu de `build_trash.gd` (G62), gris très foncé dans le code (0,16), s'affichait gris moyen, presque beige sous la crasse.
- **Cause** : Godot lit les couleurs de sommet comme des couleurs linéaires ; une valeur pensée en sRGB ressort bien plus claire (0,16 linéaire ≈ 0,44 sRGB). Les teintes claires des autres déchets cachaient l'écart.
- **Bonne pratique** : passer chaque couleur de sommet par `srgb_to_linear()` (comme le décor, `CLAUDE.md`) et vérifier en capture les teintes sombres.
