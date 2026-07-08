# Internet-Relay_tchat — Récap & notions à maîtriser

> Document de suivi personnel pour  **ft_irc / Internet Relay Chat**.  
> Objectif : garder une vision claire de ce qui a déjà été fait, comprendre les notions techniques, puis avancer proprement jusqu’à un serveur IRC complet

---

## 1. Objectif du sujet

Le projet **ft_irc** consiste à créer son propre **serveur IRC** en **C++98**.

produire un exécutable :

```bash
./ircserv <port> <password>
```

Avec :

```txt
<port>      = port TCP sur lequel ton serveur écoute les connexions entrantes
<password>  = mot de passe que les clients IRC devront fournir avec PASS
```

Sujet contraintes :

```txt
- Le programme doit s'appeler ircserv.
- Le projet doit être en C++98.
- Compilation avec -Wall -Wextra -Werror.
- Makefile obligatoire avec au minimum : NAME, all, clean, fclean, re.
- Tu ne dois pas coder de client IRC.
- Tu ne dois pas coder de communication serveur-à-serveur.
- Le serveur doit gérer plusieurs clients simultanément.
- Pas de fork.
- Tous les fd doivent être non-bloquants.
- Un seul poll() ou équivalent doit gérer les lectures, écritures, connexions, etc.
- Le serveur doit être testable avec un vrai client IRC de référence.
```

Fonctionnalités obligatoires :

```txt
- Authentification avec PASS
- Choix d'un nickname avec NICK
- Déclaration utilisateur avec USER
- Connexion avec un vrai client IRC
- JOIN un channel
- Envoyer et recevoir des messages privés ou de channel avec PRIVMSG
- Forward des messages envoyés dans un channel à tous les autres membres
- Gestion des utilisateurs normaux et opérateurs
- Commandes opérateur : KICK, INVITE, TOPIC, MODE
```

Modes obligatoires du channel :

```txt
+i : activer/désactiver le mode invitation only
+t : restreindre le changement de topic aux opérateurs
+k : ajouter/retirer une clé, donc un mot de passe de channel
+o : donner/retirer les droits opérateur à un utilisateur
+l : ajouter/retirer une limite d'utilisateurs
```

---

## 2. Résumé ultra simple du fonctionnement d'IRC

IRC signifie **Internet Relay Chat**.

C’est un protocole de discussion en temps réel, principalement textuel. Un client IRC, comme `irssi`, `WeeChat` ou `HexChat`, se connecte à un serveur IRC. Ensuite, l’utilisateur peut rejoindre des salons, appelés **channels**, ou envoyer des messages privés.

Schéma mental :

```txt
Client IRC
   |
   | TCP
   v
Serveur IRC
   |
   +-- Client A
   +-- Client B
   +-- Client C
   |
   +-- #general
   +-- #dev
   +-- #random
```

Exemple de session IRC minimale :

```txt
PASS secret
NICK noe
USER noe 0 * :Noe Kiefer
JOIN #test
PRIVMSG #test :salut tout le monde
```

Le serveur reçoit des lignes texte, les parse, puis déclenche les bonnes actions.

---

### 3.1 `main.cpp`

Déjà fait :

```txt
[x] Vérification du nombre d'arguments
[x] Parsing du port
[x] Vérification que le port est numérique
[x] Vérification que le port est entre 1 et 65535
[x] Vérification que le password n'est pas vide
[x] Création d'un objet Server(port, password)
[x] Lancement de server.run()
[x] Gestion globale des exceptions avec try/catch
```

`main.cpp` : prépare le serveur, vérifie les arguments, puis laisse `Server` gérer le réseau.

```txt
main.cpp = point d'entrée
Server = moteur réseau
Client = représentation d'une connexion TCP
```

---

### 3.2 `Server`

Déjà fait :

```txt
[x] Création du socket serveur avec socket(AF_INET, SOCK_STREAM, 0)
[x] Configuration avec setsockopt(SO_REUSEADDR)
[x] Préparation d'une adresse IPv4 avec sockaddr_in
[x] Association du socket à un port avec bind()
[x] Passage en mode écoute avec listen()
[x] Passage du socket serveur en non-bloquant avec fcntl(O_NONBLOCK)
[x] Ajout du socket serveur dans le vector<pollfd>
[x] Boucle principale avec poll()
[x] Détection des connexions entrantes
[x] accept() des nouveaux clients
[x] Passage des clients en non-bloquant
[x] Ajout des clients dans poll()
[x] Stockage des clients dans std::map<int, Client>
[x] recv() des données envoyées par un client
[x] Ajout des données reçues dans le buffer du Client
[x] Extraction des commandes complètes
[x] Détection de déconnexion client
[x] close() du fd client
[x] Suppression du client de _clients
[x] Suppression du fd de _fds
```

Le serveur fait déjà :

```txt
socket()
setsockopt()
fcntl(non-blocking)
bind()
listen()
poll()
accept()
recv()
close()
```

C’est le socle de tout le projet.

---

### 3.3 `Client`

Déjà fait :

```txt
[x] Stocker le fd du client
[x] Stocker un buffer d'entrée
[x] Ajouter des données brutes reçues avec appendBuffer()
[x] Savoir si une commande complète est présente avec hasCommand()
[x] Extraire une ligne complète avec popCommand()
[x] Retirer le \r final si la ligne vient d'un vrai client IRC en \r\n
```

C’est très important, car TCP ne garantit pas qu’une commande IRC arrive d’un seul coup.

Exemple :

```txt
NICK noe\r\n
```

peut arriver comme :

```txt
NI
CK n
oe\r\n
```

buffer sert à reconstruire la vraie ligne complète avant de la parser.
reconstruit le flux tcp

---

### 3.4 `debug.hpp`

Déjà fait :

