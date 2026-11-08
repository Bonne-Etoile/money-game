# Pièges : Rendu et performance

Format : **symptôme**, **cause**, **bonne pratique** (voir `README.md`).

## Trajectoire vue par la tranche à la première personne

- **Symptôme** : le viseur du lancer est illisible ; sur les captures, tout l'arc se réduit à un trait vertical au centre de l'écran et les flèches proches deviennent d'énormes chevrons.
- **Cause** : le lancer partait du centre de la vue, dans la direction du regard : l'arc est dans un plan qui contient la caméra, donc vu par la tranche. Une flèche orientée vers l'avant est en plus raccourcie par la perspective.
- **Bonne pratique** : faire partir le lancer de la main (décalé sur le côté) ; orienter les flèches face à la caméra, la pointe dans la direction de l'arc *à l'écran* ; réduire la taille des flèches proches de la caméra. Toujours juger un repère 3D sur une capture depuis la vue du joueur.

## Un filtre plein écran efface les objets transparents

- **Symptôme** : le viseur (flèches et anneau, matériaux transparents) n'apparaît plus ; l'écume des rives non plus.
- **Cause** : le filtre « peinture » de G17 était un quad plein écran qui lisait `hint_screen_texture`. Cette texture est copiée après la passe opaque ; le quad, dessiné ensuite, recouvrait tout ce que la passe transparente avait dessiné avant lui.
- **Bonne pratique** : pour un post-traitement qui doit garder les objets transparents, passer par un `CompositorEffect` ou l'`Environment` (ajustements, brouillard), pas par un quad qui lit l'écran. Filtre retiré en G18 ; vérifier le viseur avec `make screenshots` (`aim_guide_*`).

## Mesurer une image : `--headless` plafonne la boucle vers 145 images/s

- **Symptôme** : une mesure de performance lancée avec `--headless` donne 6,9 ms par image (145 images/s), que la rivière ait 0 ou 1 000 déchets (G48).
- **Cause** : sans fenêtre qui puisse dessiner, Godot ralentit sa boucle principale ; `Engine.max_fps = 0` n'y change rien. Le compteur `Performance.TIME_PROCESS` n'aide pas non plus (valeurs absurdes, des centaines de millisecondes pour des images de 1 ms).
- **Bonne pratique** : mesurer sous Xvfb avec `RenderingServer.render_loop_enabled = false` (rien n'est dessiné, la boucle n'est pas freinée), `Engine.max_fps = 0` et la synchronisation verticale coupée, et prendre le temps entre deux images (`Time.get_ticks_usec`) ; `make benchmark` le fait (`TrashBenchmark`, `--no-draw`).

## Une surcouche transparente sur des milliers d'objets les dessine un par un

- **Symptôme** : à 10 000 déchets, 16 500 appels de dessin et 22 ms de rendu CPU par image sur le PC de Stelio ; sans la crasse des déchets, 1 400 appels et 5 ms (G52).
- **Cause** : la crasse était un `material_overlay` transparent (`blend_mix`). Godot regroupe les objets opaques qui partagent maillage et matière, mais dessine chaque objet transparent à part, trié : un appel de dessin de plus par déchet.
- **Bonne pratique** : sur ce qui existe en milliers d'exemplaires, mettre l'effet dans la matière opaque elle-même (shader commun, une matière par source, partagée : `Trash.grimy`), et garder les surcouches pour un objet à la fois (la surbrillance du déchet visé). Mesurer avec `make benchmark` et le bouton du menu avant et après.

## `instance uniform` : 16 places par objet, et le tampon s'épuise

- **Symptôme** : au-delà de quelques milliers de déchets, « Too many instances using shader instance variables. Increase buffer size in Project Settings » ; les déchets en trop gardent la valeur par défaut du paramètre (tous le même motif de crasse) (G57).
- **Cause** : chaque objet qui a des paramètres par instance (`instance uniform`) réserve un bloc de 16 places dans un tampon commun (`rendering/limits/global_shader_variables/buffer_size`, 65 536 par défaut, soit environ 4 000 objets), même pour un seul `float`. Un jumeau qui porte la même matière (ombre) en réserve un autre.
- **Bonne pratique** : pas d'`instance uniform` sur ce qui existe en milliers d'exemplaires ; quelques variantes de la matière à la place (`Trash.GRIME_PATTERNS`, huit motifs par matière, quelques dizaines de groupes de dessin), ou les données par instance d'un `MultiMesh` (`INSTANCE_CUSTOM`, `RippleField`). Agrandir le tampon ne va pas loin : 100 000 objets en demanderaient 1,6 million de places (25 Mo).

## `generate_lods` ne fait rien sur un maillage sans index

- **Symptôme** : après `ImporterMesh.generate_lods()`, le modèle n'a aucun niveau de détail (`RenderingServer.mesh_get_surface(...)["lods"]` vide), et rien ne le signale. Les modèles de `build_trash.gd` sont restés à pleine définition à toute distance de G52 à G58, alors que la doc disait le contraire.
- **Cause** : un maillage fait avec `SurfaceTool` sans `index()` n'a pas de tableau d'indices ; les niveaux de détail ne se calculent que sur un maillage indexé.
- **Bonne pratique** : `SurfaceTool.create_from(mesh, surface)`, `index()`, `commit_to_arrays()` avant `generate_lods` ; et **vérifier** le résultat (compter les niveaux par surface) au lieu de le supposer. Un modèle glTF importé (Blender) est déjà indexé.
