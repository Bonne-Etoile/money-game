# Réglages recommandés (pubs, reprise, bonus, difficulté)

Demandé par Stelio le 11 novembre 2026 : quels réglages tirer de Block Blast, d'abord sur le nombre de pubs qu'on peut proposer avant que les joueurs se lassent, puis sur les autres réglages du jeu. Ce document part de `docs/etude-block-blast.md` (ce que fait Block Blast) et de `docs/strategies-pub.md` (règles et leviers), y ajoute les repères publics du marché, et donne pour chaque réglage : la valeur actuelle, ce qu'on sait ailleurs, la valeur de départ recommandée, et ce qu'il faut mesurer pour l'ajuster.

**Accord de Stelio le 11 novembre 2026** (« ok pour tout ») : les tickets 1, 2 et 4 de la section 9 et la reprise en mode niveaux sont faits (G18, réglages dans `game/data/ad_pacing_rules.tres`). Restent le ticket 3 (après mesure) et le ticket 5 (avant la sortie).

## 1. En bref

1. **Block Blast ne propose presque qu'une pub récompensée par partie** (« Continuer »), rationnée pour garder sa valeur ; le reste de son revenu vient des interstitiels et de la bannière, que nous n'avons pas (décision du 2026-11-09). Nous devons donc proposer **un peu plus** de récompensées que lui, mais à des moments choisis.
2. Aujourd'hui, une partie du mode infini peut faire voir **jusqu'à 7 pubs** (1 reprise + 2 bonus × 3) et rien ne limite la journée. C'est au-dessus des repères (3 à 5 par session, 15 à 20 par jour pour un jeu casual, tous formats confondus).
3. Recommandation de départ : **4 pubs au plus par partie** (1 reprise + 3 bonus, tous bonus confondus), **au moins 5 pièces posées entre deux pubs de bonus**, **15 pubs récompensées au plus par jour**, et **aucun bouton de pub pendant les 2 premières parties** d'un nouveau joueur.
4. But mesuré : **2 à 4 pubs vues par joueur actif et par jour**, avec **30 à 50 % des joueurs** qui en regardent au moins une. Au-delà, on vérifie que la durée des sessions et le retour le lendemain ne baissent pas.
5. Les autres réglages que Block Blast éclaire : la **difficulté autour du record** (notre montée par paliers de points sature vite), l'**aide après des défaites** (déjà chez nous), la **reprise offerte à qui décroche** (seuil à baisser de 3 à 2 jours), la **reprise en mode niveaux** (aujourd'hui absente), et les **nouveaux joueurs** (pièces faciles, pas de pub tout de suite).
6. Ce qu'on ne copie pas : la difficulté ou le nombre de pubs réglés selon ce que vaut le joueur, et les lots « mortels ».

## 2. Les repères : Block Blast et le marché

### Block Blast (`docs/etude-block-blast.md`, section 5)

