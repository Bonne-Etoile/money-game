# Stratégies pour maximiser le rendement publicitaire

Le but du projet : un jeu simple, vite sur le marché, conçu **autour du visionnage de pubs**. Ce document réunit les chiffres du marché, les règles à ne jamais franchir, les leviers psychologiques qui font regarder des pubs **de plein gré**, puis une recommandation de jeu et de technologie.

Recherches faites le 8 novembre 2026 (sources en bas de page). La publication sur Google Play est dans `docs/deploiement-android.md`.

## 1. L'idée directrice

Une pub regardée **par choix** rapporte plus, énerve moins et ne fait pas bannir le compte. Les pubs récompensées (*rewarded*) ont le meilleur prix (eCPM), le meilleur taux de remplissage, et ne coûtent presque rien en rétention. Les interstitiels forcés rapportent aussi, mais chaque interstitiel mal placé fait partir des joueurs, et un joueur parti ne regarde plus aucune pub.

Donc : **concevoir un jeu dont l'économie donne au joueur des raisons fréquentes et sincères de vouloir regarder une pub**, ajouter quelques interstitiels aux pauses naturelles, et une bannière discrète au plus.

L'équation du revenu :

```
revenu/jour = joueurs actifs/jour × pubs vues par joueur × eCPM / 1000
```

On agit sur les trois termes : **garder les joueurs** (rétention), **multiplier les occasions de pub voulues** (conception), **vendre chaque vue plus cher** (formats, médiation, consentement, pays).

## 2. Les formats

| Format | Principe | eCPM indicatif Europe de l'Ouest (Android) | eCPM indicatif États-Unis (Android) | Rôle dans notre jeu |
|---|---|---|---|---|
| **Récompensée** (*rewarded*) | vidéo de 15 à 30 s, choisie par le joueur contre une récompense | 3,6 $ (moyenne) ; jusqu'à 15–30 $ pour les meilleurs pays de premier rang | 12,9 $ | **cœur du modèle** |
| **Interstitiel récompensé** | plein écran annoncé par un écran d'intro avec bouton « non », récompense à la fin | proche de la récompensée | — | aux transitions, en complément |
| **Interstitiel** | plein écran imposé entre deux écrans | 3,3 $ | 11,1 $ | aux pauses naturelles, plafonné |
| **App open** | plein écran au retour dans l'application | proche de l'interstitiel | — | facultatif, au retour après une longue absence |
| **Bannière** | bande fixe en bas | 0,2 $ | 0,6 $ | peu rentable ; seulement sur des écrans calmes, loin des boutons |
| **Native** | pub intégrée au style de l'interface | variable | — | à éviter au début (risque de confusion avec le jeu) |

Les chiffres varient beaucoup selon les sources (de 2 à 8 fois) : moyennes Appodeal 2021–2022 relayées par Udonis, fourchettes « pays de premier rang » de Playwire 2025. Aucune source sérieuse ne donne de chiffre propre à la France : **nos vrais chiffres viendront des rapports AdMob par pays et par format**, dès les premières semaines. Constantes d'une source à l'autre :

- la récompensée est le format le mieux payé partout ; la bannière le moins bien ;
- iOS paie plus qu'Android, les États-Unis bien plus que l'Europe ;
- les prix montent d'octobre à décembre (pic en décembre) et s'effondrent en janvier ;
- un joueur qui refuse le consentement RGPD rapporte beaucoup moins (pubs non personnalisées).

### Ordre de grandeur réaliste

Pour **1 000 joueurs actifs par jour** en France, avec 4 pubs récompensées et 2 interstitiels par joueur et par jour, à 4 $ d'eCPM :
`1 000 × 6 × 4 / 1000 ≈ 24 $ par jour`, soit ≈ 700 $ par mois. Playwire donne, pour un jeu à 5 000 joueurs actifs par jour, 50 à 250 $ par jour selon la qualité et la part de pays riches. Autrement dit, **un joueur actif rapporte de l'ordre de 1 à 5 centimes par jour**. Le vrai défi n'est pas la pub, c'est **d'avoir des joueurs** (section 7).

