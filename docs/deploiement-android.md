# Publier le jeu sur Google Play (Android)

Tout ce qu'il faut pour mettre un jeu financé par la publicité sur le Google Play Store, dans l'ordre où on le rencontre. iOS est mis de côté pour l'instant.

Recherches faites le 8 novembre 2026. Les règles de Google changent souvent : chaque chiffre a sa source en bas de page, à revérifier au moment de publier. La monétisation elle-même (formats de pub, leviers, politiques AdMob) est dans `docs/strategies-pub.md`.

## Résumé : le chemin le plus court

| Étape | Durée | Qui |
|---|---|---|
| 1. Compte développeur Google Play personnel (25 $, pièce d'identité, téléphone Android) | 1 à 3 jours de vérification | Stelio |
| 2. Compte AdMob, lié au même compte Google, profil de paiement | 1 jour | Stelio |
| 3. Politique de confidentialité en ligne (URL publique) et site pour `app-ads.txt` | quelques heures | Claude rédige, Stelio publie |
| 4. Build Android signé (AAB), API cible 36, pubs de test | — | Claude |
| 5. Fiche Play Store, questionnaires (classification, Data safety, public cible, pubs) | 1 jour | Claude prépare, Stelio remplit |
| 6. **Test fermé : 12 testeurs inscrits pendant 14 jours d'affilée** | 14 jours minimum | Stelio recrute |
| 7. Demande d'accès à la production, puis examen de Google | ≈ 7 jours | Google |
| 8. Publication en production, puis activation des vraies pubs | — | Stelio valide |

**Compter environ un mois** entre le premier build jouable et la sortie publique, à cause du test fermé obligatoire. Le recrutement des 12 testeurs est l'étape à lancer le plus tôt possible.

## 1. Compte développeur Google Play

- **Frais** : 25 $ US, une seule fois. Carte de crédit ou de débit (Visa, Mastercard, American Express ; pas de carte prépayée).
- **Conditions** : avoir 18 ans ; accepter le *Developer Distribution Agreement* ; nom légal, adresse, téléphone et pièce d'identité officielle **au même nom que la carte**. Si les informations sont jugées invalides, les 25 $ ne sont pas remboursés.
- **Compte personnel ou organisation** :
  - *Personnel* : le plus simple, mais soumis au test fermé obligatoire (section 7) et à la vérification d'un appareil Android (application Play Console sur un vrai téléphone). Le nom légal et le pays sont affichés sur la fiche publique ; l'adresse aussi si le jeu contient des achats intégrés (pas le cas avec la pub seule, à vérifier au moment venu).
  - *Organisation* : demande un numéro **D-U-N-S** (gratuit, quelques jours à semaines) et une structure légale (société, micro-entreprise selon les cas). Pas de test fermé obligatoire. Utile plus tard si le projet devient une activité.
  - **Recommandation** : compte personnel pour commencer. Passer en organisation plus tard est possible, mais le transfert d'application entre comptes demande une procédure : à anticiper si une société est prévue à court terme.
- **Vérification des développeurs Android (2026)** : Google exige désormais une identité vérifiée pour tout développeur Android, même hors Play Store. Un compte Play Console vérifié est déjà couvert : rien de plus à faire pour nous.
- **Contact public** : une adresse e-mail de contact est obligatoire et affichée sur la fiche. Prévoir une adresse dédiée au jeu.

## 2. Compte AdMob

- Créé avec le même compte Google. Ajouter l'application dans AdMob (d'abord « non publiée », puis la relier à la fiche Play une fois en ligne).
- **Vérification de l'application** : AdMob examine l'application une fois liée à la fiche Play ; avant cela, les pubs sont en « diffusion limitée ».
- **Profil de paiement** : nom, adresse, RIB, informations fiscales. Le paiement est mensuel une fois le seuil atteint (environ 70 € pour un compte en euros, 100 $ en dollars ; à vérifier dans AdMob).
- **Fiscalité en France** : les revenus AdMob sont des revenus d'activité à déclarer (souvent sous le statut de micro-entrepreneur, en BNC). Ce point n'est pas un conseil juridique : à valider avec un comptable ou l'URSSAF avant les premiers revenus réguliers.
- **Pubs de test pendant tout le développement** : ID de test de Google ou appareil déclaré comme appareil de test. **Ne jamais cliquer sur ses propres pubs réelles** : c'est la cause n°1 de fermeture définitive d'un compte AdMob.

