# Étude de Block Blast

Demandée par Stelio le 9 novembre 2026 : tout ce qu'on peut apprendre de Block Blast (Hungry Studio) sur le design, le gameplay, les pubs et la difficulté, et ce qu'on en retient pour Block Tiles. Complète la section 3 de `docs/etude-concurrence.md` (chiffres de marché, concurrents), sans la répéter.

**Trois niveaux de fiabilité**, indiqués à chaque fois :

- **sûr** : ce que montre le jeu, et les annonces officielles (Apple, communiqués) pour les faits datés ;
- **déclaré** : ce que dit l'éditeur (interviews, communiqués, études de cas de ses partenaires), non vérifiable ;
- **décompilé** : la décompilation publiée le 15 octobre 2026 par Ayo Omolewa (« Ayoships », section 4). Elle cite le code avec ses numéros de ligne, publie des empreintes et des paquets de preuves vérifiables, et a observé certaines règles en direct. Hungry Studio n'a répondu ni à la presse ni à MobileGamer.biz. C'est la source la plus précise sur le fonctionnement du jeu, mais elle vient d'un seul auteur, qui en fait un contenu viral ; sa rédaction est critiquée sur Hacker News, pas ses constats.

Les guides de joueurs et blogs « astuces » se contredisent (barème, fenêtre de combo) : ils ne sont pas repris.

## 1. En bref

1. **Une seule mécanique, polie à l'extrême.** Grille 8 × 8, 3 pièces, lignes et colonnes. L'éditeur en fait sa philosophie : pas de règle nouvelle, mais l'interface, l'art, la difficulté, les effets et la vibration réglés par des milliers de tests.
2. **Le jeu est une machine à tests A/B.** Plus de 10 000 expériences en 2025, jusqu'à 300 en parallèle (déclaré) ; ≈ 3 % seulement s'avèrent positives. Juges : **la rétention et le temps de jeu**.
3. **Le jeu est un assemblage de ≈ 700 petites règles** (« traits ») téléchargées depuis le serveur après l'installation. Chaque joueur en reçoit une sélection (254 pour l'installation étudiée) : deux joueurs côte à côte ne jouent pas au même jeu (décompilé).
4. **La difficulté s'adapte dans les deux sens** : pièces faciles après des échecs ou pour les joueurs peu engagés, pièces dures pour qui joue vite près de son record (décompilé).
5. **Le jeu sait fabriquer une défaite.** Un générateur cherche 3 pièces dont 2 rentrent mais qu'aucun ordre ne permet de poser toutes. Plusieurs règles le déclenchent, presque toutes **juste après le record battu** ; l'une attend qu'une pub récompensée **3,5 fois plus chère** que la précédente soit chargée (décompilé). C'est exactement ce que nous ne ferons pas (section 8.3).
6. **Pubs peu nombreuses mais pilotées par la valeur du joueur** (nous : aucune pub forcée, décision du 2026-11-09) : bannière, interstitiel court entre deux parties, une récompensée « Continuer ». Un modèle sur le téléphone estime ce que vaut chaque joueur en pub ; le jeu choisit les formats en conséquence (décompilé).
7. **Ce que les joueurs reprochent** : pub même quand on refuse de continuer, pubs longues, pas d'achat « sans pubs », pas d'aspect social, et depuis octobre 2026 le soupçon d'être « truqué ». C'est notre ouverture : un jeu honnête, qui le dit.

## 2. Fiche d'identité (complément)

Les chiffres d'audience et de téléchargements sont dans `docs/etude-concurrence.md`. Ce qui s'ajoute :