```txt
[x] Macro DBG(msg)
[x] DEBUG désactivé par défaut
[x] Possibilité de compiler avec -DDEBUG=1
[x] Affichage debug coloré dans std::cerr
```

Utilité :

```txt
- Voir ce que fait le serveur
- Suivre les connexions
- Suivre les commandes reçues
- Déboguer sans polluer le code avec des std::cerr partout
```

---

### 3.5 `Makefile`

Déjà commencé :

```txt
[x] NAME = ircserv
[x] CXX = c++
[x] CXXFLAGS avec -Wall -Wextra -Werror -std=c++98
[x] Règles all / clean / fclean / re
[x] Cible release
[x] Cible debug avec -DDEBUG=1
```

---

## 4. pour l intsant

```txt
serveur TCP multi-clients non-bloquant de debug
```
pas complet

Il accepte des clients, reçoit des lignes et les affiche, mais il ne comprend pas encore réellement les commandes IRC.

Schéma actuel :

```txt
Client TCP
   |
   | envoie du texte
   v
Server
   |
   | recv()
   v
Client::_buffer
   |
   | popCommand()
   v
handleCommand()
   |
   | affiche la ligne
   v
stdout debug
```

Schéma cible :

```txt
Client IRC
   |
   | PASS / NICK / USER / JOIN / PRIVMSG
   v
Server
   |
   | recv()
   v
Client::_inBuffer
   |
   | popCommand()
   v
IrcParser
   |
   | IrcMessage { command, params }
   v
CommandDispatcher
   |
   | handlePass / handleNick / handleJoin / handlePrivmsg
   v
Server state : clients + channels
   |
   | queueMessage()
   v
Client::_outBuffer
   |
   | POLLOUT + send()
   v
Client IRC reçoit une réponse valide
```

---

## 5. Les notions réseau à maîtriser

### 5.1 File descriptor, ou fd

Un `fd` est un nombre entier donné par le système pour représenter une ressource ouverte.

Les serveurs sont identifiés de manière unique par leur nom, qui a une longueur maximale.
   longueur de soixante-trois (63) caractères

```txt
_serverFd = socket serveur qui écoute les connexions
clientFd  = socket connecté à un client précis
```

Ton serveur ne manipule pas directement “un utilisateur”. Il manipule des fd.

Exemple :

```txt
fd 3 = socket serveur
fd 4 = client noe
fd 5 = client bob
fd 6 = client alice
```

---

### 5.2 Socket serveur vs socket client

Le socket serveur sert uniquement à écouter :

```txt
socket()
bind()
listen()
accept()
```

Il ne sert pas à lire les messages IRC.

Quand `accept()` réussit, il crée un nouveau socket client :

```txt
serverFd
   |
   | accept()
   v
clientFd
```

Le socket client sert à communiquer :

```txt
recv()
send()
close()
```

---

### 5.3 `socket()`

`socket()` crée un point de communication réseau.

Dans ton code :

```cpp
_serverFd = socket(AF_INET, SOCK_STREAM, 0);
```

Signification :

```txt
AF_INET     = IPv4
SOCK_STREAM = TCP
0           = protocole par défaut pour TCP
```

---

### 5.4 `setsockopt()

On utilise :

```cpp
setsockopt(_serverFd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
```

Utilité :

```txt
Permet de relancer rapidement ton serveur sur le même port après l'avoir arrêté.
```

Sans ça, on peut avoir :

```txt
bind() failed: Address already in use
```

---

### 5.5 `bind()`

`bind()` attache ton socket serveur à une adresse IP et à un port.

Dans ton code :

```cpp
addr.sin_family = AF_INET;
addr.sin_addr.s_addr = htonl(INADDR_ANY);
addr.sin_port = htons(_port);
bind(_serverFd, reinterpret_cast<struct sockaddr *>(&addr), sizeof(addr));
```

Signification :

```txt
AF_INET       = IPv4
INADDR_ANY    = accepte les connexions sur toutes les interfaces réseau
htons(_port)  = convertit le port dans l'ordre réseau
```

---

### 5.6 `listen()`

`listen()` transforme le socket en socket d'écoute.

Avant `listen()` :

```txt
le socket existe, mais n'accepte pas encore de connexion
```

Après `listen()` :

```txt
le socket peut recevoir des connexions entrantes
```

---

### 5.7 `fcntl(O_NONBLOCK)`

mettre fd en non-bloquant :

```cpp
fcntl(fd, F_SETFL, O_NONBLOCK);
```

Pourquoi ?

Parce que le sujet interdit les I/O bloquantes.

Sans non-bloquant :

```txt
recv() peut attendre indéfiniment
accept() peut attendre indéfiniment
send() peut bloquer si le buffer système est plein
```

Avec non-bloquant :

```txt
si rien n'est disponible, la fonction retourne directement -1 avec EAGAIN ou EWOULDBLOCK
```

---

### 5.8 `poll()`

`poll()` surveille plusieurs fd à la fois.

Ton vector :

```cpp
std::vector<struct pollfd> _fds;
```

Chaque `pollfd` contient :

```cpp
struct pollfd
{
    int   fd;
    short events;
    short revents;
};
```

Signification :

```txt
fd      = le fd à surveiller
events  = ce qu'on veut surveiller
revents = ce qui est réellement arrivé
```

Exemples :

```txt
POLLIN  = il y a quelque chose à lire
POLLOUT = le fd est prêt pour écrire
POLLERR = erreur
POLLHUP = connexion fermée
POLLNVAL = fd invalide
```

Logique de ton serveur :

```txt
poll(_fds)
   |
   +-- si événement sur _serverFd : acceptNewClient()
   |
   +-- si événement POLLIN sur clientFd : receiveFromClient()
   |
   +-- plus tard, si POLLOUT sur clientFd : flushClientOutput()
```

