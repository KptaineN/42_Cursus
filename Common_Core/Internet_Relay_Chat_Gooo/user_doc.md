# user8doc - Guide d'utilisation du serveur IRC

Ce document explique comment utiliser le serveur IRC du projet, comment s'y connecter avec des clients IRC classiques ou avec `nc`, puis comment fonctionne la phase apres connexion : inscription, salons, operateur et modes.

Le but est de se rapprocher du comportement attendu dans un projet `ft_irc` de 42.

## 1. Vue d'ensemble

Un serveur IRC fonctionne en TCP. Le client ouvre une connexion au serveur, puis envoie des commandes texte terminees par `\r\n`.

Le serveur lit les commandes une par une, les interprete, puis repond avec des numeriques IRC ou des messages textes selon la commande.

Le flux normal est le suivant :

1. Connexion TCP au serveur.
2. Authentification avec `PASS`.
3. Choix du pseudo avec `NICK`.
4. Declaration de l'utilisateur avec `USER`.
5. Reception du message de bienvenue et du MOTD.
6. Rejoindre un channel avec `JOIN`.
7. Echanger des messages avec `PRIVMSG`.

## 2. Demarrer le serveur

L'executable attendu est :

```bash
./ircserv <port> <password>
```

Exemple :

```bash
./ircserv 6667 secret
```

`<port>` est le port d'ecoute TCP.
`<password>` est le mot de passe a fournir avec la commande `PASS`.

## 3. Connexion avec un client IRC existant

Tu peux utiliser un client IRC classique comme `irssi`, `weechat` ou `HexChat`.

### 3.1 Avec irssi

```bash
irssi
/connect -password secret localhost 6667
```

Si le client ne renseigne pas le mot de passe a la connexion, tu peux le fournir ensuite dans la fenetre du serveur :

```text
/quote PASS secret
/nick monPseudo
/user monUser 0 * :Mon nom reel
```

### 3.2 Avec weechat

```bash
/server add monserveur localhost/6667 -password=secret
/connect monserveur
```

Si besoin, envoie ensuite :

```text
/quote PASS secret
/nick monPseudo
/user monUser 0 * :Mon nom reel
```

### 3.3 Avec HexChat

Dans la configuration du serveur :

```text
Server: localhost/6667
Password: secret
Nick name: monPseudo
Username: monUser
Real name: Mon nom reel
```

## 4. Connexion avec `nc`

`nc` est pratique pour tester manuellement le serveur IRC. Comme IRC utilise `\r\n`, il vaut mieux activer l'envoi en mode CRLF si ton `nc` le permet.

Exemple :

```bash
nc -C localhost 6667
```

Si `-C` n'est pas disponible sur ta version de `nc`, il faut envoyer les fins de ligne manuellement selon l'outil utilise, mais le principe reste identique.

Une fois connecte, saisis les commandes suivantes :

```text
PASS secret
NICK monPseudo
USER monUser 0 * :Mon nom reel
```

## 5. Etapes apres connexion

### 5.1 Registration

Un client IRC n'est pas vraiment pret tant que les trois informations principales n'ont pas ete fournies :

```text
PASS <password>
NICK <nickname>
USER <username> 0 * :<realname>
```

Le serveur considere en general qu'un client est enregistre quand :

1. Le mot de passe est correct.
2. Un nickname valide a ete choisi.
3. La commande `USER` a ete envoyee avec les informations attendues.

Quand l'inscription est valide, le serveur peut envoyer :

```text
001 :Welcome to ft_irc <nickname>
```

Puis le MOTD, en general :

```text
375 :Message of the Day
372 :<ligne du MOTD>
376 :End of /MOTD command
```

### 5.2 Erreurs de base au moment du register

Quelques cas classiques :

```text
461 :Not enough parameters
462 :You may not reregister
464 :Password incorrect
431 :No nickname given
433 :Nickname is already in use
451 :You have not registered
```

Ces reponses servent a indiquer pourquoi la connexion n'est pas encore acceptee ou pourquoi une commande est refusee.

## 6. Rejoindre un channel

Une fois enregistre, tu peux rejoindre un salon avec :

```text
JOIN #general
```

Exemple avec cle de channel :

```text
JOIN #dev secretkey
```

Le channel devient alors un espace de discussion partage entre tous les membres presents.

### 6.1 Fonctionnement attendu d'un channel

Un channel IRC contient en general :

1. Une liste de membres.
2. Une liste d'operateurs.
3. Un topic.
4. Des modes actifs.

Un serveur IRC 42 doit normalement gerer au minimum :

