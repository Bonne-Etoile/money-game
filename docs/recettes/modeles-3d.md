# Modèles 3D

Méthode suivie sur *River Cleaner: India* (G18, G26, G27, G30, G33, G52 à G62, décision 31 de son architecture) : déchets, décor, animaux, héros et statues, faits par script puis jugés dans le jeu. Les pièges détaillés : `docs/pitfalls/modeles-3d.md`.

## 1. Décider avant de modéliser

| Question | Pourquoi |
|---|---|
| Combien d'exemplaires à l'écran ? | Des milliers : opaque, environ 1 500 triangles, niveaux de détail, une matière partagée, pas de transparence ni de surcouche. Une pièce unique : jusqu'à 40 000 triangles. |
| À quelle distance le voit-on ? | Les détails invisibles à distance de jeu sont du coût pur. |
| Taille réelle ou agrandie ? | Un petit objet à viser se fait 1,5 fois plus grand que nature (les déchets de River Cleaner). |
| Quelles parties le jeu doit-il retrouver ? | Surfaces dans un ordre fixe (surface 0 = étiquette), parties nommées pour l'animation (`wing_l`, `tail`), point d'appui. |

## 2. Des références d'abord

1. Claude écrit le prompt d'une **planche de quatre vues** (face, dos, côté, trois quarts) du même objet, fond gris uni, lumière douce, style voulu (« low poly stylised indie game prop »), marque fictive à écrire exactement, aucun logo réel.
2. Le joueur génère l'image (Nano Banana a très bien marché ; les services gratuits sans clé donnent des images floues avec filigrane).
3. L'image reste une **référence** : jamais dans le jeu, jamais dans le dépôt si elle est lourde. Vérifier qu'aucune vraie marque n'est imitée.

Sur River Cleaner, la même statue refaite d'après une référence a été jugée nettement meilleure à l'aveugle (7/6/6/6/8 contre 4/4/5/4/6).

## 3. Choisir l'outil

| Quoi | Outil | Dans ce modèle |
|---|---|---|
| Personnage, statue, créature (modelé fin) | Outil 3D par IA (Tripo Studio, choisi par le joueur), à partir de la référence ; export glb | `tools/assets/import_glb_mesh.gd` |
| Accessoire simple (bouteille, tonneau, caisse) | Blender par script | `tools/assets/blender/build_prop_example.py` |
| Procédural, très simple, ou généré par le jeu (terrain, plantes légères, interface 3D) | `SurfaceTool` dans un script Godot | `tools/assets/build_mesh_example.gd` |
| Décor générique (arbres, rochers) | Pack CC0 (Quaternius, Kenney), converti par script | voir `import_megakit.py` de River Cleaner |

Un modèle fait par script se refait à l'identique en relançant le script, et se modifie par le code : c'est ce qui permet à Claude d'itérer seul.

## 4. Construire

**Dans Godot** (`build_mesh_example.gd`) :

- repère de Godot : y en haut, l'avant vers +z ; une face avant tourne dans le sens horaire vue de l'extérieur (sinon elle est éliminée : on voit l'intérieur) ;
- couleurs de sommets passées par `srgb_to_linear()` (Godot les lit comme linéaires) ;
- `generate_normals()`, une matière avec `vertex_color_use_as_albedo` ;
- niveaux de détail : chaque surface **indexée** (`SurfaceTool.index()`) puis `ImporterMesh.generate_lods()` ; sans index, rien n'est fait et rien ne le dit ;
- `godot --headless --path . --script res://tools/assets/build_mesh_example.gd -- --out=res://assets/models/<x>.res`.

**Dans Blender** (`build_prop_example.py`) :

- `apt-get install -y blender python3-numpy` (le binaire téléchargé est refusé dans la session), puis `blender -b --factory-startup -P script.py -- sortie.glb` ;
- toutes les mesures écrites en repère Godot, converties par une fonction (`blender_point(x, y, z) = (x, -z, y)`) ;
- couleurs de sommets données **en sRGB telles quelles** (le calque de couleur de `bmesh` est stocké en sRGB, l'exporteur convertit) ; marquer le calque pour le rendu (`render_color_index = 0`) et exporter avec `export_colors=True` ;
- `bmesh.ops.recalc_face_normals` ; pas de décimation forte (elle froisse les formes fines) : réduire la densité à la source ;
- l'erreur « Draco mesh compression is not available » du Blender d'Ubuntu est sans effet (pas de compression demandée).

**Depuis un outil par IA** : exporter en glb, vérifier l'échelle et l'orientation, puis `import_glb_mesh.gd` pour connaître triangles et niveaux de détail ; si le modèle dépasse le budget, le réduire dans Blender (décimation légère, en excluant les parties fines).

## 5. Importer

- Un modèle unique (personnage, bâtiment) : le glb dans `assets/models/`, utilisé comme scène.
- Un modèle en milliers d'exemplaires ou partagé : `godot --headless --path . --script res://tools/assets/import_glb_mesh.gd -- modele.glb res://assets/models/<x>.res`. L'outil indexe, fait les niveaux de détail, garde les matières (en affichant les couleurs de sommets, que l'import glTF ignore sinon : modèle blanc) et affiche triangles et niveaux par surface.

## 6. Juger dans le jeu

1. `make model-view MODELS=res://assets/models/a.res,res://assets/models/b.glb` : les modèles côte à côte sous la lumière du jeu, capture dans `build/screenshots/models.png`. Puis la regarder.
2. Le juger aussi dans sa vraie situation (une scène de `test/fixtures/` qui le place dans le niveau, avec l'éclairage et les shaders du jeu) : un modèle propre dans Blender peut être froissé dans le jeu à cause d'un shader.
3. Vérifier les teintes sombres (une couleur de sommet mal convertie ressort beaucoup plus claire ou plus foncée) et de près (faces inversées).
4. Pour un modèle important : critique **à l'aveugle** par un agent séparé, avec la référence (skill `gauntlet-loop` de River Cleaner).
5. Mesurer si le modèle existe en nombre (`docs/recettes/mesurer.md`).

## 7. Licences et déclaration

Une ligne dans `assets/LICENSES.md` : le script qui le produit (« Claude, code écrit par IA ») ou l'outil par IA et son forfait, les références consultées (non incluses), les retouches. À déclarer dans le questionnaire de contenu de Steamworks.