## 3. Site web, politique de confidentialité et `app-ads.txt`

- **Politique de confidentialité** : obligatoire dès qu'un SDK publicitaire est présent. URL publique, active, non modifiable par n'importe qui, qui nomme le jeu et le développeur et décrit les données collectées (identifiant publicitaire, adresse IP, données d'appareil, journaux de plantage), leurs usages (publicité, mesure, personnalisation selon le consentement), les partenaires (Google AdMob et chaque réseau de médiation) et la façon de retirer son consentement.
- **`app-ads.txt`** : fichier à la racine du site du développeur (le domaine indiqué dans la fiche Play), qui liste les vendeurs de pub autorisés. Sans lui, les annonceurs achètent moins cher ou pas du tout. AdMob fournit la ligne à copier.
- **Solution simple** : une page statique (SvelteKit en `adapter-static`, GitHub Pages ou Netlify) avec la politique, une page de contact et `app-ads.txt`. Nom de domaine propre recommandé (≈ 10 €/an) : il sert aussi au `app-ads.txt` et ne change pas si on change d'hébergeur.

## 4. Consentement (RGPD, UMP)

- En Europe (EEE), au Royaume-Uni et en Suisse, Google impose une **plateforme de gestion du consentement certifiée par Google (CMP)** pour diffuser des pubs. La plus simple : **UMP** (*User Messaging Platform*) de Google, gratuite, intégrée à AdMob (onglet « Confidentialité et messages »).
- **Ordre à respecter au lancement** :
  1. demander l'état du consentement (`requestConsentInfoUpdate`) à **chaque** lancement ;
  2. afficher le formulaire s'il est requis (`loadAndShowConsentFormIfRequired`) ;
  3. n'initialiser le SDK et ne charger des pubs que si `canRequestAds` est vrai ;
  4. proposer dans les options du jeu un bouton « Confidentialité » qui rouvre le formulaire (`showPrivacyOptionsForm`) quand c'est requis.
- Un joueur qui refuse voit des pubs **non personnalisées** (ou limitées) : elles rapportent nettement moins. Le formulaire ne doit pas être truqué pour forcer l'accord ; c'est le formulaire de Google, on le laisse tel quel.
- Messages à activer dans AdMob : RGPD (Europe), et les États américains (CCPA et suivants) si le jeu est diffusé aux États-Unis.

## 5. Le build Android

### Format et signature

- **Android App Bundle (`.aab`)** obligatoire pour toute nouvelle application sur Google Play (l'APK sert seulement aux tests directs sur téléphone).
- **Play App Signing** : Google garde la clé de signature finale ; nous signons avec une **clé d'importation** (*upload key*). Si la clé d'importation est perdue, Google peut la réinitialiser ; la garder quand même en lieu sûr, avec son mot de passe, **hors du dépôt** (gestionnaire de mots de passe de Stelio ; secret GitHub plus tard si la CI produit les builds).
- **Nom de package** (ex. `com.bonneetoile.nomdujeu`) : **unique et définitif**, il ne pourra jamais être changé ni réutilisé. À choisir avec soin.
- **`versionCode`** : entier, à augmenter à chaque envoi sur Play (maximum 2 100 000 000). `versionName` : version lisible (`1.0.3`).

### Niveau d'API cible

- Depuis le **31 août 2026**, toute nouvelle application et toute mise à jour doit cibler **Android 16 (API 36)** ou plus (prolongation possible jusqu'au 1er novembre 2026, déjà passée). La règle avance chaque année vers fin août : prévoir une mise à jour annuelle du `targetSdk`, sinon plus de mise à jour possible.
- `minSdk` : le SDK Google Mobile Ads et les plugins demandent au moins API 23 ou 24 ; viser **API 24 (Android 7)**, qui couvre la quasi-totalité des téléphones en service.

### Selon le moteur (voir `docs/strategies-pub.md`, section « Quelle technologie »)

- **Godot 4.7** : export Android avec le SDK Android, un JDK 17 et l'option **« Use Gradle Build »** (obligatoire pour les plugins Android comme AdMob). Format d'export AAB, keystore de release et `target_sdk` dans le préréglage d'export. Le modèle actuel n'exporte que Windows et Linux : il faudra ajouter le préréglage Android, les modèles d'export Android et le SDK Android dans `tools/setup-cloud.sh` (ticket dédié ; la doc officielle Godot n'a pas pu être lue depuis la session aujourd'hui, à vérifier à ce moment-là).
- **SvelteKit + Capacitor** : `adapter-static` (pas de SSR), `npx cap add android`, build Gradle en `bundleRelease`. Le `targetSdkVersion` et le `compileSdkVersion` se règlent dans `android/variables.gradle`.

### Contenu du manifeste à vérifier

- Permission `com.google.android.gms.permission.AD_ID` (ajoutée par le SDK) : déclarer « oui, j'utilise l'identifiant publicitaire » dans la Play Console.
- `com.google.android.gms.ads.APPLICATION_ID` : l'ID d'application AdMob.
- **Aucune permission inutile** (localisation, contacts, stockage) : chacune doit être justifiée et alourdit la fiche Data safety. Ne jamais demander la localisation pour la pub (interdit).

## 6. Fiche Play Store et questionnaires (« Contenu de l'application »)

| Élément | Ce qu'il faut |
|---|---|
| Nom | 30 caractères maximum |
| Description courte / longue | 80 / 4 000 caractères ; en anglais et en français |
| Icône | 512 × 512 px, PNG 32 bits |
| Image de présentation | 1 024 × 500 px |
| Captures d'écran | au moins 2 (téléphone), recommandé 4 à 8 |
| Vidéo | facultative (lien YouTube) |
| Catégorie | Jeux → sous-catégorie (Occasionnel, Réflexion, Simulation…) |
| Politique de confidentialité | URL de la section 3 |
| **Annonces** | déclarer que l'application **contient des annonces** (badge « Contient des annonces » sur la fiche) |
| **Classification du contenu** | questionnaire IARC (gratuit) : violence, jeux d'argent simulés, achats… Un thème casino ou « gratter pour gagner » relève la classification et ferme la porte aux plus jeunes. |
| **Public cible** | tranches d'âge visées. **Choisir 18+ ou 13+ uniquement** (voir encadré). |
| **Sécurité des données (Data safety)** | déclarer ce que collectent le jeu **et chaque SDK** : AdMob collecte l'identifiant publicitaire, l'adresse IP (localisation approximative), les interactions avec l'application, les diagnostics. Google publie le détail par SDK ; reprendre aussi celui de chaque réseau de médiation. Données chiffrées en transit : oui. Suppression des données : expliquer comment (ou « aucune donnée de compte »). |
| Identifiant publicitaire | oui, pour la publicité |
| Accès à l'application | pas de compte requis (sinon fournir un compte de test) |
| Appli d'actualités, santé, finances… | non |

### Public cible et enfants : ne pas viser les moins de 13 ans

Si le public cible inclut des enfants, le jeu tombe sous le programme **Familles** de Google Play :

- seuls les SDK publicitaires **autocertifiés Familles** sont permis, sans pubs personnalisées ni remarketing (revenus par pub bien plus bas) ;
- pubs fermables après **5 secondes** au plus, y compris les pubs récompensées ; pas d'interstitiel au lancement ; pas de bannière sur un écran avec plusieurs pubs ;
- interdiction des « tactiques choquantes ou émotionnellement manipulatrices pour encourager le visionnage de pubs » : la plupart des leviers de `docs/strategies-pub.md` deviennent interdits ;
- pas de jeu d'argent réel ou simulé.

**Décision recommandée** : public cible **13 ans et plus** (ou 18+), style graphique qui n'attire pas spécifiquement les enfants (pas de mascotte enfantine, pas de mots « kids » dans la fiche). Google juge aussi le public réel d'après l'apparence du jeu : un jeu qui « a l'air » pour enfants peut être reclassé d'office.

## 7. Test fermé obligatoire (comptes personnels créés après le 13 novembre 2023)

- **Au moins 12 testeurs inscrits (*opted-in*) en continu pendant au moins 14 jours** sur une piste de test fermé. Un testeur qui se désinscrit avant 14 jours ne compte plus ; s'il se réinscrit, ses 14 jours repartent de zéro.
- Les testeurs ont besoin d'un compte Google et d'un téléphone Android ; on les invite par liste d'e-mails ou par groupe Google, ils acceptent via un lien, puis installent depuis le Play Store.
- **L'engagement compte** : Google regarde si les testeurs utilisent vraiment l'application. Leur demander de jouer quelques minutes plusieurs fois, et de donner un retour (mise à jour pendant le test = bon signe).
- Pendant ce test, garder les **pubs de test** (ou des vraies pubs sans jamais cliquer) : les testeurs sont des proches, leurs clics risquent d'être vus comme du trafic invalide.
- **Ensuite** : Play Console → Tableau de bord → « Demander l'accès à la production ». Questionnaire en trois parties : le test fermé (recrutement, engagement, retours reçus), le jeu (public, intérêt, installations estimées la première année), la préparation (changements faits après le test). Examen en général **7 jours ou moins**. Un refus pour engagement insuffisant oblige à prolonger le test.
- Le test interne (jusqu'à 100 testeurs, sans examen) reste disponible à tout moment pour les essais rapides ; il ne compte pas pour la règle des 12 testeurs.

**Action pour Stelio, dès maintenant** : réunir une liste de 15 à 20 personnes (marge pour les désistements) avec un téléphone Android et une adresse Gmail. Les services payants de « testeurs » existent mais ne sont pas recommandés (engagement faible, risque pour le compte).

## 8. Examen, sortie et après

- Premier examen d'une application : souvent quelques jours (jusqu'à 7 ou plus pour un nouveau compte).
- **Déploiement progressif** possible (5 %, 20 %, 100 %) : utile pour vérifier les plantages et le rendement des pubs avant tout le monde.
- **Android vitals** (Play Console) : taux de plantage et de « l'application ne répond pas » (ANR). Au-delà des seuils de Google (≈ 1,09 % de plantages, 0,47 % d'ANR), la visibilité baisse. Un SDK pub mal intégré est une cause fréquente d'ANR : initialiser les pubs hors du fil principal quand le plugin le permet.
- **Politiques** : toute infraction (pubs trompeuses, interstitiels inattendus, clics accidentels) peut mener à la suppression du jeu et, en cas de récidive, à la **fermeture du compte développeur** (et de tout compte lié). Liste détaillée dans `docs/strategies-pub.md`.
- **Mises à jour obligatoires** : niveau d'API cible chaque année (fin août), SDK pub à jour (Google déprécie les vieilles versions), déclaration Data safety à jour à chaque nouveau SDK.

## 9. Coûts de départ

| Poste | Coût |
|---|---|
| Compte Google Play | 25 $ une fois |
| AdMob, UMP, médiation | gratuit (commission prélevée sur les revenus) |
| Nom de domaine | ≈ 10 €/an |
| Hébergement du site | gratuit (GitHub Pages, Netlify) |
| D-U-N-S (si organisation) | gratuit |
| Téléphone Android de test | celui de Stelio |

## Sources

- Test fermé des nouveaux comptes personnels : https://support.google.com/googleplay/android-developer/answer/14151465
- Création du compte, frais, identité : https://support.google.com/googleplay/android-developer/answer/6112435
- Types de comptes : https://support.google.com/googleplay/android-developer/answer/13634885
- Création d'application, App Bundle, Play App Signing, limites de la fiche : https://support.google.com/googleplay/android-developer/answer/9859152
- Niveau d'API cible : https://developer.android.com/google/play/requirements/target-sdk (lu le 8 novembre 2026)
- Programme Familles : https://support.google.com/googleplay/android-developer/answer/9893335
- Règles sur les annonces de Google Play : https://support.google.com/googleplay/android-developer/answer/9857753
- Vérification des développeurs Android 2026 (article tiers) : https://stora.sh/blog/2026-05-12-google-play-developer-verification-2026-complete-indie-guide
- Consentement avec Capacitor (article tiers, 1er octobre 2026) : https://capgo.app/blog/admob-gdpr-consent-capacitor/
