# Sons, bruitages et musique

Méthode suivie sur *River Cleaner: India* (G19 à G22, G28, G69) : 23 bruitages, 3 ambiances et une dizaine de musiques, choisis ou générés, puis réglés à l'oreille par le joueur. Claude n'entend rien : il prépare, traite, intègre et vérifie ce qui est joué ; le joueur juge.

## 1. Faire la liste avant de chercher

Dans `docs/conception-du-jeu.md` (section son), une ligne par son, groupées :

- **cœur de la boucle** (ce que le joueur fait cent fois : ramasser, lancer, réussir, rater) : à soigner en premier, courts, gratifiants sans fatiguer ;
- **monde** (pas, chocs, éclaboussures), joués en 3D là où ils arrivent ;
- **interface** (survol, clic, ouverture, fermeture, achat, refus) : discrets ;
- **ambiances** en boucle (30 s suffisent) ;
- **musiques** : combien de morceaux, quel style, et les silences entre eux (une musique sans arrêt lasse).

Pour chaque son : l'événement du jeu qui le déclenche (un signal d'`Events`), sa durée, s'il varie (hauteur, plusieurs prises).

## 2. Trouver ou générer

**Banques libres d'abord** quand le son est banal : Kenney (CC0), OpenGameArt (licence par asset), Kevin MacLeod (CC BY, crédit obligatoire). Freesound et Pixabay étaient bloqués depuis la session : le joueur télécharge et dépose les fichiers si besoin.

**Génération (ElevenLabs)** pour un univers cohérent ou un son introuvable :

1. Une clé d'API du joueur, dans une **variable d'environnement** de l'environnement cloud (`ELEVENLABS_API_KEY`), jamais dans le dépôt ni dans la conversation.
2. Les prompts dans `tools/assets/audio_prompts.json` (versionnés : un son se refait ou se varie).
3. `python3 -I tools/assets/generate_audio.py sfx /tmp/sons [nom…]`, puis `music`. Les MP3 bruts restent **hors du dépôt**.
4. Coûts constatés (forfait Starter, 40 000 crédits par mois) : environ 10 crédits par seconde de bruitage ; une musique de 2 min coûte bien plus (comparer `generate_audio.py credits` avant et après, le compteur a quelques minutes de retard). Deux requêtes à la fois au plus.

**Écrire un prompt de bruitage** (ce qui a marché) :

- décrire l'objet, la matière et le geste : « Quick grab of a light plastic bottle, short soft plastic crinkle » ;
- la prise de son : « close-up, dry studio, no reverb » ;
- ce qu'on ne veut pas : « no music, no voices », « no metal, no clink, no high frequencies » ;
- une durée courte (0,5 s) pour un son d'action, `loop` pour une ambiance ;
- un son raté (trop faible, deux sons en un) : le refaire avec `influence` à 0,8 (suit mieux le prompt).
- **Les pas** : générés un par un, ils sonnaient « comme des frappes de batterie ». Mieux : générer un enregistrement de marche de 5 s (« field recording of a person walking… ») et découper chaque pas à son attaque.

**Écrire un prompt de musique** : genre précis et tempo (« Indian lo-fi hip hop, 85 BPM »), instruments, ambiance, « no vocals ». Des prompts trop proches donnent des morceaux trop proches (« musique de méditation ») : varier les genres d'un morceau à l'autre.

## 3. Faire choisir le joueur

Deux ou trois candidats par son sur une **page d'écoute** (un artifact avec un lecteur par candidat et une case à cocher, choix enregistrés dans sa base) : le joueur écoute et coche, Claude relit les choix. Chaque retour (« trop strident », « on dirait du sable ») devient une consigne du prochain jet, notée dans le ticket avec ses mots.

## 4. Traiter les fichiers

`tools/assets/process_audio.sh <sfx|ambience|music> <brut> assets/sounds/<nom>.ogg [passe-bas]` :

- **sfx** : mono, silences coupés au début et à la fin, fondu de sortie de 30 ms, crête à -1,5 dBFS ;
- **ambience** : stéréo, gardée entière (boucle), volume perçu -28 LUFS ;
- **music** : stéréo, fondu de sortie de 4 s, -16 LUFS ;
- **passe-bas** (ex. `5000`) pour un son jugé strident ; baisser de 2 à 4 dB s'il reste trop présent.

Puis l'écouter… par le joueur. Claude peut vérifier la durée, la crête (`ffmpeg -i x.ogg -af astats -f null -`) et le centre spectral pour comparer deux sons (un pas « boueux » plus grave qu'un pas « frais »).

## 5. Intégrer dans Godot

- **Bus** : `Music`, `Effects`, `Ambience` (qui passe par `Effects`) dans `default_bus_layout.tres`.
- **Banque en données** : une ressource `SoundDef` par son (flux, bus, volume, polyphonie, positionnel ou non) dans une `SoundBank` ; les variations par un `AudioStreamRandomizer` (hauteur et volume aléatoires, plusieurs prises).
- **Un autoload `Audio`** écoute `Events` et joue le son de l'événement ; les scènes ne jouent rien elles-mêmes, sauf l'interface (`Audio.play`). Un son du monde se joue en 3D à sa position (`AudioStreamPlayer3D` déplacé).
- **Musique** : une `MusicSet` (morceaux avec titre et créateur), un ordre choisi par une classe pure (jamais deux fois le même d'affilée, silences d'ambiance entre deux morceaux), en sourdine quand le jeu est en pause.
- **Volumes** du joueur dans `AudioSettings` (déjà dans le modèle), appliqués aux bus.
- Le code de River Cleaner (`game/autoload/audio.gd`, `game/data/sound_*.gd`, `music_*.gd`, `game/core/music_schedule.gd`) est le point de départ.

## 6. Tester

- Sans carte son (session, CI), Godot passe sur le pilote factice : un test vérifie **ce qui est joué** (un signal `Audio.played(nom)`), jamais ce qu'on entend.
- Un son de test qui doit encore jouer à l'assertion dure plus longtemps que le test (20 s), sinon le test échoue sur une machine lente.
- À la fermeture, arrêter les sons puis attendre un mixage (100 ms), sinon « resources still in use at exit » (`docs/pitfalls/godot-ligne-de-commande-et-export.md`).

## 7. Licences

Une ligne dans `assets/LICENSES.md` par fichier ou famille : source, auteur, licence, texte de crédit exigé, et pour l'IA : l'outil, le forfait qui donne l'usage commercial, la date et les retouches `ffmpeg`. À déclarer dans le questionnaire de contenu de Steamworks.