| Date | Fait | Fiabilité |
|---|---|---|
| 2021 | Création de Hungry Studio (siège à Hong Kong selon la presse, Singapour selon d'autres sources) | déclaré |
| fin 2024 | 40 M de joueurs par jour, plus de 3 000 tests A/B depuis la sortie, dont ≈ 100 positifs (interview de Jason Wang, Baijing) | déclaré |
| 2025 | n°1 mondial des téléchargements ; meilleur jeu de réflexion aux Sensor Tower APAC Awards | estimations |
| janvier 2026 | 70 M de joueurs par jour, 300 M par mois, plus de 10 000 tests A/B en 2025 | déclaré |
| janvier à mai 2026 | **≈ 127 M $ de revenus publicitaires**, n°1 mondial (Vita Mahjong 2ᵉ à 89,8 M $, Candy Crush 81,1 M $) ; ≈ 60 % hors des États-Unis | estimation Sensor Tower |
| 28 → 29 mai 2026 | Retiré de Google Play une journée ; une rumeur parle d'une plainte pour droit d'auteur (DMCA), non confirmée | sûr (le retrait) |
| 3 septembre 2026 | **Block Blast!+** sur Apple Arcade : même jeu, sans pub ni achat | sûr (Apple Newsroom) |
| 15 octobre 2026 | Décompilation publiée par Ayoships ; vidéo à plus de 15 M de vues, reprise par Inc., The Star, MobileGamer.biz, Hacker News | décompilé |

- **Revenu** : pub presque exclusivement (≈ 66 000 $ d'achats en tout, selon AppMagic). ≈ 0,6 à 1 M $ par jour, ≈ 1,8 M $ le jour du Black Friday 2025 (Gamigion).
- **Contexte du marché** : la pub dans les jeux mobiles pèse plus de 12 Md $ (2025) ; le puzzle en fait 53 %, le sous-genre « blocs » à lui seul ≈ 10 %. Surtout : **les jeux hors du top 1 000 captent 29 % des revenus publicitaires, contre 9 % des achats** (Sensor Tower, juin 2026). La pub profite aux petits jeux bien plus que l'achat intégré : bon signe pour nous.
- **Session moyenne** : ≈ 12 minutes, plusieurs fois par jour ; rétention J1 ≈ 26 % (Udonis, AppMagic).
- **Régies** : AppLovin MAX en médiation, AdMob dans les enchères (décompilé ; AdMob et InMobi publient des études de cas sur le studio : +8 % de rétention, +5 % de revenu par joueur et par jour).

## 3. Gameplay et design

### Les règles

- Grille **8 × 8**. Trois pièces proposées sous la grille ; on les pose dans l'ordre qu'on veut, **sans les tourner**. Les trois posées, trois nouvelles arrivent.
- Une **ligne ou une colonne pleine** s'efface. Plusieurs à la fois et des effacements à la suite (combo) rapportent beaucoup plus ; une grille vidée donne un gros bonus.
- **Fin** : aucune des pièces restantes ne rentre. Pas de minuteur, pas de vies.
- Différences avec nos prototypes : nous **tournons** les pièces (retour de Stelio) et **remplaçons** chaque pièce dès qu'elle est posée (G8). Chez Block Blast, ne pas tourner et attendre d'avoir posé les trois créent la tension : une pièce gênante reste là et oblige à prévoir de la place.

### Les modes

- **Classique** (« sans fin ») : un seul but, battre son **record**, affiché en permanence. **90 % des joueurs commencent par là** (interview).
- **Aventure** : 96 niveaux, renouvelés chaque semaine environ. La grille commence avec des **blocs obstacles** ; il faut effacer un nombre donné de blocs (ou récupérer des gemmes). Chaque niveau gagné colore une case d'une **mosaïque en points** ; l'image finie est faite pour être **partagée en capture d'écran** (elle a remplacé une illustration avec citation, après un test A/B). Moins de 1 % des joueurs finissent les 96 niveaux.
- **Mode caché « chute »** (*falling*) : un mode plus difficile, caché derrière « More Games » dans le Classique, pour les joueurs qui veulent plus de défi (interview).

### Ce qui fait « bon » à jouer

- **Lisibilité totale** : couleurs franches, fond sombre, rien autour de la grille. Rien à lire pour comprendre.
- **Retours massifs à chaque effacement**, réglés un par un : les noms des règles trouvées dans le code en donnent la liste (décompilé) : arc-en-ciel sur les combos (`ComboRainbowTrait`), score qui s'envole (`ComboflyScoreTrait`), effets qui grossissent avec le nombre d'effacements (`TheMoreEliminateTheMoreGoodEffectTrait`), onde en cœur quand la grille est vidée (`ClearBoardHeartRippleAniTrait`), feu d'artifice en fin de partie (`SettleFireworkTrait`), vibration (`IsOpenVibrateTrait`), tremblement des boutons, animations ralenties pour les joueurs lents (`SlowPlayerAnimTrait`), effets allégés sur les petits téléphones (`CTLowDeviceEffectTrait`, 30 images/s).
- **Aide discrète** : indice d'effacement possible (`AddClearTipsExTrait`), aide quand le joueur réfléchit longtemps (`LongThinkClearAssistTrait`), aide au placement (`IsOpenRightPutTrait`, `PlaceHabitAdaptPathTrait`).
- **Début soigné** : pièces plus petites pour les débutants (`LimitNoviceBlockSizeTrait`), premier score réglé (`FirstGameScoreTrait`, `NewbieScoreRegulationTrait`), incitation à rejouer pour les nouveaux (`NewPlayerContinuePlayIncentiveTrait`).
- **Rendez-vous** : séries de victoires quotidiennes (`DailyWinStreakStateTrait`), apparences de pièces (*skins*) qu'on change, mode débloqué en battant son record (`GameLobbyUnlockByBreakHighScoreTrait`).
- **Le presque-record** : on voit le record approcher, chaque partie peut être « la bonne ».
- **Pas de méta-jeu** (ni monnaie, ni boutique) : l'effort va au cœur du jeu et à son réglage.

### Ce qui lui manque (nos ouvertures)

- **Aucun aspect social** : pas de classement, pas de défi entre amis, pas de défi du jour commun (le partage de la mosaïque est le seul geste social).
- **Lassitude du mode infini** : 99 % ne finissent pas l'Aventure.
- **Pas d'option sans pub** sur Android (seulement dans l'abonnement Apple Arcade).
- **La confiance** : depuis octobre 2026, une partie du public pense que le jeu triche.

## 4. Difficulté : ce que montre la décompilation

### L'architecture

- Le jeu installé est presque vide de logique. Au lancement, le serveur envoie une configuration qui choisit, pour ce joueur, une variante (« bras ») de chaque règle ; les règles arrivent en JavaScript chiffré, **hors de l'examen des magasins**. Tout est donc testable et modifiable à distance, joueur par joueur.
- Avant chaque lot de 3 pièces, une liste de règles décide **quel générateur** utiliser : remplissage facile, tirage dur, tirage « mortel », etc.

### Le générateur « mortel » (`ZHI_SI_TI`, « question qui tue »)

Il cherche **2 pièces qui rentrent et 1 qui ne rentre pas encore**, et ne garde le lot que si **aucun ordre et aucun placement** ne permet de poser les trois, en comptant les lignes effacées en route. Le lot n'a pas l'air impossible : deux pièces se posent. Exemple publié : deux dominos et un carré 3 × 3, impossibles sur la grille de test, alors que ces trois pièces se posent de 67 680 façons sur une grille vide.

### Les règles qui le déclenchent (ou adoucissent le jeu)

| Règle | Condition | Effet | Observée |
|---|---|---|---|
| `RewardHighValueAdHarvestTrait` | 3 dernières pubs récompensées vues jusqu'au bout, pub chargée ≥ 3,5 × la précédente, score ≥ record + 1 000 (500 ou 750 selon le bras) | lot mortel ; peut revenir après une reprise | code exécuté sur 28 cas ; en direct sur iPhone, en attente (pub à 1,94 ×). Version iOS « V2 » : jusqu'à 1 seule pub suffit, même fermée |
| `PersonalMarginBreakTrait` | score à plus de 10 % au-dessus du record | à chaque lot, **20 % de chances** de lot mortel | **en direct** (iPhone) |
| `MultiClearBoostThenKillTrait` | joueurs classés par le serveur « peu sensibles à être forcés de mourir » | attend un gros effacement, puis lot mortel quelques tours après, vers la durée habituelle de partie du joueur | code |
| `MABXiBaiTrait` | expérience à 6 bras | délai avant le premier lot mortel possible : jamais, 4, 6, 10, ≈ 17 ou 30 minutes ; mesure si le joueur relance une partie dans les 15 minutes et accepte les reprises | code |
| modèle `predict_travel_difficulty_dead` | mode Aventure : forêt XGBoost de 500 arbres, 52 entrées (niveau, essais, parties de la semaine, ancienneté) | choisit **où** perdre dans le niveau (début, milieu, fin) ; offre une reprise en plus aux joueurs qui en prennent souvent, puis lot mortel | code |
| `FastHandPunishTrait` | 6 derniers lots joués en moins de 4,2 s en moyenne, et plus de 93 % du record | pièces dures | code |
| `FailStreakStrategyTrait` | 2 parties d'affilée sous le record | pièces **faciles** | **en direct** |
| `MaturityDevelopmentV2Trait` | « maturité » du joueur = habitude + talent + historique de pubs (sous 65) | remplace des lots durs par des remplissages faciles | **en direct** |
| `ConsecutiveLossRecoveryTrait`, `IsWarmhandsTrait`, `LoginTimeFirstDifficultyRatioTrait` | (noms seulement) | rattrapage après des défaites, échauffement, difficulté au premier lancement | noms |
| `AdPlusMinusStrategyTrait` | après une offre de reprise en plus | bonus aléatoire jusqu'à 10 % du record ajouté au score | code |
| `NextDayLowActivityFirstReviveFreeTrait` | un modèle (LightGBM, 1 000 arbres) prédit que le joueur jouera moins demain (≥ 0,69) | **reprise gratuite, sans pub**, une fois par jour, bouton rose | code |

### Ce qu'on en retient

- **Le record est le pivot** : facile loin en dessous, plus dur près du record (la tension), et c'est juste après le record battu que le joueur veut le plus continuer.
- **Une bonne difficulté descend aussi** : après des échecs, pour un nouveau joueur, pour un joueur peu engagé. C'est ce qui garde le joueur moyen.
- **Le rythme** (temps par lot) et **l'hésitation** (longue réflexion) sont de bons signaux, gratuits à mesurer.
- **La générosité ciblée fidélise** : une reprise offerte au joueur qui décroche coûte une pub et peut sauver un joueur.
- **Tout est réglable à distance et mesuré** : chaque seuil est un bras d'expérience, jugé sur le retour du joueur (relance dans les 15 minutes, retour le lendemain).

## 5. Les pubs

### Formats et placements

| Format | Où | Remarques |
|---|---|---|
| Bannière | en bas, en permanence pendant la partie | pas de bannière les premiers jours d'un nouveau joueur (`NoBannerAdNewUserByDaysTrait`, décompilé) ; bannière affichée selon la progression (`HighProgressShowBannerTrait`) |
| Interstitiel | entre deux parties (Classique), entre deux niveaux (Aventure) | court ; pas d'interstitiel selon le temps de jeu (`PlaytimeNoInterstitial1Trait`), répit après un interstitiel cher (`HighValueInterstitialReliefTrait`), **aucun** pour les joueurs qui ne rapportent presque rien (`IsOpenEcpmTooLowNoInterTrait`), un de plus pour ceux qui rapportent beaucoup (`FullScreenAdAddByEcpmTrait`) |
| Récompensée | « Continuer » après une défaite | **une par partie** en principe (Applixir), des reprises en plus pour les joueurs dont la récompensée vaut ≥ 2 × l'interstitiel ; pas de bouton s'il n'y a pas de vidéo prête (`IsOpenNoVideoNoRevivieTrait`) |

- **Hors ligne, pas de pub** : c'est la « soupape » qui remplace l'achat « sans pubs » (Applixir).
- **La valeur du joueur** : un modèle XGBoost (59 arbres, 27 entrées : prix des pubs reçues, pays, téléphone, mémoire, source d'installation, score de la première partie) estime ce que vaut chaque joueur en pub (eCPM) ; d'autres modèles côté serveur (désabonnement, valeur à vie, clic sur la reprise). Exemple publié : le même joueur vaut 25,5 aux États-Unis, 8,1 au Brésil, 5,6 en Inde (iPhone).
- **Ce que dit l'éditeur** (fin 2024) : ils ont **retiré des formats de pub qui gênaient les joueurs**, au prix d'une baisse de revenu à court terme ; leur retour sur investissement est plus long que celui des concurrents à cause de cette retenue ; leur croissance dépend « lourdement » de l'achat de joueurs.
- **Ce que reprochent les joueurs** (≈ 8 900 avis analysés) : pub même quand on refuse « Continuer », pubs longues ou non passables, pas d'achat pour les retirer.

### Lecture

L'analyse d'Applixir résume le modèle : **peu de pubs, mais placées au seul moment où le joueur en veut une** (juste après avoir perdu une partie à laquelle il tenait), et **rationnées** pour que la reprise garde sa valeur. La rétention est le revenu : un test qui fait revenir les joueurs multiplie toutes les pubs futures ; une pub de plus est un gain ponctuel contre un risque permanent. Block Blast a ajouté par-dessus une couche d'optimisation par joueur (formats selon sa valeur, défaites provoquées) que nous ne reprendrons pas.

## 6. Acquisition de joueurs

- Croissance **achetée** : 30 à 40 M d'installations par mois au pic, payées par les revenus de pub ; pubs à la télévision connectée, préinstallations chez des fabricants de téléphones (Udonis).
- Pubs d'acquisition : ≈ 78 % vidéo, 16 % image, 7 % jouables (Insightrackr). Montrent surtout le vrai jeu : blocs qui s'emboîtent, effacements en chaîne, « presque perdu », défi (« seul 1 % arrive à vider la grille »), avec une accroche visuelle sans rapport (une tornade) dans les 2 premières secondes. Vidéos de créateurs TikTok réutilisées en pub.
- Les joueurs qui trouvent dans le jeu ce que la pub promettait restent nettement plus (Sensor Tower) : une pub honnête est un levier de rétention.

## 7. Comment l'équipe travaille

- **« Égalité d'expérience »** (体验平权) : le jeu doit être facile à prendre pour tous, quels que soient le pays, la langue, le réseau ou le téléphone. D'où les effets allégés sur les petits téléphones et le mode hors ligne.
- **« Moins, c'est plus »** : un seul jeu, un seul mécanisme, choisi parce que les blocs évoquent l'enfance et se comprennent tout de suite. Pas d'innovation « pour innover » : améliorer les détails de l'expérience.
- **Tests en continu**, ≈ 50 par semaine, idées venues de tous (« innovation sans chef »), « l'exploration bat l'expérience et l'autorité ». 3 % de tests positifs : c'est normal une fois les gains faciles pris.
- **Un robot joueur** (« Block AI ») imite les joueurs pour évaluer un réglage avant de le montrer.
- **Mesure d'abord** : une chute de nouveaux joueurs venait en fait d'un événement de mesure manquant (ThinkingData).
- **Achats intégrés écartés** : ils divisent les joueurs en payants et gratuits, difficiles à servir tous les deux.

## 8. Recommandations pour Block Tiles

Classées par priorité. G9 renvoie à la PR #5 (difficulté adaptative, bonus, suivi du joueur).

### 8.1 À faire (gameplay et ressenti)

1. **Mettre le record au centre.** Record visible en permanence, barre « vers le record » qui se remplit, animation et son quand on le dépasse. C'est le ressort qui fait relancer une partie et le meilleur moment pour « Continuer ». Coût faible (le record existe dans `PlayerStats`).
2. **Une difficulté qui descend aussi** (suite de G9, qui la fait seulement monter). Après **2 parties d'affilée sous la moyenne**, ou tant que le score est loin du record, tirer la pièce qui a **le plus** de place ; niveau bas pendant les premières parties (déjà le cas) ; petites pièces pour les tout débutants.
3. **Garantie de jouabilité** : le générateur ne propose jamais un lot impossible tant que la grille n'est pas vraiment pleine. Une défaite doit toujours venir d'un choix du joueur. On peut le **dire** (écran d'aide, page du Play Store : « jamais de pièces impossibles ») : c'est un argument face aux soupçons qui visent Block Blast.
4. **Retours d'effacement au niveau du genre** : mots qui montent avec le combo, explosion des cases, son qui monte par coup de combo, effet qui grossit avec le nombre d'effacements, « grille vide ! » avec gros bonus, vibration courte (réglable), feu d'artifice au record. C'est ce qui se voit dans une vidéo de 5 secondes. À faire juger par Stelio (Claude ne peut pas juger les sensations).
5. **Essayer « les 3 pièces renouvelées ensemble »** contre notre remplacement immédiat (G8), sur un build de test. La version Block Blast crée plus de tension ; ça peut répondre au « trop facile » sans toucher au générateur. Le réglage `refill_each_slot` existe déjà.
6. **Aide à l'hésitation** : si le joueur ne joue pas pendant une dizaine de secondes, montrer en ombre un placement qui efface une ligne ou un trio. Gratuit au début, puis (au choix) un bonus « Indice » contre pub.
7. **Mode à objectifs façon Aventure, avec notre accroche** : niveaux courts (effacer N trios, libérer des tuiles « gemmes », grille de départ avec obstacles), et une **image de tuiles de mahjong** révélée niveau après niveau, avec un bouton **Partager**. Interstitiels entre deux niveaux (pause naturelle).
8. **Ce que Block Blast n'a pas** : un **défi du jour** (même graine pour tous, `RandomNumberGenerator` à graine : déjà notre règle) et un score à comparer ; plus tard un classement simple. Et un **mode expert** à débloquer en battant son record (pièces non tournables, par exemple).

### 8.2 À faire (pubs)

1. **« Continuer » au moment où il compte** : déjà en place (G3), une fois par partie. Le mettre en avant quand la partie était proche du record ou l'a battu (« Il te manquait 120 points »). Pas de bouton sans pub prête (déjà notre règle).
2. **Bonus contre pub au moment de la difficulté** (G9 le fait : boutons qui brillent quand une seule pièce rentre). Ajouter les bonus proposés (marteau, bombe, annuler, joker) un par un, chacun jugé sur le taux de pubs vues **et** la durée des parties.
3. **Aucune pub forcée** (décision de Stelio, 2026-11-09) : ni interstitiel ni bannière pour le moment, seulement des pubs récompensées choisies. Ça règle d'office la plainte n°1 contre Block Blast (la pub imposée quand on refuse « Continuer ») et ça devient un argument : « aucune pub forcée » sur la page du Play Store. Tout le revenu repose alors sur les récompensées : d'où l'importance des points 1, 2 et 5.
4. **Si un jour on ajoute des pubs forcées**, protéger d'abord les nouveaux joueurs (rien pendant les premières parties, voire le premier jour, comme Block Blast pour la bannière) et suivre les plafonds de `docs/strategies-pub.md` (section 5).
5. **Une reprise offerte à qui décroche** : par exemple, pour un joueur qui revient après plusieurs jours d'absence, la première reprise du jour est gratuite. Simple à faire sans modèle (date de dernière session dans `PlayerStats`).
6. **Pas de pub hors ligne** : il n'y en aura de toute façon pas (rien à charger) ; le jeu doit rester entièrement jouable hors ligne, boutons de pub masqués.
7. **Achat « Sans pubs »** : sans pub forcée, il n'a plus d'objet pour l'instant ; à revoir si des interstitiels arrivent.
8. **Mesurer comme eux** : chaque réglage jugé sur la rétention J1/J7, le temps de jeu et la relance d'une partie, pas seulement sur le revenu du jour. Le suivi de G9 est la base ; il faudra l'envoyer à un outil d'analyse et rendre les seuils **réglables à distance** (Firebase Remote Config ou Supabase) pour tester deux groupes de joueurs.

### 8.3 À ne pas faire

| Idée tirée de Block Blast | Pourquoi non |
|---|---|
| Lot « mortel » volontaire (après le record, quand une pub chère est prête, au moment choisi par un modèle) | Trompe le joueur sur ce qui le fait perdre ; contraire à l'esprit des règles Google Play et AdMob (pas de jeu rendu impossible pour forcer la pub, `docs/strategies-pub.md` section 3) ; scandale public en octobre 2026. **Notre générateur ne lit jamais l'état des pubs, et ne produit jamais un lot impossible.** |
| Difficulté ou nombre de pubs réglés selon la valeur publicitaire estimée du joueur (pays, téléphone…) | Même grief ; demande un profilage soumis au consentement (RGPD) ; hors de portée d'un petit jeu. La médiation choisit déjà la pub la mieux payée. |
| Punir le joueur rapide près de son record | Punit le bon joueur au moment où il s'amuse le plus. On peut monter la difficulté avec la maîtrise, pas viser le record pour le faire tomber. |
| Règles de jeu téléchargées en code (JavaScript chiffré) après l'installation | Google Play interdit à une application de télécharger du code exécutable hors de Play ; c'est aussi ce qui a permis la fuite. Nous ne téléchargerons que des **réglages** (JSON lu sans confiance), jamais du code. |
| Pub imposée après un refus de « Continuer » | Plainte n°1 ; casse la confiance dans les pubs choisies, celles qui rapportent le plus. |
| Pubs d'acquisition qui montrent un autre jeu | Pratique trompeuse ; mauvaise rétention. Une accroche spectaculaire est permise si le jeu montré est le vrai. |
| Reprendre le nom, le logo, les couleurs ou l'interface de Block Blast | Identité protégée ; on reprend des mécaniques de genre (grille, 3 pièces, lignes), pas l'apparence. |

### 8.4 Tickets proposés

À ajouter à `docs/backlog.md` si Stelio est d'accord (ordre suggéré) :

1. **Record au centre** (8.1.1, 8.2.1) — petit.
2. **Difficulté dans les deux sens et garantie de jouabilité** (8.1.2, 8.1.3) — petit, suite de G9.
3. **Build de test « 3 pièces renouvelées ensemble »** (8.1.5) — très petit (réglage).
4. **Retours d'effacement** (8.1.4) — moyen, à juger par Stelio.
5. **Reprise offerte au retour** (8.2.5) — petit.
6. **Aide à l'hésitation** (8.1.6) — petit.
7. **Défi du jour** (8.1.8) — moyen.
8. **Mode à objectifs avec image révélée et partage** (8.1.7) — gros. **Choix de Stelio (2026-11-09)** : niveaux ajoutés au prototype 1 (même règle que le mode infini), voir `docs/backlog.md`, G17.

## Sources

Lues le 9 novembre 2026. Dates de publication entre parenthèses.

**Décompilation et réactions**

- Ayo Omolewa (Ayoships), « How Block Blast harvests its players for ad money » (15 octobre 2026), source primaire, code cité : https://ayoships.com/breakdowns/block-blast
- The Star / Inc., « Is Block Blast rigged? » (28 octobre 2026) : https://www.thestar.com.my/tech/tech-news/2026/10/28/is-block-blast-rigged-a-developer-decompiled-the-viral-game-to-find-out
- MobileGamer.biz, la décompilation présentée comme allégation (octobre 2026) : https://mobilegamer.biz/this-creator-says-he-decompiled-block-blast-candy-crush-and-subway-surfers-to-reveal-their-monetisation-secrets/
- Felix Braberg, Mobile Ad Revenue (octobre 2026) : https://felixbraberg.substack.com/p/block-blasts-1mday-ad-logic-just
- Hacker News, discussion : https://news.ycombinator.com/item?id=50217946
- Mezha, limites des conclusions : https://mezha.net/eng/news/mezha-d2153a8745538b800d77853d_how_block_blast/

**Éditeur et partenaires (déclaré)**

- Baijing, interview de Jason Wang, vice-président marque et marketing de Hungry Studio (fin 2024, en chinois) : https://www.baijing.cn/article/id-50876
- Business Wire, « 70M DAU, 10 000 expériences » (janvier 2026) : https://www.businesswire.com/news/home/20260108572322/en/Block-Blast-Scales-to-70M-DAU-as-Hungry-Studio-Runs-Over-10000-Experiments-in-a-Single-Year
- AdMob, étude de cas Hungry Studio : https://admob.google.co.in/home/resources/hungry-studio-boosts-user-retention-revenue-with-admob/
- Digital Turbine, étude de cas DT Exchange : https://www.digitalturbine.com/case-studies/hungry-studio-hit-8-arpdau-in-one-month-with-dt-exchange/
- Apple Newsroom, Block Blast!+ sur Apple Arcade (août 2026) : https://apple.com/newsroom/2026/08/apple-arcade-levels-up-with-block-blast-plus-and-art-of-fauna-cozy-puzzles-plus/

**Analyses du marché et de la monétisation**

- Applixir, « The Block Blast playbook » (2026, d'après Sensor Tower, *Gaming Deep Dive: Ad Monetization*, juin 2026) : https://www.applixir.com/blog/the-block-blast-playbook-what-127m-in-ad-revenue-actually-bought/
- Udonis, statistiques (2026, données AppMagic) : https://www.blog.udonis.co/statistics/block-blast
- Gamigion, revenu publicitaire (2025) : https://www.gamigion.com/?p=12954
- Insightrackr, pubs d'acquisition : https://blog.insightrackr.com/en/docs/Block-Blast-Intelligence
- PocketGamer.biz, retrait de Google Play (mai 2026) : https://www.pocketgamer.biz/hungry-studios-block-blast-no-longer-available-on-google-play/ ; retour : https://www.pocketgamer.biz/hungry-studios-block-blast-returns-to-google-play/
- Baijing, retrait de Google Play et rumeur DMCA : https://www.baijing.cn/article/55485

**Avis de joueurs**

- Marlvel, synthèse des avis : https://marlvel.ai/apps/block-blast/reviews
- Adlock, pub après refus de « Continuer » : https://adlock.com/blog/remove-block-blast-ads