## 3. Les règles qui font bannir un compte (à ne jamais faire)

Google ferme sans préavis les comptes AdMob pour trafic invalide, et supprime les jeux (puis le compte développeur en cas de récidive) pour pubs perturbatrices. Un compte AdMob fermé l'est en général définitivement, et les comptes liés avec. **Chaque idée de la section 4 a été vérifiée contre cette liste.**

### Interdit par AdMob

- **Cliquer sur ses propres pubs** ou faire cliquer ses proches, testeurs compris. Développer avec les pubs de test.
- **Payer ou récompenser un clic** sur une pub, ou promettre de l'argent pour regarder des pubs. **Aucune récompense en argent réel** : ni argent, ni cryptomonnaie, ni carte cadeau, ni points transférables. Un « jeu qui rapporte de l'argent au joueur » est donc exclu.
- **Pub récompensée non choisie** : elle ne se lance qu'après un choix clair et volontaire du joueur.
- **Ne pas donner la récompense promise** après la vidéo.
- **Ne pas annoncer clairement** avant la pub ce qu'il faut faire et ce qu'on gagne (« Regarder 3 pubs pour 100 pièces » si c'est un lot).
- **Textes qui forcent la main** : « Regarde cette pub pour nous soutenir », ou un bouton « non » caché, minuscule ou qui pénalise.
- **Récompense aléatoire sans transparence** : permise seulement si les chances sont annoncées avant la pub, si toutes les récompenses possibles sont visibles (y compris « rien »), et si chaque chance est supérieure à zéro.
- **Interstitiel au lancement ou à la sortie** de l'application, ou quand elle est en arrière-plan.
- **Plus d'un interstitiel toutes les deux actions** du joueur (le bouton Retour compte), deux interstitiels de suite, ou un interstitiel à chaque clic.
- **Interstitiel qui surgit pendant que le joueur est concentré** (en pleine partie), ou qui apparaît en retard par-dessus un nouvel écran (le précharger).
- Rafraîchir les bannières plus vite que le SDK ne le permet ; multiplier les requêtes de pub.

### Interdit par Google Play

- **Pub déguisée** en élément de l'interface, en notification ou en alerte du système ; il doit toujours être clair quelle application affiche la pub.
- **Faux bouton de fermeture**, ou pub placée **là où le joueur tape d'habitude** (sous le bouton « Jouer », à la place d'un bouton du jeu) : c'est le **clic accidentel**, la faute la plus fréquente.
- Pub plein écran **sans bouton de fermeture**, ou impossible à fermer après **15 secondes** (sauf récompensée choisie ou plein écran à une vraie pause, comme l'écran des scores).
- **Interstitiel au début d'un niveau** ou d'une séquence de jeu, ou avant l'écran de démarrage.
- **Obliger à regarder ou cliquer une pub** avant de pouvoir utiliser le jeu.
- Pubs **hors de l'application** (écran de verrouillage, bouton accueil, notifications).
- Demander la **localisation** pour la pub ; ignorer le refus de suivi publicitaire du joueur.
- Pub dont le contenu ne correspond pas à la classification du jeu.
- Application « faite pour les pubs » (*Made for Ads*) : interstitiels répétés qui gênent ce que fait le joueur. Un jeu sans contenu réel autour des pubs est refusé.

### Si des enfants sont visés : encore plus strict

Programme Familles : pubs fermables après 5 s, pas de pubs personnalisées, et **« tactiques choquantes ou émotionnellement manipulatrices pour encourager le visionnage » interdites**. C'est pourquoi le jeu doit viser **13 ans et plus** et ne pas avoir l'air d'un jeu pour enfants (voir `docs/deploiement-android.md`, section 6).

## 4. Les leviers psychologiques (permis)

Chaque levier ci-dessous est **compatible avec les politiques**, à condition de respecter la colonne « Garde-fou ». L'idée commune : la pub est **un raccourci que le joueur choisit**, jamais un péage.

### 4.1 Le multiplicateur de gain (« ×2 », « ×3 »)

- **Ressort** : aversion à la perte et ancrage. À la fin d'un niveau, le joueur voit son gain (« +120 pièces ») et, juste à côté, le gain doublé (« +240 avec une pub »). Refuser revient à « perdre » 120 pièces qu'il a sous les yeux.
- **Où** : écran de fin de niveau, coffre ouvert, gains hors ligne.
- **Garde-fou** : bouton « Continuer » (gain simple) bien visible et de même taille, sans texte culpabilisant. Le gain annoncé est exactement celui reçu.
- C'est le levier le plus rentable du genre ; il donne souvent un taux de visionnage très élevé à chaque fin de niveau.

### 4.2 La seconde chance (« Continuer »)

- **Ressort** : effet de dotation et coût irrécupérable. Le joueur a investi dans sa partie ; perdre près du record est frustrant. « Continuer d'où tu es tombé ? » arrive au moment où la valeur perçue de la pub est maximale.
- **Garde-fou** : une seule seconde chance par partie (sinon la partie n'a plus d'enjeu) ; chrono de quelques secondes **avec** un bouton « Non merci » visible ; n'afficher l'offre que si la partie en vaut la peine (score à au moins 50 % du record, par exemple), pour qu'elle reste désirable.

### 4.3 Les gains hors ligne

- **Ressort** : récompense différée et retour quotidien. Le jeu « travaille » pendant l'absence ; au retour : « Pendant ton absence : 3 400 pièces. ×3 avec une pub ? »
- **Où** : au retour dans le jeu, **après** l'écran de démarrage, en fenêtre que le joueur ferme ou accepte (pas un interstitiel au lancement).
- **Garde-fou** : le gain de base reste acquis sans pub.

### 4.4 Le boost temporaire

- **Ressort** : gain immédiat et rareté. « Revenus ×2 pendant 30 minutes. » Le boost qui expire crée une envie de le relancer, et rend la session plus longue.
- **Garde-fou** : durée et effet affichés avant la pub ; boosts cumulables jusqu'à un plafond (ex. 4 heures), pour récompenser le joueur assidu.

### 4.5 Sauter l'attente

- **Ressort** : impatience (préférence pour le présent). Une amélioration ou un bâtiment prend 2 heures ; une pub les réduit de 30 minutes ou les termine.
- **Garde-fou** : attendre doit rester une option réelle et raisonnable ; sinon le jeu « oblige » à regarder.

### 4.6 La rareté organisée (plafond quotidien)

- **Ressort** : rareté et valeur perçue. « Coffre gratuit : 3 restants aujourd'hui. » Un plafond rend chaque pub plus précieuse, crée un rendez-vous pour le lendemain et évite l'usure du joueur.
- **Effet secondaire utile** : les annonceurs paient mieux les premières pubs de la journée d'un joueur ; plafonner protège l'eCPM.

### 4.7 La série et le rendez-vous quotidien

- **Ressort** : habitude et peur de perdre la série. Bonus quotidien croissant (jour 1 à 7), doublé par une pub. Une pub peut aussi **sauver une série** interrompue.
- **Garde-fou** : la série se garde sans pub si le joueur revient chaque jour.

### 4.8 La jauge de progression vers une récompense

- **Ressort** : effet de gradient de l'objectif (on accélère près du but) et progression dotée (une jauge déjà entamée motive). « Regarde 5 pubs cette semaine → skin exclusif », avec une jauge qui démarre à 1/5.
- **Garde-fou** : AdMob exige d'annoncer un lot de pubs à l'avance : afficher clairement « 5 pubs = ce skin ». Chaque pub de la jauge donne aussi sa propre petite récompense.

### 4.9 Le coffre mystère

- **Ressort** : récompense variable (le plus puissant des ressorts d'habitude).
- **Garde-fou strict** : chances affichées **avant** la pub, toutes les récompenses visibles, aucune case « rien » sans l'annoncer, et rien qui ressemble à un casino (roue, machine à sous, cartes à gratter : risque de classification « jeux d'argent simulés », interdit si des enfants jouent). **Recommandation** : contenu toujours garanti, seule la **rareté** varie (commun, rare, épique), présentation en coffre et non en roue.

### 4.10 Le contenu cosmétique « offert par une pub »

- **Ressort** : identité et collection. Skins, couleurs, décors débloquables par des pubs. Le joueur qui collectionne revient.
- **Garde-fou** : récompense utilisable uniquement dans le jeu et non transférable (règle AdMob).

### 4.11 La trêve d'interstitiels

- **Ressort** : réciprocité. « Merci d'avoir regardé ! Pas de pub forcée pendant 10 minutes. » Le joueur apprend que regarder une pub choisie lui épargne les pubs imposées : il préfère la récompensée, mieux payée.
- C'est aussi un argument loyal pour présenter les pubs.

### 4.12 L'achat « Sans pubs »

- **Ressort** : ancrage et confort. Un achat unique (2 à 4 €) qui supprime **les interstitiels et bannières**, en gardant les pubs récompensées volontaires (et souvent un bonus de bienvenue). Il rapporte en général plus qu'un joueur très actif sur toute sa vie, et rend les pubs forcées plus acceptables (« tu peux les enlever »).
- **Coût** : ajoute Google Play Billing et des démarches (version 1.1, pas au lancement).

### 4.13 Bien placer et présenter le bouton

- Bouton de pub **coloré, avec une icône vidéo** (Lucide `clapperboard` ou `play`) et la récompense écrite dessus : « ▶ ×2 », « ▶ +50 💎 ». Le joueur doit comprendre en un coup d'œil ce qu'il gagne.
- Toujours afficher la **valeur concrète** (« +240 pièces ») plutôt qu'un pourcentage.
- Le jeu **montre l'effet** de la récompense tout de suite (animation de pièces, compteur qui grimpe) : le cerveau associe pub et plaisir.
- Préchargement : la pub doit être **prête** quand le bouton s'affiche ; sinon masquer le bouton (un bouton qui ne marche pas casse la confiance).

### Leviers à proscrire, même s'ils « marcheraient »

| Idée | Pourquoi non |
|---|---|
| Bouton « Non merci » minuscule, grisé ou décalé | « Option non qui gêne l'usage normal » : interdit par AdMob |
| Texte culpabilisant (« Non, je n'aime pas les cadeaux ») | Texte qui force le choix : interdit par AdMob ; manipulatoire au sens du programme Familles |
| Interstitiel juste après un tap sur « Jouer » | Interstitiel inattendu et clic accidentel : interdit |
| Bannière collée aux boutons du jeu | Clics accidentels : trafic invalide |
| Pub qui se lance seule en prétendant donner une récompense | Récompensée non choisie : interdit |
| Récompense en argent, cartes cadeaux, tirages au sort réels | Interdit par AdMob, sans exception |
| Rendre le jeu impossible sans pub (mur de difficulté) | Obliger à regarder : interdit par Google Play ; et ça fait fuir |
| Roue de la fortune ou machine à sous à pub | Jeu d'argent simulé : classification, enfants, image du jeu |
| Faux compte à rebours (« offre expire dans 0:10 » qui revient sans cesse) | Pratique trompeuse ; risque de refus |

## 5. Interstitiels : où et combien

> **Décision du 2026-11-09 (Stelio)** : aucune pub forcée pour le moment (ni interstitiel, ni bannière). Cette section sert le jour où la décision serait revue.

- **Seulement aux pauses naturelles** : après l'écran de résultat, en revenant au menu, entre deux niveaux. Jamais au lancement, au début d'un niveau, ni pendant la partie.
- **Plafonds de départ** (à régler ensuite avec les chiffres) :
  - pas d'interstitiel pendant les **3 premières parties** ou la **première session** (laisser le joueur accrocher) ;
  - au plus **un toutes les 2 à 3 parties** et **un toutes les 90 à 120 secondes** ;
  - aucun pendant les **10 minutes** qui suivent une pub récompensée (trêve, section 4.11) ;
  - plafond quotidien (par exemple 15).
- **Réglables à distance** : ces plafonds doivent vivre dans une configuration modifiable sans mettre à jour le jeu (Supabase ou Firebase Remote Config), pour tester sans attendre un examen de Google Play.

## 6. Médiation et réglages techniques

- **Au lancement : AdMob seul.** Une intégration, une déclaration Data safety, un seul tableau de bord.
- **À partir d'environ 1 000 joueurs actifs par jour : médiation par enchères** (*bidding*) dans AdMob, avec 2 à 4 réseaux (AppLovin, Unity Ads, Liftoff/Vungle, Meta Audience Network, Mintegral, ironSource). Plus de concurrence = meilleur prix par vue (les éditeurs annoncent souvent +10 à +40 %, chiffres non vérifiés). Chaque réseau ajouté : un adaptateur, une ligne dans la politique de confidentialité, dans la liste des partenaires de UMP et dans Data safety.
- Alternative : AppLovin MAX comme médiateur principal (souvent choisi par les jeux *hypercasual*). À évaluer plus tard, pas au lancement.
- **`app-ads.txt` à jour** pour chaque réseau.
- **Consentement** : le formulaire UMP standard, en langue du joueur. Un taux d'accord plus élevé (formulaire clair, affiché au bon moment) relève l'eCPM européen ; ne jamais le truquer.
- **Préchargement** des pubs dès la fin de la précédente ; réessai avec délai croissant en cas d'échec.
- **Pays visés** : fiche Play traduite en anglais au minimum ; les États-Unis, le Royaume-Uni, l'Allemagne, le Canada et l'Australie paient 2 à 4 fois plus que la moyenne.

### Ce qu'il faut mesurer dès la première version

| Mesure | Pourquoi |
|---|---|
| Joueurs actifs par jour (DAU), rétention J1 / J7 / J30 | Le terme le plus important de l'équation |
| Pubs vues par joueur et par jour, par format et par emplacement | Savoir quels leviers marchent |
| Taux d'engagement des récompensées (offres vues → pubs regardées) | Une offre peu prise est mal placée ou peu désirable |
| eCPM et taux de remplissage par pays et par format | Vrais chiffres, à la place des estimations de la section 2 |
| ARPDAU (revenu par joueur actif par jour) | Comparer au coût d'acquisition d'un joueur |
| Durée de session, sessions par jour | L'usure : si elles baissent, trop de pubs |

AdMob donne les chiffres de pub ; Firebase Analytics (gratuit) ou une table Supabase d'événements donne la rétention et les entonnoirs.

## 7. Trouver des joueurs

Sans joueurs, aucune stratégie de pub ne rapporte. Pour un premier jeu :

- **ASO** (référencement sur le Play Store) : titre et description courte avec les mots-clés du genre, icône très lisible, captures qui montrent le jeu en 2 secondes, traductions.
- **Vidéos courtes** (TikTok, YouTube Shorts, Reels) montrant le moment le plus satisfaisant du jeu : le canal gratuit qui marche le mieux pour les jeux simples. **Toute publication demande l'accord explicite de Stelio** (règle de `CLAUDE.md`).
- **Acquisition payante** seulement quand l'ARPDAU et la rétention montrent qu'un joueur rapporte plus qu'il ne coûte (souvent 0,2 à 1 $ par installation en Europe pour un jeu simple ; chiffre à vérifier sur nos propres campagnes).
- **Penser le jeu pour la vidéo** : un effet visuel satisfaisant, compréhensible sans son, est à la fois du marketing et de la rétention.

## 8. Quel jeu construire autour de la pub


### Ce que le marché télécharge (2025–2026)

Chiffres AppMagic (année 2025, App Store + Google Play, monde) et FoxData (août 2026) :

| Rang 2025 | Jeu | Téléchargements 2025 | Genre | Modèle |
|---|---|---|---|---|
| 1 | **Block Blast** | 368 M | **puzzle de blocs (façon Tetris, sans chute)** | **presque 100 % pub** |
| 2 | Roblox | 295 M | plateforme de jeux | achats |
| 3 | Free Fire | 287 M | battle royale | achats |
| 4 | Subway Surfers | 191 M | course infinie | pub + achats |
| 5 | Pizza Ready | 166 M | gestion de restaurant (*idle* arcade) | pub + achats |
| 6 | Ludo King | 151 M | jeu de plateau (petits chevaux) | pub + achats |
| 7 | Vita Mahjong | ≈ 122 M | mahjong solitaire | pub + achats |
| 8 | My Talking Tom 2 | 122 M | animal virtuel (enfants) | pub + achats |
| 9 | Hole.io | 121 M | arcade « .io » | pub |
| 12 | Candy Crush Saga | 111 M | match-3 | achats |
| 15 | Paper.io 2 | 102 M | arcade « .io » | pub |
| 19 | Tile Explorer | 96 M | association de tuiles | pub + achats |

Ce qu'on en tire :

- **Les jeux les plus téléchargés au monde sont des classiques très simples** : blocs, mahjong, tuiles, petits chevaux, billard, course infinie. L'intuition « un jeu bateau avec une accroche » est celle du marché.
- **Block Blast est le cas d'école** : n°1 mondial en 2025 et encore en août 2026 (≈ 25 M de téléchargements par mois), monétisé presque uniquement par la pub (plus gros revenu publicitaire de jeu mobile de janvier à mai 2026 selon Sensor Tower, ≈ 127 M $). Plus de 2 000 clones sont sortis au premier semestre 2026 : le genre marche, mais il est encombré, d'où l'importance de l'accroche.
- **Genres casual en croissance** (AppMagic) : puzzle de blocs (revenus ×10 en 2025), tri (*sort* : billes, couleurs, liquides ; ×2 puis ×3), vis et écrous (*screw*, ×2), mahjong (+189 % de téléchargements), flèches à faire sortir (*arrow puzzle*, surtout financé par la pub). En recul : match-3 (sauf les géants) et casino.
- **L'hypercasual** (parties de 30 s, un seul geste) fait encore ≈ 44 % des téléchargements mondiaux, mais rapporte peu par joueur : la rétention est courte. Les classiques de réflexion gardent leurs joueurs des mois, ce qui compte pour la pub.
- **Ces classiques de réflexion attirent surtout des adultes** (hypothèse courante dans le secteur, non chiffrée dans nos sources) : un public hors du programme Familles, qui joue en pause ou le soir et accepte bien la pub récompensée.

### Recommandation révisée : un puzzle de blocs avec une accroche

À la suite de la remarque de Stelio (2026-11-08 : un jeu de gestion ne touche peut-être pas assez large et n'est pas si simple à faire), la meilleure piste est **un classique de réflexion type Block Blast / Tetris, avec une accroche nouvelle** :

- **Public le plus large du marché**, règles comprises en 3 secondes, aucune lecture nécessaire (toutes les langues).
- **Très simple à développer** : une grille, des pièces, des lignes qui disparaissent, un score. La logique tient dans `game/core/` et se teste unitairement.
- **Parties de 2 à 5 minutes** qui se terminent par un échec : moments naturels pour la **seconde chance** (4.2), le **×2 du score ou des pièces** (4.1) et un interstitiel à l'écran de fin (section 5).
- **Leviers ajoutables sans complexifier le jeu** : « joker » qui change les pièces proposées ou supprime un bloc (une pub = un joker), défi quotidien, série (4.7), thèmes et blocs cosmétiques (4.10).
- **Vidéos courtes faciles** : une grille qui se vide en cascade est très satisfaisante à regarder.

Idées d'accroche (à départager en prototype, quelques jours chacune) :

1. **Gravité et matières** : les blocs ont une matière (sable qui s'écoule, glace qui glisse, bois qui flotte) ; effacer une ligne fait bouger le reste, avec des combos en chaîne.
2. **Couleurs** : une ligne d'une seule couleur rapporte ×5 ; donne une décision à chaque pose sans changer les règles.
3. **Image à révéler** : chaque ligne effacée dévoile une partie d'une illustration (collection d'images à compléter, très bon pour la rétention et le cosmétique).
4. **Aventure par niveaux** : objectifs courts (« libère les 3 gemmes », « 20 lignes en 15 coups ») sur une carte, en plus du mode infini.

Autres classiques « bateau » possibles avec la même logique : **tri de couleurs** (*sort*), **mahjong / association de tuiles**, **flèches à faire sortir**. Le puzzle de blocs reste en tête pour sa simplicité et son public.

### Autre piste : un jeu *idle* (« incrémental ») de gestion

Exemple de thème : **un petit empire qui grandit** (stand de citronnade → chaîne de magasins, ou une usine, une mine, une ferme). Le joueur tape, achète des améliorations, automatise, et ses revenus grimpent pendant son absence.

Pourquoi ce genre est fait pour la pub :

| Critère | Idle | Arcade hypercasual (un tap, une partie de 30 s) |
|---|---|---|
| Occasions de pub récompensée | **très nombreuses** : gains hors ligne ×3, boosts ×2, accélérations, coffres, bonus quotidien | surtout ×2 en fin de partie et seconde chance |
| Interstitiels | peu nécessaires | essentiels (une partie = un interstitiel), plus irritants |
| Rétention | **longue** (des semaines) : le joueur revient chaque jour voir ses gains | courte (quelques jours) |
| Développement | interface (boutons, compteurs, animations) ; **pas de physique** | gameplay à régler finement (sensations) |
| Contenu | des chiffres et des paliers, faciles à étendre par données | des niveaux ou obstacles à produire |
| Risque de rejet « fait pour les pubs » | faible : vrai jeu de progression | plus élevé si le jeu est mince |

Les leviers 4.1 à 4.12 s'y appliquent presque tous naturellement. L'équilibrage (prix, multiplicateurs, temps) se règle par des données et se simule par script, ce qui colle à notre façon de travailler (logique pure testée).

### Version minimale pour sortir vite (≈ 2 à 4 semaines de développement)

1. Un écran principal : compteur d'argent, un gros bouton à taper, 5 à 8 « entreprises » à acheter et améliorer (coûts croissants).
2. Revenus automatiques par seconde, gains hors ligne (plafonnés à quelques heures).
3. Pubs récompensées : gains hors ligne ×3 au retour, boost revenus ×2 pendant 30 min, coffre gratuit (3 par jour).
4. Un interstitiel au plus, à l'achat d'un palier important (pause naturelle), avec les plafonds de la section 5.
5. Sauvegarde locale, réglages (son, langue, confidentialité / consentement).
6. Français et anglais.

Ensuite, par mises à jour : bonus quotidien et série, « prestige » (recommencer avec un multiplicateur permanent : énorme pour la rétention), skins, achat « Sans pubs », médiation.

Autres genres possibles, si l'idle ne plaît pas : **puzzle de fusion** (*merge*, très bon aussi pour la pub, un peu plus long à faire), **jeu de réflexion à niveaux** (mots, tri de couleurs ; indices et ×2 en récompensée). À éviter : tout thème casino ou loterie, et tout jeu d'action qui demande des sensations fines (long à régler, voir `CLAUDE.md`).

## 9. Quelle technologie

### Option A : SvelteKit + Capacitor (la stack préférée de Stelio)

- **Principe** : le jeu est une application web (SvelteKit en `adapter-static`, Tailwind, shadcn-svelte, icônes Lucide) emballée dans une application Android native par **Capacitor**.
- **Pub** : plugin **`@capacitor-community/admob`** (MIT, maintenu, version 8.x pour Capacitor 8) : bannière, interstitiel, récompensée, interstitiel récompensé, *app open*, et l'API de consentement UMP (`requestConsentInfo`, `showConsentForm`, `showPrivacyOptionsForm`). La documentation de l'ordre consentement / initialisation est contradictoire d'une source à l'autre : suivre le README du plugin à jour au moment de l'intégration.
- **Pour un idle** : excellent choix. Le jeu est fait de boutons, de compteurs et d'animations, exactement ce que Svelte fait bien ; les transitions Svelte et CSS suffisent pour les effets. Le développement et les tests se font dans le navigateur, très vite. Supabase est **facultatif** au départ (sauvegarde locale via `@capacitor/preferences`), puis utile pour la configuration à distance des plafonds de pub, un classement ou la sauvegarde dans le nuage.
- **Limites** : moins adapté à un jeu d'action (physique, centaines d'objets animés) ; performances de la WebView sur les vieux téléphones à surveiller ; outillage à créer (le dépôt actuel est un modèle Godot).

### Option B : Godot 4.7 (le modèle actuel du dépôt)

- **Pub** : plugin **poingstudios `godot-admob-plugin`** (MIT, actif ; version 5.1.0 de septembre 2026, testée jusqu'à Godot 4.7.2) : tous les formats, UMP, pubs factices dans l'éditeur.
- **Avantages** : le dépôt est déjà prêt (tests, captures, CI, règles), idéal pour un jeu d'action ou à physique.
- **Limites** : le modèle est réglé pour la 3D sur PC (Forward+, Steam) : il faut passer au rendu Mobile ou Compatibility, ajouter l'export Android (SDK Android, JDK, Gradle) à la session cloud et à la CI ; une interface riche (listes, boutons, animations de chiffres) demande plus de travail qu'en Svelte ; Stelio ne lit pas le GDScript aussi facilement que du Svelte.

### Décision

**Godot 4.7**, choisi par Stelio le 8 novembre 2026 (`docs/architecture.md`, décision 16). Le genre reste à décider (`docs/backlog.md`, D2) : un puzzle de blocs en 2D se fait très simplement en Godot (grille en nœuds 2D, logique pure dans `game/core/`, réglages en ressources `.tres`).

## Sources

Politiques (lues le 8 novembre 2026) :

- AdMob, interstitiels interdits : https://support.google.com/admob/answer/6201362
- AdMob, pubs récompensées : https://support.google.com/admob/answer/7372450 et règles de récompense https://support.google.com/admob/answer/7313578
- AdMob, règlement du programme et clics invalides : https://support.google.com/admob/answer/6128543 et https://support.google.com/admob/answer/2753860
- Google Play, règles sur les annonces : https://support.google.com/googleplay/android-developer/answer/9857753
- Google Play, programme Familles : https://support.google.com/googleplay/android-developer/answer/9893335

Chiffres du marché (sources d'éditeurs, à prendre comme ordres de grandeur) :

- Playwire, *AdMob eCPM benchmarks* (septembre 2025) : https://www.playwire.com/blog/admob-ecpm-benchmarks-what-publishers-should-expect
- Udonis, eCPM par région, données Appodeal 2021–2022 : https://blog.udonis.co/mobile-marketing/mobile-apps/ecpms
- Appodeal, *eCPM Report* (octobre–décembre 2024) : https://appodeal.com/the-mobile-ecpm-report-updated-q4-2024-view
- Segwise, *AdMob for game monetization* (mis à jour juillet 2026) : https://segwise.ai/blog/google-ads-game-monetization.md

Marché des jeux (lus le 8 novembre 2026) :

- Jeux les plus téléchargés en 2025 (AppMagic) : https://mobilegamer.biz/the-top-mobile-game-downloads-of-2025/ et https://www.pocketgamer.biz/the-most-downloaded-mobile-games-of-2025
- AppMagic, *Casual Games Report H1 2026* : https://appmagic.rocks/research/casual-report-H12026
- AppMagic, jeux casual 2025 (résumé) : https://mobidictum.com/appmagic-casual-games-report-2025-summary/
- FoxData, classement d'août 2026 : https://foxdata.com/en/blogs/global-mobile-game-rankings-august-2026-top-15-downloads-revenue/
- Synthèse des tendances casual 2026 (source secondaire) : https://app.cinevva.com/guides/casual-games-trends-2026

Technologie :

- Plugin AdMob pour Godot : https://github.com/poingstudios/godot-admob-plugin
- Plugin AdMob pour Capacitor : https://github.com/capacitor-community/admob
- Consentement avec Capacitor (article d'éditeur, octobre 2026) : https://capgo.app/blog/admob-gdpr-consent-capacitor/