---

### 5.9 `accept()`

`accept()` accepte une nouvelle connexion.

Important :

```txt
accept() ne lit pas de message IRC.
accept() crée seulement un nouveau fd client.
```

Après accept :

```txt
- mettre clientFd en non-bloquant
- l'ajouter à poll()
- créer un Client(clientFd)
- l'ajouter dans _clients
```

---

### 5.10 `recv()`

`recv()` lit des octets depuis un client.

Cas possibles :

```txt
bytes > 0 : données reçues
bytes == 0 : le client a fermé la connexion
bytes < 0 avec EAGAIN/EWOULDBLOCK : rien à lire maintenant
bytes < 0 autre erreur : problème, on déconnecte le client
```


---

### 5.11 `send()`

`send()` envoie des octets à un client.

Point important : `send()` peut envoyer seulement une partie du message.

Exemple :

```txt
Tu veux envoyer 1000 octets.
send() peut en envoyer 300.
Il faut garder les 700 restants pour plus tard.
```

C’est pour ça qu’il faut ajouter un **output buffer** dans `Client`.

---

### 5.12 `close()`

`close(fd)` ferme le fd côté système.

Mais dans ton serveur, fermer un client doit aussi impliquer :

```txt
- close(fd)
- supprimer le Client de _clients
- supprimer le pollfd de _fds
- plus tard : le retirer de tous les channels
- supprimer les channels vides
```

---

## 6. Les notions IRC à maîtriser

### 6.1 IRC est un protocole texte

Une commande IRC est une ligne de texte.

Exemples :

```txt
PASS secret
NICK noe
USER noe 0 * :Noe Kiefer
JOIN #general
PRIVMSG #general :salut tout le monde
```

Les vrais clients IRC terminent normalement les lignes par :

```txt
\r\n
```

C’est-à-dire :

```txt
CRLF = Carriage Return + Line Feed
```

Ton `popCommand()` retire déjà le `\r` final si présent.

---

### 6.2 TCP ne respecte pas les lignes IRC

TCP transporte un flux d’octets. Il ne connaît pas tes commandes.

Donc une commande peut arriver coupée :

```txt
PRIV
MSG #test :salut\r\n
```

Ou plusieurs commandes peuvent arriver ensemble :

```txt
PASS secret\r\nNICK noe\r\nUSER noe 0 * :Noe\r\n
```

C’est la raison du buffer par client.

Logique correcte :

```txt
recv()
   ↓
appendBuffer()
   ↓
tant que buffer contient \n :
   popCommand()
   parse()
   dispatch()
```

---

### 6.3 Format d'un message IRC

Forme générale :

```txt
[:prefix] COMMAND [params] [:trailing]
```

Exemples :

```txt
PASS secret
NICK noe
USER noe 0 * :Noe Kiefer
PRIVMSG #test :salut tout le monde
```

Le `trailing`, c’est le dernier paramètre qui commence par `:`. Il peut contenir des espaces.

Exemple :

```txt
PRIVMSG #test :salut tout le monde
```

Doit devenir :

```txt
command   = PRIVMSG
params[0] = #test
params[1] = salut tout le monde
```

Sans la règle du `:`, mauvaise découpe :

```txt
salut
tout
le
monde
```

Alors que ça doit rester un seul message.

---

### 6.4 Registration IRC

Un client connecté n'est pas automatiquement un utilisateur IRC valide.

Il doit d'abord réussir :

```txt
PASS <password>
NICK <nickname>
USER <username> 0 * :<realname>
```

État mental :

```txt
Connexion TCP acceptée
   ↓
Client non registered
   ↓
PASS correct ?
   ↓
NICK valide ?
   ↓
USER reçu ?
   ↓
Client registered
   ↓
Envoyer 001 RPL_WELCOME
```

Tant que le client n’est pas registered, il ne doit pas pouvoir faire :

```txt
JOIN
PRIVMSG
TOPIC
KICK
MODE
INVITE
```

Il faut répondre avec une erreur IRC, par exemple :

```txt
451 ERR_NOTREGISTERED
```

---

### 6.5 Replies numériques

IRC utilise beaucoup de réponses numériques.

Exemples utiles :

```txt
001 RPL_WELCOME
331 RPL_NOTOPIC
332 RPL_TOPIC
341 RPL_INVITING
353 RPL_NAMREPLY
366 RPL_ENDOFNAMES
401 ERR_NOSUCHNICK
403 ERR_NOSUCHCHANNEL
404 ERR_CANNOTSENDTOCHAN
431 ERR_NONICKNAMEGIVEN
432 ERR_ERRONEUSNICKNAME
433 ERR_NICKNAMEINUSE
441 ERR_USERNOTINCHANNEL
442 ERR_NOTONCHANNEL
443 ERR_USERONCHANNEL
451 ERR_NOTREGISTERED
461 ERR_NEEDMOREPARAMS
462 ERR_ALREADYREGISTERED
464 ERR_PASSWDMISMATCH
471 ERR_CHANNELISFULL
472 ERR_UNKNOWNMODE
473 ERR_INVITEONLYCHAN
475 ERR_BADCHANNELKEY
482 ERR_CHANOPRIVSNEEDED
```

Pourquoi centraliser les replies ?

Pour éviter d’écrire des strings partout dans les handlers.

Exemple conseillé :

```cpp
namespace Replies
{
    std::string welcome(const Client& client);
    std::string needMoreParams(const std::string& nick, const std::string& cmd);
    std::string nicknameInUse(const std::string& nick);
    std::string passMismatch();
    std::string notRegistered();
}
```

---

### 6.6 Channels

Un channel est un salon IRC.

Il commence généralement par `#` :

```txt
#general
#test
#dev
```

Un channel doit stocker :

