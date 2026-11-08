# Pièges : Physique (Jolt)

Format : **symptôme**, **cause**, **bonne pratique** (voir `README.md`).

## Un déchet lancé traverse le sol

- **Symptôme** : un déchet lancé sur la berge disparaît sous le terrain, puis flotte à la surface de l'eau (sous la terre) ; `landing_position` reste `null`.
- **Cause** : le sol de la rivière (G18) est un `ConcavePolygonShape3D`, une surface sans épaisseur ; un petit corps rapide la traverse entre deux pas de physique. Les anciennes berges étaient des boîtes, épaisses.
- **Bonne pratique** : `continuous_cd = true` sur les corps petits et rapides (déchets). `test_predicted_landing_matches_the_real_throw` échoue sans cette option : il sert de garde-fou.

## Jolt : un corps posé peut trembler sans jamais paraître arrêté

- **Symptôme** : un déchet lancé, posé sur un obstacle de la rive, ne s'arrête jamais (`Trash.thrown` reste vrai, le raté n'est pas compté) ; seulement dans la suite complète des tests, où le déchet tombe ailleurs.
- **Cause** : posé sur certains objets, le corps tombe d'un pas et il est repoussé au pas suivant : il tremble de 1,3 cm à chaque pas, et `linear_velocity` reste à 0,67 m/s, au-dessus du seuil `SETTLED_SPEED`. Un seuil sur le déplacement d'un pas à l'autre échoue aussi (1,3 cm par pas, c'est 0,8 m/s).
- **Bonne pratique** : juger l'immobilité sur la dérive depuis un point d'ancrage pendant toute la durée voulue (`Trash._still_anchor`), pas sur `linear_velocity` ni sur un seul pas.

## Un corps invisible sur la couche des déchets bloque la visée

- **Symptôme** : un déchet passé sous un amas (sous le tronc, sous l'eau) brille comme les derniers déchets mais ne se vise plus : impossible de finir la rivière (retour de Stelio, G45).
- **Cause** : le plancher invisible de chaque amas (`HeapFloor`, `River._add_heap`) est sur la couche `trash` pour que les déchets s'y posent. Le rayon et le `ShapeCast3D` du ramassage, qui ne regardent que cette couche, s'arrêtent dessus et ne voient pas ce qui est dessous.
- **Suite (G54)** : le plancher était une boîte de 10 cm ; un déchet poussé au bord d'un amas dérivait dessous et y restait plaqué par sa flottaison. Il descend désormais jusqu'au lit de la rivière. Un corps fin qui sert de sol au-dessus de l'eau laisse passer ce qui flotte dessous : le prolonger jusqu'au fond.
- **Bonne pratique** : un corps sur la couche `trash` qui n'est pas un déchet est exclu des visées (groupe `heap_floors`, `Pickup.heap_floors()` : `exclude` du rayon et `add_exception` du `ShapeCast3D` ; la visée des statues aussi). Dans un test de visée, attendre que le joueur ait touché le sol avant `aim_at` : sinon la visée part d'une position qui change encore.

## Jolt refuse les corps au-delà de 10 240

- **Symptôme** : avec 30 000 déchets, « Failed to create underlying Jolt Physics body … Maximum number of bodies is currently set to 10240 » dans le journal ; rien d'autre ne casse visiblement, mais les déchets en trop n'ont pas de corps physique : ils ne flottent plus, ne se heurtent plus, et ne se ramassent plus (le ramassage passe par la physique) (G57).
- **Cause** : `physics/jolt_physics_3d/limits/max_bodies` vaut 10 240 par défaut.
- **Bonne pratique** : régler la limite sur la quantité visée, avec de la marge (131 072 dans River Cleaner, garde-fou dans `project_settings_test.gd`) ; chercher « Jolt » dans le journal d'une mesure de performance avant d'en croire les chiffres.