```text
+i : invite only
+t : topic reserve aux operateurs
+k : cle de channel
+o : operateur de channel
+l : limite d'utilisateurs
```

## 7. Envoyer des messages

### 7.1 Message prive

Pour parler a un utilisateur :

```text
PRIVMSG pseudoCible :salut
```

Le serveur envoie alors le message au client cible.

### 7.2 Message de channel

Pour parler dans un channel :

```text
PRIVMSG #general :bonjour tout le monde
```

Le serveur doit alors retransmettre le message a tous les membres du channel.

## 8. Devenir operateur

Dans un projet IRC 42, un operateur de channel est un membre qui a plus de droits que les autres. Il peut en general :

1. Changer le topic si le mode `+t` est actif.
2. Donner ou retirer le statut operateur avec `MODE +o` / `MODE -o`.
3. Kicker un utilisateur avec `KICK`.
4. Inviter un utilisateur si le channel est `+i`.
5. Modifier certains modes du channel.

### 8.1 Comment devenir operateur

Le plus courant est :

1. Creer le channel en premier.
2. Rejoindre le channel.
3. Etre initialement operateur du channel si tu es le createur.

Ensuite, un operateur deja present peut donner ce statut a quelqu'un d'autre :

```text
MODE #general +o pseudoCible
```

Pour retirer ce statut :

```text
MODE #general -o pseudoCible
```

Selon l'implementation du serveur, le createur du channel peut aussi etre considerer comme operateur par defaut.

## 9. La commande MODE

`MODE` est une des commandes centrales d'IRC. Elle sert a lire ou modifier les modes d'un channel.

Syntaxe generale :

```text
MODE <channel> <flags> [parametres]
```

### 9.1 `+i` / `-i`

Mode invite only.

```text
MODE #general +i
```

Quand `+i` est actif, seuls les utilisateurs invites peuvent rejoindre le channel.

```text
MODE #general -i
```

Le channel redevient ouvert a tous, selon les autres restrictions.

### 9.2 `+t` / `-t`

Mode topic reserve aux operateurs.

```text
MODE #general +t
```

Quand `+t` est actif, seul un operateur du channel peut modifier le topic.

```text
MODE #general -t
```

Le topic peut alors etre modifie par les membres autorises par le serveur.

### 9.3 `+k` / `-k`

Mode cle de channel.

```text
MODE #general +k secretkey
```

Le channel exige alors cette cle pour rejoindre le salon.

```text
MODE #general -k
```

La cle est retiree et le channel n'a plus de mot de passe.

### 9.4 `+o` / `-o`

Mode operateur de channel.

```text
MODE #general +o pseudoCible
```

Le serveur donne les droits operateur a `pseudoCible`.

```text
MODE #general -o pseudoCible
```

Le serveur retire les droits operateur.

### 9.5 `+l` / `-l`

Mode limite de membres.

```text
MODE #general +l 10
```

Le channel accepte au maximum 10 utilisateurs.

```text
MODE #general -l
```

La limite est supprimee.

## 10. Commandes utiles apres connexion

Voici les commandes que l'on utilise le plus dans un serveur IRC 42 :

```text
PASS <password>
NICK <nickname>
USER <username> 0 * :<realname>
JOIN <channel> [cle]
PRIVMSG <user|channel> :message
MODE <channel> <flags> [parametres]
KICK <channel> <user> [:raison]
INVITE <user> <channel>
TOPIC <channel> [:nouveau topic]
QUIT [:message]
PING <token>
```

## 11. Exemple de session complete

```text
PASS secret
NICK alice
USER alice 0 * :Alice Liddell

JOIN #general
PRIVMSG #general :bonjour tout le monde
PRIVMSG bob :salut bob

MODE #general +i
MODE #general +t
MODE #general +k cle123
MODE #general +l 15
MODE #general +o bob
```

## 12. Ce qui est deja present dans ce sous-projet

Dans la version actuelle du sous-projet `Quentin_part/ILLEGIT`, on trouve deja :

```text
PASS
NICK
USER
PING
PRIVMSG
QUIT
WHOIS
HELP
MOTD
```

Le document ci-dessus decrit aussi le comportement IRC attendu pour les commandes de channel et d'operateur qui peuvent etre ajoutees ensuite.

## 13. A retenir

1. Toujours envoyer `PASS`, `NICK` et `USER` avant de faire des commandes avancees.
2. Les commandes IRC doivent se terminer par `\r\n`.
3. `JOIN` permet d'entrer dans un channel.
4. `PRIVMSG` sert a parler a un utilisateur ou a un channel.
5. `MODE` sert a gerer les droits et restrictions du channel.
6. Les operateurs de channel controlent les permissions du salon.