```txt
- son nom
- son topic
- ses clients
- ses opérateurs
- ses invités
- son mot de passe éventuel
- ses modes actifs
- sa limite d'utilisateurs éventuelle
```

Structure conseillée :

```cpp
class Channel
{
private:
    std::string _name;
    std::string _topic;
    std::string _key;

    std::set<int> _clients;
    std::set<int> _operators;
    std::set<int> _invited;

    bool _inviteOnly;
    bool _topicProtected;
    int  _userLimit;
};
```

Le premier client qui crée un channel devient généralement opérateur.

---

### 6.7 Operators

Un opérateur de channel est un utilisateur qui a des droits supplémentaires dans ce channel.

Il peut :

```txt
- kick un utilisateur
- inviter un utilisateur
- modifier certains modes
- changer le topic si +t est actif
- donner ou retirer le statut opérateur avec MODE +o / -o
```

Important : être opérateur dans `#test` ne veut pas dire être opérateur dans `#dev`.

Les droits sont par channel.

---

### 6.8 `PRIVMSG`

`PRIVMSG` sert à envoyer un message.

Vers un utilisateur :

```txt
PRIVMSG bob :salut bob
```

Vers un channel :

```txt
PRIVMSG #test :salut tout le monde
```

Si c’est un channel, le serveur doit transmettre à tous les autres membres du channel.

Schéma :

```txt
client1 -> PRIVMSG #test :salut
              |
              v
           serveur
              |
              +--> client2 reçoit
              +--> client3 reçoit
              +--> client4 reçoit
```

En général, on ne renvoie pas le message à l’émetteur.

---

### 6.9 `MODE`

`MODE` sert à modifier le comportement d’un channel.

Exemples :

```txt
MODE #test +i
MODE #test -i
MODE #test +t
MODE #test -t
MODE #test +k secret
MODE #test -k
MODE #test +o bob
MODE #test -o bob
MODE #test +l 10
MODE #test -l
```

Détail des modes :

```txt
+i : seul un utilisateur invité peut rejoindre
-t/+t : topic libre ou réservé aux opérateurs
+k : le channel demande une clé pour JOIN
+o : donne les droits opérateur
-o : retire les droits opérateur
+l : fixe une limite d'utilisateurs
-l : retire la limite
```

---

## 7. Les commandes à implémenter et leur rôle

### 7.1 `PASS`

Rôle : vérifier le mot de passe du serveur.

Exemple :

```txt
PASS secret
```

À vérifier :

```txt
- Le client n'est pas déjà registered
- Le paramètre existe
- Le mot de passe correspond à celui donné au lancement du serveur
```

Erreurs possibles :

```txt
461 ERR_NEEDMOREPARAMS
462 ERR_ALREADYREGISTERED
464 ERR_PASSWDMISMATCH
```

---

### 7.2 `NICK`

Rôle : définir le pseudonyme de l’utilisateur.

Exemple :

```txt
NICK noe
```

À vérifier :

```txt
- Paramètre présent
- Nickname valide
- Nickname non déjà utilisé
```

Erreurs possibles :

```txt
431 ERR_NONICKNAMEGIVEN
432 ERR_ERRONEUSNICKNAME
433 ERR_NICKNAMEINUSE
```

---

### 7.3 `USER`

Rôle : définir username et realname.

Exemple :

```txt
USER noe 0 * :Noe Kiefer
```

À vérifier :

```txt
- Assez de paramètres
- Client pas déjà registered
```

Erreurs possibles :

```txt
461 ERR_NEEDMOREPARAMS
462 ERR_ALREADYREGISTERED
```

---

### 7.4 `PING` / `PONG`

Rôle : garder la connexion vivante.

Client envoie :

```txt
PING :abc123
```

Serveur répond :

```txt
PONG :abc123
```

Beaucoup de clients IRC en ont besoin pour ne pas considérer le serveur comme mort.

---

### 7.5 `JOIN`

Rôle : rejoindre un channel.

Exemple :

```txt
JOIN #test
```

Avec mot de passe :

```txt
JOIN #test secret
```

À vérifier :

```txt
- Client registered
- Nom de channel valide
- Si channel inexistant : le créer
- Si premier utilisateur : le mettre opérateur
- Si +i : utilisateur doit être invité
- Si +k : clé correcte obligatoire
- Si +l : vérifier la limite
```

Erreurs possibles :

```txt
451 ERR_NOTREGISTERED
461 ERR_NEEDMOREPARAMS
471 ERR_CHANNELISFULL
473 ERR_INVITEONLYCHAN
475 ERR_BADCHANNELKEY
```

---

### 7.6 `PART`

Rôle : quitter un channel.

Exemple :

```txt
PART #test
```

À vérifier :

```txt
- Channel existe
- Client est dans le channel
- Supprimer le client du channel
- Si channel vide : supprimer le channel
```

---

### 7.7 `PRIVMSG`

Rôle : envoyer un message privé ou de channel.

Exemples :

```txt
PRIVMSG bob :salut
PRIVMSG #test :salut tout le monde
```

À vérifier :

```txt
- Client registered
- Cible présente
- Message présent
- Si cible channel : channel existe et client a le droit d'écrire
- Si cible user : nickname existe
```

---

### 7.8 `TOPIC`

Rôle : voir ou modifier le topic d’un channel.

Voir le topic :

```txt
TOPIC #test
```

Changer le topic :

```txt
TOPIC #test :nouveau topic
```

À vérifier :

```txt
- Channel existe
- Client est dans le channel
- Si +t est actif : client doit être opérateur
```

---

### 7.9 `KICK`

Rôle : éjecter un utilisateur d’un channel.

Exemple :

```txt
KICK #test bob :raison
```

À vérifier :

