# NEXUS — configuration des sauvegardes cloud

Le jeu utilise Supabase. Une seule instance Supabase est partagée par tous les joueurs ; ils n'ont pas à créer leur propre projet.

## 1. Créer le projet Supabase
1. Créer un projet sur https://supabase.com.
2. Dans Project Settings > API, copier le Project URL et la clé publique (publishable key ou anon key).
3. Ne jamais utiliser la clé `service_role` dans le navigateur.

## 2. Créer la table et sécuriser les données
Dans Supabase > SQL Editor, exécuter tout le contenu de `SUPABASE_SETUP.sql`.
Les règles RLS limitent chaque joueur à sa propre sauvegarde.

## 3. Activer les méthodes de connexion
- Authentication > Sign In / Providers : activer Email.
- Authentication > Sign In / Providers : activer Anonymous Sign-Ins pour le mode invité.
- Pour Google : activer Google et configurer les identifiants OAuth côté Google Cloud. Ajouter l'URL de redirection fournie par Supabase dans les URI de redirection autorisées Google et dans Supabase > Authentication > URL Configuration. Ajouter aussi `https://noonoo-hash.github.io` aux URL autorisées.

## 4. Brancher le projet au jeu
Modifier `cloud-config.js` une seule fois :
```js
window.NEXUS_SUPABASE_CONFIG = {
  url: "https://VOTRE-PROJET.supabase.co",
  anonKey: "VOTRE-CLE-PUBLIQUE"
};
```
Publier le changement sur GitHub. Tous les joueurs utiliseront alors automatiquement le même backend ; ils n'auront pas à saisir ces informations.

Les champs de configuration visibles dans Options sont un mécanisme de test/local de secours. La configuration partagée du fichier `cloud-config.js` est prioritaire.

## Fonctionnement
- Sauvegarde locale conservée.
- Synchronisation cloud après les sauvegardes automatiques locales.
- Connexion par e-mail/mot de passe, Google ou compte invité anonyme.
- Les comptes invités doivent être associés à une identité récupérable avant de changer/perdre leur navigateur.
- Lors d'une première connexion sur un nouvel appareil, la sauvegarde cloud est restaurée si aucune sauvegarde locale n'existe.
- Les sauvegardes cloud sont protégées par RLS.

## Limites et précautions
- Le cloud n'est pas opérationnel tant que le projet Supabase n'est pas créé, configuré et renseigné dans `cloud-config.js`.
- Les comptes invités anonymes ne sont pas récupérables après perte de leur session, sauf association préalable à un e-mail ou à Google.
- Le jeu reste jouable localement sans connexion ; la synchronisation nécessite Internet.
- Pour un jeu public, prévoir des limites de débit, une politique de confidentialité et un mécanisme de résolution de conflits si un même compte joue simultanément sur plusieurs appareils.