| Point | Block Blast |
|---|---|
| Récompensée | « Continuer » après une défaite, **une par partie** en principe ; des reprises en plus seulement pour les joueurs qui rapportent beaucoup |
| Bouton sans pub prête | jamais (`IsOpenNoVideoNoRevivieTrait`) ; nous non plus |
| Nouveaux joueurs | pas de bannière les premiers jours ; pièces plus petites au début |
| Reprise gratuite | une fois par jour, sans pub, pour le joueur qu'un modèle voit décrocher |
| Session | ≈ 12 minutes, plusieurs fois par jour ; rétention J1 ≈ 26 % |
| L'éditeur | a **retiré des formats qui gênaient**, en perdant du revenu à court terme, pour la rétention |
| Plainte n°1 | la pub imposée après un refus de « Continuer » (nous n'en avons pas) |

La leçon d'Applixir sur Block Blast : **peu de pubs, au seul moment où le joueur en veut une, et rationnées**. Une pub de plus est un gain ponctuel ; un joueur perdu, c'est toutes ses pubs futures.

### Le marché (chiffres d'éditeurs et de régies, à prendre comme ordres de grandeur)

| Repère | Valeur | Source |
|---|---|---|
| Plafond par session | 3 à 5 récompensées pour un joueur moyen | Applixir |
| Plafond (casual) | 5 à 8 | Pangle |
| Plafond par jour (casual) | 15 à 20 (6 à 10 par session) | RevenueFlex |
| Pubs récompensées par joueur actif et par jour | 2 à 6 « sain » ; 1,5 dans l'exemple d'Applixir | RevenueFlex, Applixir |
| Part des joueurs qui en regardent | 25 % au début, plus de 35 % chez les joueurs installés, ≈ 5,5 pubs par jour pour ceux-là | Kongregate |
| Puzzle, sur la durée de vie | ≈ 23 à 24 récompensées par joueur (et 72 interstitiels) | Appodeal, *Mobile Casual Benchmarks 2025* |

Ces sources ont un intérêt commercial et ne mesurent pas toutes la même chose ; leur point commun : **un plafond par jour, réglé ensuite par des tests**. Les premières pubs de la journée d'un joueur se vendent aussi mieux (`docs/strategies-pub.md`, 4.6).

## 3. Pubs récompensées : combien et quand

| Réglage | Actuel | Recommandé au départ | Où | Pourquoi |
|---|---|---|---|---|
| Reprises par partie | 1 (`revives_per_game`) | **1** | existe | Comme Block Blast ; plus, la partie perd son enjeu |
| Pubs de bonus par partie | 3 **par bonus** (`bonus_ad_uses`), soit 6 avec deux bonus | **3 en tout**, tous bonus confondus | **code** | Le total doit rester le même quand on ajoutera des bonus (marteau, bombe…) |
| Total par partie | jusqu'à 7 | **4** (1 reprise + 3 bonus) | découle des deux lignes | Dans la fourchette 3 à 5 par session ; une partie dure moins qu'une session |
| Espacement entre deux pubs de bonus | aucun | **5 pièces posées** au moins | **code** | Évite d'enchaîner les pubs au même moment de détresse ; compté en coups, pas en secondes (testable, et juste pour le joueur lent) |
| Plafond par jour | aucun | **15** récompensées, toutes confondues | **code** | Haut de fourchette faute d'autres formats ; protège l'eCPM. Une fois atteint : boutons de pub cachés jusqu'au lendemain (les charges gratuites restent) |
| Nouveaux joueurs | boutons de pub dès la 1re partie | **aucun bouton de pub pendant les 2 premières parties** (`beginner_games`) ; les charges gratuites suffisent | **code** | Le joueur apprend le jeu et découvre les bonus gratuitement avant qu'on lui propose une pub ; Block Blast protège aussi ses débutants |
| Quand proposer un bonus | les boutons brillent quand 1 pièce au plus rentre (`trouble_fitting_pieces` = 1) | **1** | existe | C'est le moment où la pub vaut le plus pour le joueur |
| Charges gratuites | 1 par bonus et par partie (`bonus_free_uses`) | **1** | existe | Le joueur goûte au bonus, puis peut le vouloir contre une pub |
| Pub sans récompense | jamais | **jamais** | règle | Plainte n°1 contre Block Blast ; argument « aucune pub forcée » sur la fiche Play |

Effet attendu : un joueur moyen voit 1 à 2 pubs par partie (la reprise et parfois un bonus), soit 2 à 4 par jour s'il fait 2 à 3 parties. À 4 $ d'eCPM en France, cela fait ≈ 1 à 1,5 centime par joueur actif et par jour (`docs/strategies-pub.md`, section 2).

## 4. La reprise (« Continuer »)

| Réglage | Actuel | Recommandé | Où | Pourquoi |
|---|---|---|---|---|
| Quand l'offrir | à chaque défaite | à chaque défaite **si le score atteint 40 % du record**, et toujours pendant les **5 premières parties** | **code** | Une reprise sur une partie ratée a peu de valeur et use l'offre ; au début le record est bas et le joueur doit découvrir l'offre (`docs/strategies-pub.md`, 4.2, proposait 50 %) |
| Ce qu'elle donne | une croix de 3 lignes et 3 colonnes vidée au centre (`revive_clear_lines` = 3) | **3** | existe | Assez pour toutes nos pièces ; à réduire à 2 si les parties reprises durent trop longtemps |
| Mise en avant | « Il vous manquait N points » au-dessus du bouton | idem | existe (G10) | Block Blast attend ce moment pour proposer |
| Reprise offerte au retour | après **3 jours** d'absence (`comeback_days`) | **2 jours** | réglage | La rétention chute surtout les premiers jours (J1 ≈ 26 % chez Block Blast) ; un geste dès 2 jours rattrape plus de joueurs, pour le prix d'une pub |
| Mode niveaux | pas de reprise quand la grille est bloquée (`LevelGame` met 0) ; « +5 pièces (pub) » jusqu'à **2 fois** par essai quand il n'y a plus de pièces (`extra_pieces_ads`) | garder les 2 « +5 pièces », ajouter **1 reprise** quand la grille est bloquée, et compter le tout dans le plafond de 4 pubs par essai | **code** pour la reprise | Block Blast propose la reprise en Aventure ; perdre un niveau presque gagné est le moment où la pub vaut le plus |
| Défi du jour | reprise permise | permise tant qu'il n'y a pas de classement ; **interdite** le jour où un classement arrive | plus tard | Un classement doit comparer des parties sans aide payée |

## 5. Difficulté

Block Blast règle sa difficulté **par rapport au record** du joueur : facile loin en dessous, plus dure en approchant, et des pièces faciles après deux parties sous le record (`FailStreakStrategyTrait`). Nous avons déjà la seconde moitié.

| Réglage | Actuel | Recommandé | Où | Pourquoi |
|---|---|---|---|---|
| Parties de débutant | 2 (`beginner_games`), aidées (`help_level` = −1) | **3** | réglage | Block Blast soigne longtemps le début (pièces plus petites, premier score réglé) ; une partie de plus pour accrocher |
| Montée en cours de partie | +1 niveau tous les 200 points (`points_per_level`), 6 niveaux | **mesurer d'abord** le record moyen ; si la plupart des parties dépassent 1 000 points, la difficulté est au maximum bien avant le record | mesure, puis réglage ou **code** | Au-delà de 1 000 points, plus rien ne monte : la tension « près du record » disparaît. Piste : un niveau de plus tous les 20 % du record au lieu de tous les 200 points. **Fait (G19, 2026-11-12)** : rien sous 30 % du record, puis +1 tous les 15 % |
| Aide après des défaites | 2 parties sous la moyenne (`poor_games_for_help`) | **2** | existe | Exactement la règle que Block Blast fait tourner en direct |
| Garantie de jouabilité | jusqu'à 70 % de grille remplie (`playable_until_fill_percent`) | **70** | existe | Au-delà, perdre est juste ; ne jamais fabriquer un lot impossible |
| Pièces tirées par niveau | 1, 2, 2, 3, 3, 4 | idem | existe | À revoir seulement si les parties sont trop longues |
| Le hasard et les pubs | la difficulté ne lit jamais l'état des pubs | **jamais** | règle | C'est le scandale Block Blast d'octobre 2026 |

## 6. Aide, retours et score

| Réglage | Actuel | Recommandé | Pourquoi |
|---|---|---|---|
| Indice après hésitation | 10 s (`hint_after_seconds`) | **10 s** au début ; 15 s après les 10 premières parties (**code**) | Block Blast aide quand le joueur réfléchit longtemps ; le joueur confirmé veut moins d'aide (à confirmer par le test de Stelio, G15) |
| Bonus de grille vide | 300 (`empty_grid_bonus`) | **300** | Assez gros pour fêter, pas assez pour fausser le record |
| Bonus de combo et multi-effacement | +50 % chacun | **+50 %** | Block Blast récompense fortement les chaînes ; à garder |
| Retours d'effacement | en place (G13) | idem ; prévoir une version allégée pour les petits téléphones | Block Blast a des effets allégés (`CTLowDeviceEffectTrait`) |

## 7. Ce qu'on ne copie pas

- **Régler les pubs ou la difficulté selon ce que vaut le joueur** (pays, téléphone, prix des pubs reçues) : profilage soumis au consentement, et c'est ce qui a fait accuser Block Blast. La médiation choisit déjà la pub la mieux payée.
- **Des reprises en plus pour les joueurs « rentables »** : même raison ; une reprise par partie pour tous.
- **Les lots « mortels »** et tout lien entre l'état des pubs et les pièces.
- **Un bonus de score aléatoire après une pub** (`AdPlusMinusStrategyTrait`) : fausse le record.

## 8. Mesurer et ajuster

Les plafonds sont des points de départ. Il faut les mesurer dès le test fermé, puis les régler un à un (un seul changement à la fois, sur au moins une semaine).

| Mesure | Bon signe | Signal d'alerte |
|---|---|---|
| Pubs vues par joueur actif et par jour | 2 à 4 | moins de 1 : offres mal placées ou peu désirables |
| Part des joueurs qui regardent au moins une pub dans la journée | 30 à 50 % | moins de 20 % |
| Offres de reprise acceptées | plus de 30 % | moins de 15 % : offrir seulement près du record |
| Offres de bonus acceptées (quand les boutons brillent) | plus de 20 % | moins de 10 % |
| Joueurs qui atteignent le plafond du jour | moins de 5 % | plus de 10 % : relever à 20, s'ils reviennent le lendemain |
| Durée de session, parties par session, retour le lendemain (J1) | stables quand on relève un plafond | baisse de plus de 5 % : revenir au plafond précédent |
| eCPM selon le rang de la pub dans la journée | stable | chute nette après la n-ième : plafonner vers n |

`PlayerStats` compte déjà, par emplacement, les offres montrées, les pubs vues jusqu'au bout et fermées avant (G9). Il manque le compte par jour, et l'envoi des chiffres (Firebase Analytics ou une table Supabase, `docs/strategies-pub.md`, section 6). Les plafonds doivent pouvoir changer **sans mise à jour du jeu** (configuration à distance) avant la sortie.

## 9. Tickets proposés (à valider)

1. **Dosage des pubs récompensées** : plafond de pubs de bonus par partie tous bonus confondus (3), espacement de 5 pièces, plafond de 15 par jour (compte par jour dans `PlayerStats`, migration de sauvegarde), pas de bouton de pub pendant les parties de débutant. Réglages dans un `.tres`. Petit à moyen.
2. **Reprise seulement si la partie en vaut la peine** : 40 % du record, toujours pendant les 5 premières parties. Petit.
3. **Difficulté relative au record** : faite en avance (G19, 2026-11-12, accord de Stelio) ; seuils à régler avec le test fermé. Moyen.
4. **Réglages sans code** : `comeback_days` 3 → 2, `beginner_games` 2 → 3. Très petit, mais changent l'équilibrage : à tester par Stelio.
5. **Configuration à distance des plafonds** et **envoi des mesures** : avant la sortie (dépend du choix Firebase ou Supabase).

## Sources

Lues le 11 novembre 2026, en plus de celles de `docs/etude-block-blast.md` et `docs/strategies-pub.md`.

- Applixir, bonnes pratiques (plafond 3 à 5 par session) : https://support.applixir.com/hc/en-us/articles/360056835154-Best-Practices-
- Applixir, « The Block Blast playbook » (2026) : https://www.applixir.com/blog/the-block-blast-playbook-what-127m-in-ad-revenue-actually-bought/
- Pangle, placement des récompensées : https://www.pangleglobal.com/resource/27805
- RevenueFlex, récompensées dans les jeux mobiles : https://revenueflex.com/blog/rewarded-video-ads-mobile-game-monetization
- Kongregate, bonnes pratiques des pubs : https://blog.kongregate.com/best-practices-in-game-ads
- AppSamurai, récompensées : https://appsamurai.com/blog/rewarded-ads-in-mobile-games-strategy-data-and-best-practices/
- Appodeal, *Mobile Casual Benchmarks Report 2025* : https://appdevelopermagazine.com/Mobile-Casual-Benchmarks-Report-2025/
- Meta, bonnes pratiques de monétisation (tester placements et fréquence) : https://developers.facebook.com/docs/games/monetize/best-practices