```txt
- Channel existe
- Client source est dans le channel
- Client source est opérateur
- Cible existe
- Cible est dans le channel
```

---

### 7.10 `INVITE`

Rôle : inviter un utilisateur dans un channel.

Exemple :

```txt
INVITE bob #test
```

À vérifier :

```txt
- Cible existe
- Channel existe
- Source est dans le channel
- Si channel +i : source doit être opérateur
- Ajouter la cible à la liste _invited
```

---

### 7.11 `MODE`

Rôle : modifier les modes du channel.

Exemples obligatoires :

```txt
MODE #test +i
MODE #test -i
MODE #test +t
MODE #test -t
MODE #test +k secret
MODE #test -k
MODE #test +o bob
MODE #test -o bob
MODE #test +l 10
MODE #test -l
```

À vérifier :

```txt
- Channel existe
- Client est opérateur
- Mode connu
- Paramètre présent si le mode en demande un
```

---

### 7.12 `QUIT`

Rôle : quitter le serveur proprement.

Exemple :

```txt
QUIT :bye
```

À faire :

```txt
- Broadcast aux channels où le client est présent
- Retirer le client de tous les channels
- Fermer le fd
- Supprimer le Client
```

---

## 8. Les options et comment y accéder

### 8.1 Lancer le serveur

Commande :

```bash
./ircserv 6667 pass
```

Signification :

```txt
6667 = port classique de test IRC
pass = mot de passe attendu par PASS
```

---

### 8.2 Compiler en mode normal

```bash
make
```

ou :

```bash
make all
```

Produit :

```txt
./ircserv
```

---

### 8.3 Compiler en mode debug

```bash
make debug
```

Effet attendu :

```txt
Compile avec -DDEBUG=1
Active la macro DBG(msg)
Affiche les événements serveur
```

Exemple d'affichage :

```txt
[DEBUG] Creating server socket...
[DEBUG] Binding server on port 6667
[DEBUG] New client accepted, fd = 4
```

---

### 8.4 Nettoyer les fichiers objets

```bash
make clean
```

Rôle :

```txt
Supprime les .o
```

---

### 8.5 Nettoyer complètement

```bash
make fclean
```

Rôle :

```txt
Supprime les .o et l'exécutable ircserv
```

---

### 8.6 Recompiler depuis zéro

```bash
make re
```

Rôle :

```txt
fclean puis all
```

---

### 8.7 Tester avec `nc`

Connexion simple :

```bash
nc -C 127.0.0.1 6667
```

Puis taper :

```txt
PASS pass
NICK noe
USER noe 0 * :Noe
```

`-C` permet à `nc` d’envoyer les fins de ligne en CRLF sur certaines versions.

---

### 8.8 Tester la fragmentation TCP

Le sujet demande de vérifier que ton serveur sait reconstruire une commande reçue en plusieurs morceaux.

Avec `nc` :

```bash
nc -C 127.0.0.1 6667
```

Puis envoyer une commande petit à petit avec `Ctrl+D` entre les morceaux selon l’environnement.

Idée du test :

```txt
com
man
d\n
```

Le serveur doit reconstruire :

```txt
command
```

a tester :

```txt
PASS pa
ss\r\n
```

ou :

```txt
NICK n
oe\r\n
```

---

### 8.9 Tester avec `irssi`

Installer :

```bash
sudo apt install irssi
```

Connexion :

```bash
irssi -c 127.0.0.1 -p 6667 -w pass
```

Dans `irssi` :

```txt
/nick noe
/join #test
/msg #test salut
/part #test
/quit
```

Pour deux clients : ouvrir deux terminaux.

Terminal 1 :

```bash
irssi -c 127.0.0.1 -p 6667 -w pass
```

Terminal 2 :

```bash
irssi -c 127.0.0.1 -p 6667 -w pass
```

Puis :

```txt
client1: /join #test
client2: /join #test
client1: /msg #test salut
client2 doit recevoir le message
```

---

### 8.10 Tester les leaks

```bash
valgrind --leak-check=full --show-leak-kinds=all --track-fds=yes ./ircserv 6667 pass
```

À vérifier :

```txt
- Pas de definitely lost
- Pas de fd client oublié
- Pas de fd serveur oublié après arrêt propre
```

---

## 9. Architecture conseillée pour la suite

Pour éviter que `Server.cpp` devienne énorme, je te conseille cette structure :

```txt
ircserv/
├── Makefile
├── includes/
│   ├── Server.hpp
│   ├── Client.hpp
│   ├── Channel.hpp
│   ├── IrcMessage.hpp
│   ├── IrcParser.hpp
│   ├── CommandDispatcher.hpp
│   ├── Replies.hpp
│   ├── Debug.hpp
│   └── exceptions.hpp
│
├── src/
│   ├── main.cpp
│   ├── Server.cpp
│   ├── Client.cpp
│   ├── Channel.cpp
│   ├── IrcParser.cpp
│   ├── CommandDispatcher.cpp
│   ├── Replies.cpp
│   └── commands/
│       ├── PassCommand.cpp
│       ├── NickCommand.cpp
│       ├── UserCommand.cpp
│       ├── JoinCommand.cpp
│       ├── PrivmsgCommand.cpp
│       ├── PartCommand.cpp
│       ├── PingCommand.cpp
│       ├── QuitCommand.cpp
│       ├── TopicCommand.cpp
│       ├── KickCommand.cpp
│       ├── InviteCommand.cpp
│       └── ModeCommand.cpp
│
└── tests/
    ├── manual_nc.sh
    ├── auto_test.sh
    └── leak_test.sh
```

Architecture mentale :

```txt
main.cpp
   ↓
Server
   ↓
Client / Channel
   ↓
IrcParser
   ↓
CommandDispatcher
   ↓
Handlers de commandes
   ↓
Replies
```

---

