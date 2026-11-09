# Étude de Block Blast

Demandée par Stelio le 9 novembre 2026 : tout ce qu'on peut apprendre de Block Blast (Hungry Studio) sur le design, le gameplay, les pubs et la difficulté, et ce qu'on en retient pour Block Tiles. Complète la section 3 de `docs/etude-concurrence.md` (chiffres de marché, concurrents), sans la répéter.

**À lire avec prudence** : Hungry Studio ne publie ni règles détaillées ni post-mortem. Trois sortes de sources, à ne pas confondre :

- **sûr** : ce que montre le jeu, et les annonces officielles (Apple, communiqués) pour les faits datés ;
- **déclaré** : ce que dit l'éditeur (interviews, communiqués, études de cas de ses partenaires), non vérifiable ;
- **allégué** : la décompilation publiée par un développeur indépendant en octobre 2026 (section 5). Rien ne confirme ni ne dément ces règles ; elles sont citées parce qu'elles décrivent très concrètement ce qu'un tel jeu *peut* faire, pas parce qu'elles sont prouvées.

Les guides de joueurs et blogs « astuces » trouvés en ligne se contredisent (barème, fenêtre de combo) : ils ne sont pas repris ici.

## 1. En bref

1. **Une seule mécanique, polie à l'extrême.** Grille 8 × 8, 3 pièces, lignes et colonnes. L'éditeur dit en faire sa philosophie : pas de nouvelles règles, mais des milliers de réglages fins.
2. **Le jeu est une machine à tests A/B** : plus de 10 000 expériences en 2025, jusqu'à 300 en parallèle (déclaré). Les deux mesures qui tranchent tout : **la rétention et le temps de jeu**, pas le revenu par pub.
3. **Pub seulement** : bannière, interstitiel après chaque partie ou niveau, pub récompensée pour continuer. Aucun achat, même pas « sans pubs » (les joueurs le réclament).
4. **La difficulté s'adapte au joueur**, dans les deux sens : plus dure quand il va bien, plus douce après des échecs (déclaré par l'éditeur ; règles précises alléguées par la décompilation).
5. **Le moment fort de la pub, c'est le record.** Selon la décompilation, le jeu aide le joueur à dépasser son record, puis peut lui servir une partie perdue d'avance quand une pub chère est prête. Si c'est vrai, c'est exactement ce qu'on ne doit **pas** faire (section 8.3).
6. **Ce que les joueurs lui reprochent** : pubs trop longues, pub imposée même quand on refuse de continuer, pubs en plein niveau sur Android, aucune option payante pour les retirer, aucun aspect social.
7. **2026 a été agitée** : retiré de Google Play un jour sans explication (28 mai), version sans pub sur Apple Arcade (3 septembre), soupçons de « triche » après la décompilation (fin octobre). La confiance des joueurs est devenue un sujet : c'est une ouverture pour un jeu qui joue franc-jeu.

## 2. Fiche d'identité (complément)

Les chiffres d'audience et de revenus sont dans `docs/etude-concurrence.md`. Faits nouveaux :

| Date | Fait | Fiabilité |
|---|---|---|
| 2021 | Création de Hungry Studio | déclaré |
| 2025 | ≈ 356 à 368 M de téléchargements, n°1 mondial ; prix « meilleur jeu de réflexion » Sensor Tower APAC 2025 | estimations de trackers |
| janvier 2026 | Communiqué : 70 M de joueurs par jour, 300 M par mois, plus de 10 000 tests A/B en 2025 | déclaré |
| 28 → 29 mai 2026 | Disparaît de Google Play une journée, sans explication, puis revient | sûr (PocketGamer.biz) |
| 3 septembre 2026 | **Block Blast!+** sur Apple Arcade : même jeu, **sans pub ni achat** | sûr (Apple Newsroom) |
| fin octobre 2026 | Un développeur (Ayo Omolewa, « Ayoships ») publie une décompilation qui accuse le jeu de régler la difficulté selon la valeur des pubs ; reprise par The Star, Inc., MobileGamer.biz, Hacker News | allégué |

