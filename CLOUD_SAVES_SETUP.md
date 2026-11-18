# NEXUS — configuration des sauvegardes cloud

Le jeu utilise Supabase. Le projet est déjà renseigné dans `cloud-config.js` ; les joueurs n'ont pas à créer leur propre projet ni à saisir de clé.

## 1. Vérifier le projet existant
Ouvrir le projet NEXUS dans Supabase :
https://supabase.com/dashboard/project/yzmgbltymdyubxnbkcse

La clé enregistrée dans le dépôt est une clé publique *publishable*. C'est normal qu'elle soit visible dans le navigateur. Ne jamais mettre une clé `sb_secret_` ou `service_role` dans le code du jeu.

## 2. Créer / sécuriser la table de sauvegardes
Dans Supabase > SQL Editor :
1. Ouvrir le fichier `SUPABASE_SETUP.sql` du dépôt GitHub.
2. Copier tout son contenu dans une nouvelle requête SQL.
3. Exécuter la requête.

Le script active RLS, retire les droits du rôle public et du rôle `anon`, puis accorde uniquement les opérations nécessaires au rôle `authenticated`. Les policies limitent chaque joueur à la ligne dont le `user_id` correspond à son propre identifiant.

## 3. Activer les méthodes de connexion
Dans Authentication > Sign In / Providers :
- Activer Email pour la création de compte et la connexion par e-mail/mot de passe.
- Activer Anonymous Sign-Ins pour le mode invité.
- Activer le *manual identity linking* pour permettre l'association d'une identité à un compte invité.

### Google (facultatif)
Pour Google, il faut aussi créer/configurer les identifiants OAuth dans le compte Google Cloud du propriétaire du projet :
1. Activer le fournisseur Google dans Supabase et renseigner les identifiants OAuth.
2. Copier l'URL de callback OAuth affichée par Supabase et la déclarer comme URI de redirection autorisée dans le client OAuth Google.
3. Dans Supabase > Authentication > URL Configuration, définir la Site URL sur :
   `https://noonoo-hash.github.io/nexus-game-the-real/`
4. Ajouter cette même URL complète à la liste des Redirect URLs autorisées. Le jeu renvoie vers l'URL courante de la page ; elle doit donc être autorisée.

Ne pas confondre l'URI de callback Google (qui pointe vers Supabase) avec l'URL de retour du joueur après connexion (qui pointe vers le jeu).

## 4. Configuration du jeu
La configuration publique du projet est déjà intégrée dans `cloud-config.js`. Aucune modification supplémentaire n'est nécessaire tant que l'URL du projet et sa clé publique restent valides.

Le fichier est public par conception : la sécurité repose sur les règles RLS et les droits SQL, pas sur le secret de la clé publishable.

## Fonctionnement
- La sauvegarde locale reste active.
- Une sauvegarde cloud est envoyée après les sauvegardes automatiques locales.
- Connexion prévue par e-mail/mot de passe, Google ou compte invité anonyme.
- Un compte invité doit être associé à une identité récupérable avant de changer/perdre son navigateur.
- Sur un nouvel appareil sans sauvegarde locale, le jeu restaure la sauvegarde cloud du compte connecté.
- Si une sauvegarde locale existe, le jeu conserve la plus récente selon son horodatage.

## 5. Test de validation
Après les réglages ci-dessus :
1. Ouvrir https://noonoo-hash.github.io/nexus-game-the-real/
2. Dans le panneau « Sauvegarde cloud & comptes », lancer « Jouer en invité » ou créer un compte e-mail.
3. Faire progresser la partie et attendre le message « Sauvegarde cloud synchronisée ».
4. Dans Supabase > Table Editor > `player_saves`, vérifier qu'une ligne est créée.
5. Tester la connexion au même compte dans un autre navigateur/appareil pour vérifier la restauration.

Ne pas utiliser un compte invité comme unique moyen de récupération : sa session peut être perdue si les données du navigateur sont effacées ou si l'utilisateur change d'appareil.

## Limites et précautions
- Le cloud n'est réellement opérationnel qu'après exécution du SQL et activation des fournisseurs nécessaires dans le tableau de bord.
- Les comptes invités anonymes ne sont pas récupérables après perte de leur session, sauf association préalable à une identité.
- Le jeu reste jouable localement sans connexion ; la synchronisation nécessite Internet.
- Pour un lancement public, prévoir aussi des limites de débit / CAPTCHA et une politique de confidentialité.
- Si le même compte est utilisé simultanément sur plusieurs appareils, la dernière sauvegarde envoyée peut remplacer l'autre : il faudra alors ajouter une vraie stratégie de résolution de conflits.