## 10. Todo-list globale

### 10.1 Fondations déjà faites

```txt
[x] Comprendre le sujet général ft_irc
[x] Comprendre le rôle de Jarkko Oikarinen et l'idée historique d'IRC
[x] Comprendre qu'IRC est un protocole texte
[x] Comprendre la différence client IRC / serveur IRC
[x] Comprendre que le projet demande seulement un serveur
[x] Comprendre le lancement ./ircserv <port> <password>
[x] Parser argc/argv dans main.cpp
[x] Vérifier que le port est numérique
[x] Vérifier que le port est dans une plage valide
[x] Vérifier que le password n'est pas vide
[x] Créer une classe Server
[x] Créer une classe Client
[x] Créer un socket serveur
[x] Configurer SO_REUSEADDR
[x] bind sur le port
[x] listen sur le socket serveur
[x] mettre le socket serveur en non-bloquant
[x] créer un vector<pollfd>
[x] ajouter le socket serveur dans poll
[x] faire une boucle poll
[x] accepter les nouveaux clients
[x] mettre les clients en non-bloquant
[x] ajouter les clients dans poll
[x] stocker les clients dans map<int, Client>
[x] recevoir les données avec recv
[x] détecter bytes == 0 comme déconnexion
[x] gérer EAGAIN / EWOULDBLOCK
[x] créer un buffer par client
[x] append les données reçues dans le buffer
[x] détecter une commande complète avec \n
[x] retirer le \r final
[x] extraire plusieurs commandes dans un seul recv
[x] supprimer un client de _clients et _fds
[x] fermer le fd avec close
[x] ajouter une macro DBG
[x] préparer une cible debug dans le Makefile
```

---

### 10.2 À corriger immédiatement

```txt
[ ] Corriger le Makefile pour qu'il corresponde aux vrais chemins
[ ] Créer une arborescence propre src/ + includes/
[ ] Déplacer server.hpp, client.hpp, debug.hpp dans includes/
[ ] Déplacer main.cpp, server.cpp dans src/
[ ] Créer Client.cpp au lieu de tout laisser inline dans Client.hpp
[ ] Retirer debug.cpp du build principal, car il contient un autre main()
[ ] Vérifier que make, make debug, make clean, make fclean, make re fonctionnent
[ ] Tester ./ircserv 6667 pass avec nc
```

---

### 10.3 À faire ensuite : écriture non-bloquante propre

```txt
[ ] Ajouter std::string _outBuffer dans Client
[ ] Ajouter appendOutBuffer() ou queueMessage()
[ ] Ajouter hasDataToSend()
[ ] Ajouter popSentBytes(size_t n)
[ ] Modifier les pollfd pour activer POLLOUT quand le client a des données à envoyer
[ ] Créer Server::sendToClient() ou queueToClient()
[ ] Créer Server::flushClientOutput()
[ ] Ne plus faire send() directement dans acceptNewClient()
[ ] Supprimer le message décoratif de connexion ou le remplacer par des replies IRC après registration
```

Pourquoi c’est important :

```txt
Le sujet veut que les opérations I/O soient gérées via poll.
recv() est déjà surveillé avec POLLIN.
send() doit être surveillé avec POLLOUT.
```

---

### 10.4 Parser IRC

```txt
[ ] Créer IrcMessage.hpp
[ ] Créer IrcParser.hpp / IrcParser.cpp
[ ] Créer une structure IrcMessage avec prefix, command, params
[ ] Retirer les lignes vides
[ ] Gérer le prefix optionnel qui commence par ':'
[ ] Mettre command en uppercase
[ ] Découper les paramètres
[ ] Gérer le trailing parameter avec ':'
[ ] Limiter ou refuser les lignes trop longues
[ ] Tester avec PRIVMSG #test :hello world
[ ] Tester avec USER noe 0 * :Noe Kiefer
```

---

### 10.5 Améliorer Client

```txt
[ ] Ajouter _nickname
[ ] Ajouter _username
[ ] Ajouter _realname
[ ] Ajouter _passAccepted
[ ] Ajouter _registered
[ ] Ajouter getters / setters propres
[ ] Ajouter isRegistered()
[ ] Ajouter hasPassAccepted()
[ ] Ajouter une liste ou set de channels rejoints si utile
```

---

### 10.6 Replies numériques

```txt
[ ] Créer Replies.hpp / Replies.cpp
[ ] Créer une fonction formatPrefix serveur
[ ] Créer RPL_WELCOME 001
[ ] Créer ERR_NEEDMOREPARAMS 461
[ ] Créer ERR_PASSWDMISMATCH 464
[ ] Créer ERR_ALREADYREGISTERED 462
[ ] Créer ERR_NONICKNAMEGIVEN 431
[ ] Créer ERR_ERRONEUSNICKNAME 432
[ ] Créer ERR_NICKNAMEINUSE 433
[ ] Créer ERR_NOTREGISTERED 451
[ ] Créer les replies liées aux channels plus tard
```

---

### 10.7 Dispatcher

```txt
[ ] Créer CommandDispatcher.hpp / CommandDispatcher.cpp
[ ] Créer une map command -> handler
[ ] Brancher PASS
[ ] Brancher NICK
[ ] Brancher USER
[ ] Brancher PING
[ ] Brancher QUIT
[ ] Plus tard : JOIN, PART, PRIVMSG, TOPIC, KICK, INVITE, MODE
[ ] Remplacer Server::handleCommand() par parser + dispatcher
```

---

### 10.8 Registration PASS / NICK / USER