- **Revenu** : estimé entre 0,6 et 1 M $ par jour de pub (tiers, écarts énormes). Les achats intégrés sont négligeables.
- **Régie** : AppLovin MAX en médiation (allégué par la décompilation, cohérent avec les études de cas de DT Exchange et d'AdMob qui citent Hungry Studio comme client). AdMob annonce +8 % de rétention grâce à son partenariat (étude de cas commerciale).

## 3. Gameplay et design

### Les règles

- Grille **8 × 8**. Trois pièces proposées sous la grille ; on les pose dans l'ordre qu'on veut, **sans les tourner**. Les trois posées, trois nouvelles arrivent.
- Une **ligne ou une colonne pleine** s'efface. Plusieurs à la fois et des effacements à la suite (combo) rapportent beaucoup plus (le barème exact n'est publié nulle part).
- **Fin** : aucune des pièces restantes ne rentre. Pas de minuteur, pas de vies.
- Différences avec nos prototypes : nous **tournons** les pièces (retour de Stelio) et **remplaçons** chaque pièce dès qu'elle est posée (G8). Chez Block Blast, ne pas tourner et attendre d'avoir posé les trois sont précisément ce qui crée la tension : une pièce gênante reste là et oblige à prévoir de la place.

### Les deux modes

- **Classique** : partie infinie, un seul but, battre son **record**. Le record est affiché en permanence et sa barre est le vrai moteur de la partie.
- **Aventure** : 96 niveaux par saison. Chaque niveau a un objectif (atteindre un score, ou récupérer des **gemmes** prises dans des cases en effaçant leur ligne). Chaque niveau gagné colore une case d'une **mosaïque** ; toutes les cases révèlent une image (thème renouvelé). Cet écran de mosaïque est sorti d'un test A/B ; moins de 1 % des joueurs finissent les 96 niveaux (interview de l'éditeur). Interstitiel entre deux niveaux.

### Ce qui fait « bon » à jouer

- **Lisibilité totale** : couleurs franches, fond sombre, aucune décoration autour de la grille. Rien à lire pour comprendre.
- **Retours massifs à chaque effacement** : animation des cases qui éclatent, mots d'encouragement (« Good! », « Great! », « Perfect! » pour une grille vidée), sons courts, vibration. Les combos montent en intensité.
- **Le presque-record** : on voit le record approcher, chaque partie peut être « la bonne ». Le *near-miss* (« presque ! ») est le ressort principal de la relance.
- **Sessions de 2 à 5 minutes**, jouables d'une main, sans connexion pour le mode Classique.
- **Pas de méta-jeu** (ni monnaie, ni boutique, ni personnage) : tout le temps de développement va au cœur du jeu et à son réglage.

### Ce qui lui manque (nos ouvertures)

- **Aucun aspect social** : pas de classement, pas de défi entre amis, pas de défi du jour commun.
- **Lassitude du mode infini** : le Classique n'a qu'un but ; l'Aventure en donne un, mais 99 % ne la finissent pas.
- **Pas d'option sans pub** sur Android (elle n'existe que dans l'abonnement Apple Arcade).

## 4. Difficulté

### Ce que dit l'éditeur

- La difficulté de chaque niveau d'Aventure est réglée par tests A/B, comme les visuels et les sons.
- Un **robot joueur** (« Block AI ») imite les joueurs pour évaluer un réglage avant de le montrer à de vrais joueurs.

### Ce qu'allègue la décompilation (octobre 2026)

Le tirage des pièces passerait par des **règles nommées**, chacune pouvant demander au générateur des pièces « faciles », « dures » ou un **tirage mortel** (trois pièces dont aucune ne rentre ou presque) :

| Règle (nom dans le code) | Condition | Effet |
|---|---|---|
| `FailStreakStrategyTrait` | 2 parties d'affilée sous le record | pièces plus **faciles** |
| — | partie très en dessous du record | pièces plus faciles |
| `FastHandPunishTrait` | les 6 derniers lots joués en moins de 4,2 s en moyenne **et** score au-delà de 93 % du record | pièces **dures** |
| « High Value Ad Harvest » | 3 dernières pubs récompensées regardées jusqu'au bout, pub chargée ≥ 3,5 × l'eCPM de la précédente, score ≥ record + 1 000 (500 ou 750 dans d'autres groupes de test) | **tirage mortel** : le joueur perd, l'offre « Continuer » arrive au moment où elle vaut le plus |
| offre de reprise | après certaines reprises | bonus de score jusqu'à 10 % du record |

- L'auteur dit avoir lancé le fichier non modifié avec des valeurs de test et vu la règle se déclencher. Comme elle exige une pub chargée, elle ne joue pas hors ligne.
- Ce n'est **ni confirmé ni démenti** par Hungry Studio ; on ne sait pas quelle part des joueurs est concernée.

### Ce qu'on en retient (indépendamment de la véracité)

- Une bonne difficulté adaptative **descend aussi** : après des échecs, le jeu aide. C'est ce qui garde le joueur moyen.
- Le **record** est le repère naturel de la difficulté : facile loin en dessous, plus dur près du record (le moment de tension), jamais impossible.
- Le **rythme** du joueur (temps par coup) est un bon signal de maîtrise, gratuit à mesurer.
- Un débat de conception connu dans le genre : le hasard pur crée des séries de pièces impossibles (« le jeu m'a tué »), un générateur trop gentil rend la partie infinie. Les réponses courantes : sac de pièces (chaque forme sort une fois par sac), ou **garantie qu'au moins une des pièces rentre**.

## 5. Les pubs

### Formats et placements (observés et rapportés)

| Format | Où | Remarques |
|---|---|---|
| Bannière | en bas, en permanence pendant la partie | source de revenu de fond |
| Interstitiel | après chaque défaite (Classique), entre deux niveaux (Aventure) | souvent 15 à 30 s, parfois plus et non passables ; pendant un niveau sur Android selon des joueurs |
| Récompensée | « Continuer » après une défaite (reprise de la partie) | le seul choix du joueur ; aussi, selon des avis, une pub **même quand on refuse** de continuer (le compte à rebours finit sur une pub) |

- **Pas** de multiplicateur de gain, de coffre, de boutique, de bonus contre pub : il n'y a rien à multiplier. Toute la valeur de la récompensée tient à **une** offre, au moment de la défaite.
- Le placement et la fréquence ont fait l'objet de « dizaines de milliers » de tests (Udonis), toujours jugés à la rétention et au temps de jeu (l'éditeur dit limiter les pubs pour protéger la rétention).
- Les plaintes les plus fréquentes dans les avis (≈ 8 900 avis analysés par un agrégateur) : fréquence, longueur, pub imposée après un refus, et l'absence d'achat pour les retirer.

### Lecture

Block Blast gagne énormément avec un système de pub **pauvre** : peu de formats, une seule récompensée. Sa force est l'audience (des dizaines de millions de joueurs par jour), pas l'ingénierie de la pub. Un petit jeu n'a pas cette audience : il doit au contraire **tirer plus de chaque joueur** avec des récompensées choisies et bien placées (notre stratégie, `docs/strategies-pub.md`), et soigner la rétention, que Block Blast obtient par sa simplicité.

## 6. Acquisition de joueurs

- Pubs d'acquisition : ≈ 78 % vidéo, 16 % image, 7 % *playable* (Insightrackr). Beaucoup de vidéos de joueurs (UGC) reprises de TikTok, perçues comme authentiques.
- Une partie des pubs montre autre chose que le jeu (accroche spectaculaire, faux Tetris). À ne pas copier : Google Play et les régies sanctionnent les pubs trompeuses, et un joueur qui retrouve dans le jeu ce que la pub promettait reste nettement plus longtemps.
- Forte croissance par pays émergents (Indonésie, Vietnam, Brésil, Inde, Mexique) : eCPM plus bas, mais volume énorme et acquisition bon marché.

## 7. Comment l'équipe travaille

- **« Égalité d'expérience »** : principe affiché par l'éditeur, qui guide produit, marketing et pub (même jeu pour tous, pas d'avantage payant).
- **Tests en continu** : ≈ 50 expériences par semaine par équipe, idées venues de toute l'entreprise, « le test bat l'expérience et l'autorité ». Chaque test est jugé sur la rétention et le temps de jeu, pour qu'aucune équipe n'optimise seule son chiffre.
- **Instrumentation d'abord** : un exemple cité (ThinkingData) d'une chute brutale de nouveaux joueurs qui venait d'un événement de mesure manquant, pas du jeu.

## 8. Recommandations pour Block Tiles

Classées par priorité. Les références G9 renvoient à la PR #5 (difficulté adaptative, bonus, suivi du joueur).

### 8.1 À faire (gameplay et ressenti)

1. **Mettre le record au centre de l'écran de jeu.** Record visible en permanence, et une barre « vers le record » qui se remplit pendant la partie ; animation et son quand on le dépasse. C'est le ressort qui fait relancer une partie, et le meilleur moment pour l'offre « Continuer ». Coût : faible (le record existe déjà dans `PlayerStats`).
2. **Une difficulté qui descend aussi** (à ajouter à G9). Aujourd'hui, la difficulté monte avec le score, les combos et la moyenne des parties. Ajouter : après **2 parties d'affilée sous la moyenne**, ou tant que le score est loin du record, le générateur tire la pièce qui a **le plus** de place (le contraire du mode dur) ; et réduire le niveau dans les 3 premières parties (déjà le cas) **et** juste après un record battu (laisser savourer).
3. **Garantie de jouabilité** : le générateur ne propose jamais 3 pièces dont aucune ne rentre dans aucun sens, **sauf** si la grille est vraiment pleine. Perdre doit toujours venir d'un choix du joueur. C'est aussi notre argument face aux soupçons qui visent Block Blast.
4. **Retours d'effacement au niveau du genre** : mots d'encouragement qui montent avec le combo, explosion des cases, son qui monte d'un demi-ton par coup de combo, vibration courte (réglable dans les options), « grille vide ! » avec gros bonus. C'est ce qui se voit dans une vidéo de 5 secondes. À capturer et à faire juger par Stelio (Claude ne peut pas juger les sensations).
5. **Essayer en test A/B maison la règle de Block Blast « on remplace les 3 pièces quand les 3 sont posées »** contre notre remplacement immédiat (G8). La version Block Blast crée plus de tension (on doit caser une pièce gênante) ; la nôtre est plus fluide mais plus facile. Ça peut répondre au « trop facile » sans toucher au générateur. Un réglage `refill_each_slot` existe déjà : il suffit de le proposer à Stelio sur un build de test.
6. **Mode à objectifs façon Aventure, avec notre accroche** : niveaux courts avec un but (effacer N trios, libérer les tuiles « gemmes » prises dans la grille, atteindre un score), et une **image de tuiles de mahjong** qui se révèle niveau après niveau. Ça donne un rendez-vous et une progression que le mode infini n'a pas, et ça se prête aux interstitiels entre niveaux (pause naturelle).
7. **Ce que Block Blast n'a pas** : un **défi du jour** (même graine pour tous, `RandomNumberGenerator` à graine : déjà notre règle) avec un score à comparer, puis un classement simple. Coût moyen (le classement demande un serveur ; le défi du jour, non).

### 8.2 À faire (pubs)

1. **Garder l'offre « Continuer » au moment où elle compte** : déjà en place (G3) ; la montrer **surtout** quand la partie était proche du record (≥ 50 % du record, `docs/strategies-pub.md` 4.2) et le dire : « Il te manquait 120 points pour ton record ».
2. **Bonus contre pub au moment de la difficulté, pas à la place du jeu** (G9 le fait : boutons qui brillent quand une seule pièce rentre). Ajouter les bonus déjà proposés (marteau, bombe, annuler, joker) un par un, chacun jugé sur le taux de pubs vues **et** la durée des parties.
3. **Ne jamais imposer de pub quand le joueur refuse « Continuer »** : c'est la plainte n°1 contre Block Blast. Si un interstitiel suit une défaite, il vient **après** l'écran de fin, jamais à la fin du compte à rebours de l'offre.
4. **Interstitiels plus rares que Block Blast** : nos plafonds de `docs/strategies-pub.md` (section 5 : rien pendant les 3 premières parties, un toutes les 2 à 3 parties, trêve de 10 minutes après une récompensée). Avec une petite audience, la rétention vaut plus que l'interstitiel de trop.
5. **Achat « Sans pubs » en version 1.1** : les joueurs de Block Blast le réclament et ne l'ont pas. C'est un argument de page Play Store (« pubs supprimables »).
6. **Mesurer comme eux** : chaque réglage de pub jugé sur la rétention J1/J7 et le temps de jeu, pas seulement sur le revenu du jour. Le suivi du joueur de G9 est la base ; il faudra l'envoyer à un outil d'analyse (Firebase ou Supabase) pour comparer deux groupes de joueurs. Prévoir les plafonds et les seuils de difficulté **réglables à distance**.

### 8.3 À ne pas faire

| Idée tirée de Block Blast | Pourquoi non |
|---|---|
| Tirage « mortel » déclenché quand une pub chère est prête ou près du record | Trompe le joueur sur ce qui le fait perdre ; contraire à l'esprit des règles Google Play et AdMob (pas de jeu rendu impossible pour forcer la pub, `docs/strategies-pub.md` section 3) ; risque de scandale public, comme en octobre 2026. Notre difficulté ne lit **jamais** l'état des pubs. |
| Punir le joueur rapide près de son record | Punit le bon joueur au moment où il prend le plus de plaisir. On peut monter la difficulté avec la maîtrise, pas viser le record pour le faire tomber. |
| Pub imposée après un refus de « Continuer » | Plainte n°1 ; casse la confiance dans les pubs choisies, celles qui rapportent le plus. |
| Interstitiel pendant un niveau | Interdit par AdMob (interstitiel inattendu). |
| Pubs d'acquisition qui montrent un autre jeu | Pratique trompeuse ; mauvaise rétention des joueurs ainsi recrutés. |
| Reprendre le nom, le logo, les couleurs ou l'interface de Block Blast | Identité protégée ; on reprend des mécaniques de genre (grille, 3 pièces, lignes), pas l'apparence. |

### 8.4 Tickets proposés

À ajouter à `docs/backlog.md` si Stelio est d'accord (ordre suggéré) :

1. **Record au centre** (8.1.1, 8.2.1) — petit.
2. **Difficulté dans les deux sens et garantie de jouabilité** (8.1.2, 8.1.3) — petit, suite de G9.
3. **Build de test « 3 pièces renouvelées ensemble »** pour comparer avec le remplacement immédiat (8.1.5) — très petit (réglage).
4. **Retours d'effacement** (8.1.4) — moyen, à juger par Stelio.
5. **Défi du jour** (8.1.7) — moyen.
6. **Mode à objectifs avec image révélée** (8.1.6) — gros, après le choix du prototype.

## Sources

Lues le 9 novembre 2026 par recherche web (plusieurs sites ne s'ouvraient pas depuis la session : les informations viennent alors des extraits des moteurs de recherche, et sont marquées « allégué » ou « estimation » quand elles ne sont pas officielles).

- Apple Newsroom, Block Blast!+ et Art of Fauna sur Apple Arcade (août 2026) : https://apple.com/newsroom/2026/08/apple-arcade-levels-up-with-block-blast-plus-and-art-of-fauna-cozy-puzzles-plus/
- PocketGamer.biz, Block Blast retiré de Google Play (mai 2026) : https://www.pocketgamer.biz/hungry-studios-block-blast-no-longer-available-on-google-play/ ; et son retour : https://www.pocketgamer.biz/hungry-studios-block-blast-returns-to-google-play/
- MobileGamer.biz, retrait de Google Play : https://mobilegamer.biz/block-blast-has-disappeared-from-googles-play-store/
- Ayoships, décompilation (octobre 2026, allégué) : https://ayoships.com/breakdowns/block-blast
- The Star, « Is Block Blast rigged? » (28 octobre 2026) : https://www.thestar.com.my/tech/tech-news/2026/10/28/is-block-blast-rigged-a-developer-decompiled-the-viral-game-to-find-out
- Inc., même sujet : https://www.inc.com/jelinda-montes/is-block-blast-rigged-a-developer-decompiled-the-viral-game-to-find-out/91419957
- MobileGamer.biz, la décompilation présentée comme allégation : https://mobilegamer.biz/this-creator-says-he-decompiled-block-blast-candy-crush-and-subway-surfers-to-reveal-their-monetisation-secrets/
- Hacker News, discussion : https://news.ycombinator.com/item?id=50217946
- Mezha, limites des conclusions : https://mezha.net/eng/news/mezha-d2153a8745538b800d77853d_how_block_blast/
- Felix Braberg (Substack), analyse de la logique de pub : https://felixbraberg.substack.com/p/block-blasts-1mday-ad-logic-just
- DEV Community, reprise de la décompilation : https://dev.to/om_shree_0709/reverse-engineering-block-blast-5eop
- Business Wire, communiqué « 70M DAU, 10 000 expériences » (janvier 2026, déclaré) : https://www.businesswire.com/news/home/20260108572322/en/Block-Blast-Scales-to-70M-DAU-as-Hungry-Studio-Runs-Over-10000-Experiments-in-a-Single-Year
- Baijing, interview de Jason Wang, Hungry Studio (2026, en chinois) : https://www.baijing.cn/article/id-50876
- Global Games Forum, IA, tests A/B et joueurs fidèles : https://www.globalgamesforum.com/news/how-block-blast-shattered-records-with-ai-a-b-testing-and-a-bold-bet-on-long-term-players
- AdMob, étude de cas Hungry Studio : https://admob.google.co.in/home/resources/hungry-studio-boosts-user-retention-revenue-with-admob/
- Digital Turbine, étude de cas DT Exchange : https://www.digitalturbine.com/case-studies/hungry-studio-hit-8-arpdau-in-one-month-with-dt-exchange/
- Udonis, statistiques (données AppMagic) : https://www.blog.udonis.co/statistics/block-blast
- Insightrackr, fiche Block Blast (pubs d'acquisition) : https://blog.insightrackr.com/en/docs/Block-Blast-Intelligence
- Applixir, « The Block Blast playbook » : https://www.applixir.com/blog/the-block-blast-playbook-what-127m-in-ad-revenue-actually-bought/
- Gamigion, analyse du revenu publicitaire : https://www.gamigion.com/?p=12954
- MAF, étude de Block Blast : https://maf.ad/en/blog/block-blast/
- Marlvel, synthèse des avis : https://marlvel.ai/apps/block-blast/reviews
- Adlock, pubs après refus de « Continuer » : https://adlock.com/blog/remove-block-blast-ads
- App Store, fiche Block Blast! : https://apps.apple.com/us/app/id1617391485