```txt
[ ] Implémenter PASS
[ ] Vérifier password correct
[ ] Refuser PASS après registration
[ ] Implémenter NICK
[ ] Vérifier nickname vide
[ ] Vérifier nickname déjà utilisé
[ ] Implémenter USER
[ ] Vérifier assez de paramètres
[ ] Créer maybeRegister(Client&)
[ ] Quand PASS + NICK + USER sont OK : passer registered = true
[ ] Envoyer 001 RPL_WELCOME
[ ] Tester avec nc
[ ] Tester avec irssi
```

Test minimal :

```txt
PASS pass
NICK noe
USER noe 0 * :Noe
```

Résultat attendu :

```txt
:ircserv 001 noe :Welcome to the Internet Relay Network noe
```

---

### 10.9 PING / PONG / QUIT

```txt
[ ] Implémenter PING
[ ] Répondre PONG avec le même token
[ ] Implémenter QUIT
[ ] Retirer le client proprement
[ ] Broadcast QUIT aux channels concernés plus tard
```

---

### 10.10 Channels simples

```txt
[ ] Créer Channel.hpp / Channel.cpp
[ ] Ajouter map<string, Channel> _channels dans Server
[ ] Implémenter JOIN
[ ] Créer le channel s'il n'existe pas
[ ] Mettre le premier utilisateur opérateur
[ ] Broadcast le JOIN aux membres
[ ] Envoyer la liste des noms 353 / 366
[ ] Implémenter PART
[ ] Retirer le client du channel
[ ] Supprimer le channel s'il est vide
[ ] Implémenter PRIVMSG vers channel
[ ] Implémenter PRIVMSG vers utilisateur
```

Test :

```txt
client1: JOIN #test
client2: JOIN #test
client1: PRIVMSG #test :salut
client2 reçoit le message
```

---

### 10.11 Commandes opérateur

```txt
[ ] Implémenter TOPIC lecture
[ ] Implémenter TOPIC modification
[ ] Gérer mode +t
[ ] Implémenter KICK
[ ] Vérifier les droits opérateur
[ ] Implémenter INVITE
[ ] Ajouter les invités dans Channel
[ ] Implémenter MODE +i / -i
[ ] Implémenter MODE +t / -t
[ ] Implémenter MODE +k / -k
[ ] Implémenter MODE +o / -o
[ ] Implémenter MODE +l / -l
```

---

### 10.12 Robustesse

```txt
[ ] Gérer commande inconnue
[ ] Gérer params manquants
[ ] Gérer client qui coupe brutalement
[ ] Gérer plusieurs commandes dans un seul recv
[ ] Gérer une commande reçue en plusieurs recv
[ ] Gérer lignes trop longues
[ ] Limiter la taille du buffer client
[ ] Ne jamais faire crash le serveur à cause d'un client
[ ] Nettoyer le client de tous les channels avant close
[ ] Supprimer les channels vides
[ ] Gérer les erreurs POLLERR / POLLHUP / POLLNVAL
[ ] Gérer EINTR sur poll
```

---

### 10.13 Tests finaux

```txt
[ ] Test nc simple
[ ] Test nc fragmentation
[ ] Test deux clients nc
[ ] Test irssi connexion
[ ] Test irssi join channel
[ ] Test irssi privmsg channel
[ ] Test mauvais password
[ ] Test nickname déjà pris
[ ] Test JOIN avant registration
[ ] Test PRIVMSG avant registration
[ ] Test MODE sans droit opérateur
[ ] Test KICK sans droit opérateur
[ ] Test INVITE channel +i
[ ] Test TOPIC avec +t
[ ] Test MODE +k avec JOIN clé correcte / incorrecte
[ ] Test MODE +l limite atteinte
[ ] Test valgrind leaks
[ ] Test valgrind fd
```

---

### 10.14 README final

Le sujet demande un README en anglais.

À prévoir :

```txt
[ ] Première ligne en italique : This project has been created as part of the 42 curriculum by <login>.
[ ] Description du projet
[ ] Instructions de compilation
[ ] Instructions d'exécution
[ ] Exemples avec nc
[ ] Exemples avec irssi
[ ] Liste des commandes supportées
[ ] Architecture technique
[ ] Ressources utilisées
[ ] Section expliquant comment l'IA a été utilisée
```

---

## 11. Plan détaillé de la suite à réaliser

### Phase 1 — Remettre le projet propre

Objectif : compiler proprement.

```txt
1. Créer includes/ et src/
2. Déplacer les fichiers
3. Corriger les includes
4. Créer Client.cpp
5. Corriger le Makefile
6. Tester make re
7. Lancer ./ircserv 6667 pass
8. Tester avec nc
```

Critère de réussite :

```txt
Le serveur compile et affiche les commandes reçues avec nc.
```

---

### Phase 2 — Rendre send propre

Objectif : avoir lecture et écriture non-bloquantes.

```txt
1. Ajouter _outBuffer dans Client
2. Créer queueMessage()
3. Activer POLLOUT quand _outBuffer non vide
4. Créer flushClientOutput()
5. Envoyer progressivement les données avec send()
6. Désactiver POLLOUT quand tout est envoyé
```

Critère de réussite :

```txt
On peut envoyer une réponse au client sans send direct non contrôlé.
```

---

### Phase 3 — Parser IRC

Objectif : transformer une ligne en commande exploitable.

```txt
1. Créer IrcMessage
2. Créer IrcParser
3. Parser command
4. Parser params
5. Parser trailing avec ':'
6. Tester avec plusieurs lignes
```

Critère de réussite :

```txt
PRIVMSG #test :hello world devient command=PRIVMSG, params=[#test, hello world]
```

---

### Phase 4 — Registration

Objectif : qu’un client puisse devenir registered.

```txt
1. Ajouter état dans Client
2. Implémenter PASS
3. Implémenter NICK
4. Implémenter USER
5. Créer maybeRegister
6. Envoyer 001 welcome
```

Critère de réussite :

```txt
Avec nc ou irssi, PASS + NICK + USER reçoit un welcome IRC.
```

---

### Phase 5 — Channels basiques

Objectif : discuter dans un salon.

```txt
1. Créer Channel
2. Implémenter JOIN
3. Implémenter PRIVMSG #channel
4. Implémenter PART
5. Supprimer les channels vides
```

Critère de réussite :

```txt
Deux clients dans #test peuvent discuter.
```

---

### Phase 6 — Commandes opérateur

Objectif : terminer le mandatory.

```txt
1. TOPIC
2. KICK
3. INVITE
4. MODE +i
5. MODE +t
6. MODE +k
7. MODE +o
8. MODE +l
```

Critère de réussite :

```txt
Toutes les commandes demandées par le sujet fonctionnent avec ton client de référence.
```
---

## 12. Questions sur irc

```txt
C'est quoi IRC ?
Pourquoi IRC est un protocole texte ?
Pourquoi on utilise TCP ?
C'est quoi un socket ?
C'est quoi un fd ?
Quelle est la différence entre serverFd et clientFd ?
À quoi sert bind() ?
À quoi sert listen() ?
À quoi sert accept() ?
Pourquoi mettre les fd en non-bloquant ?
À quoi sert poll() ?
Pourquoi pas un thread par client ?
Pourquoi TCP peut fragmenter une commande ?
Pourquoi un buffer par client est obligatoire ?
Comment tu sais qu'une commande est complète ?
Pourquoi \r\n ?
C'est quoi PASS / NICK / USER ?
C'est quoi un client registered ?
Pourquoi bloquer JOIN avant registration ?
C'est quoi une reply numérique ?
C'est quoi un channel ?
C'est quoi un opérateur de channel ?
Comment fonctionne PRIVMSG ?
Comment fonctionne KICK ?
Comment fonctionne INVITE ?
Comment fonctionne TOPIC ?
Comment fonctionne MODE ?
Comment tu nettoies un client qui quitte ?
Comment tu évites les leaks ?
Comment tu évites qu'un client fasse crash le serveur ?
Pourquoi le Makefile ne doit pas relink inutilement ?
Comment tester la fragmentation TCP ?
Comment tester avec irssi ?
```

---

## 13. Mini explication du serveur actuel


```txt
Le serveur commence par parser les arguments : un port et un mot de passe.
Ensuite, il crée un socket TCP IPv4 avec socket(), active SO_REUSEADDR avec setsockopt(), associe le socket au port avec bind(), puis le place en écoute avec listen().

Le socket serveur est mis en non-bloquant avec fcntl(O_NONBLOCK), puis ajouté à un vector de pollfd.
La boucle principale appelle poll(), qui attend un événement sur tous les fd surveillés.

Si l'événement concerne le socket serveur, cela signifie qu'une nouvelle connexion arrive : j'appelle accept(), je mets le nouveau client en non-bloquant, je l'ajoute à poll(), et je crée un objet Client associé à son fd.

Si l'événement concerne un client, je lis avec recv(). Les données reçues sont ajoutées dans le buffer du Client. Ensuite, tant que le buffer contient une fin de ligne, j'extrais une commande complète avec popCommand().

Cette logique est nécessaire parce que TCP est un flux d'octets : une commande IRC peut arriver coupée en plusieurs paquets, ou plusieurs commandes peuvent arriver dans un seul recv().

Pour l'instant, handleCommand() affiche seulement la commande reçue. La prochaine étape est de remplacer cette fonction par un parser IRC puis un dispatcher de commandes PASS, NICK, USER, JOIN, PRIVMSG, etc.
```

---

## 14. Points de vigilance

```txt
- Ne pas laisser Client.hpp contenir trop de code inline.
- Ne pas garder debug.cpp dans le build principal, car il contient un main().
- Ne pas faire grossir Server.cpp avec toutes les commandes IRC.
- Ne pas envoyer de réponses IRC avec des send directs partout.
- Ne pas oublier POLLOUT pour l'écriture.
- Ne pas oublier qu'un client peut envoyer une commande incomplète.
- Ne pas oublier qu'un client peut envoyer plusieurs commandes d'un coup.
- Ne pas oublier de supprimer un client de tous les channels avant de fermer son fd.
- Ne pas oublier de supprimer les channels vides.
- Ne pas faire crash le serveur pour une erreur client.
- Ne pas implémenter les bonus avant que le mandatory soit parfait.
```

---

## 15. Ordre de priorité final

À partir de maintenant, l’ordre le plus intelligent est :

```txt
1. Makefile + arborescence propre
2. Client.cpp propre
3. Output buffer + POLLOUT
4. IrcMessage + IrcParser
5. Replies numériques
6. PASS / NICK / USER
7. PING / PONG / QUIT
8. Channel class
9. JOIN / PART
10. PRIVMSG user + channel
11. TOPIC
12. KICK
13. INVITE
14. MODE +i +t +k +o +l
15. Tests robustesse
16. Tests irssi
17. Valgrind
18. README anglais
19. Préparation 
```

---

## 16. Sources utilisées dans ce document

```txt
- Sujet ft_irc : en.irc.subject.pdf
- Plan de travail IRC.txt
- Fichiers code envoyés : main.cpp, server.cpp, server.hpp, client.hpp, debug.hpp, debug.cpp, Makefile
- Explications produites pendant notre conversation sur le serveur TCP, poll, buffer client, parser IRC et architecture ft_irc
```
````
https://fr.wikipedia.org/wiki/Internet_Relay_Chat

````
````
https://www.ionos.fr/digitalguide/serveur/know-how/irc/
````
````
https://datatracker.ietf.org/doc/html/draft-oakley-irc-ctcp-02
````
````
https://www.rfc-editor.org/info/rfc2812/
````
````
https://www.irchelp.org/
```
