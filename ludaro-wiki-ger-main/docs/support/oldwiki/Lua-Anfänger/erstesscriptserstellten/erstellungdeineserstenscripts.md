#Scripting  #scriptenlernen #tutorial #ger

# Was wird benötigt, um dein erstes FiveM-Script zu erstellen?

- [ ] Einen Testserver, entweder auf deinem eigenen PC (siehe "Einen FiveM Server auf deinem eigenen PC hosten") oder auf einem dedizierten Server.
- [ ] Einen guten Text-Editor (Visual Studio Code wird empfohlen, aber du kannst jeden verwenden, den du bevorzugst).
- [ ] Ein Programm oder eine Website zum Zugriff auf deine Datenbank (z. B. phpMyAdmin oder HeidiSQL).

# Anfänger-Guide: Dein erstes FiveM-Script erstellen

> [info] Wichtige Vorkenntnisse:
> Du solltest im vorraus [[was ist..]] gelesen haben

Wenn du dein erstes FiveM-Script erstellen möchtest, solltest du zunächst darüber nachdenken, welches Projekt du umsetzen möchtest. In der Kategorie "Anfängerprojekte zum Nachmachen" findest du Ideen und Anleitungen, die dir bei der Umsetzung helfen können. Es ist ratsam, keine zu großen Projekte zu wählen, da Fehler gemacht werden dürfen und daraus gelernt werden kann. Du kannst dies entweder auf einem Testserver auf deinem eigenen PC (siehe "Einen FiveM Server auf deinem eigenen PC hosten") oder auf einem anderen Server durchführen.

## Dokumentation

Bevor du mit der Erstellung deines Scripts beginnst, ist es hilfreich, deine Idee klar zu definieren, entweder in deinem Kopf oder mit Notizen. Überlege dir:

- Was soll mein Script tun?
- Welche Code-Ressourcen benötige ich dafür?

Lass uns das anhand eines Beispiels für ein Teamchat-Skript erklären.

#### Ein Teamchat-Skript benötigt:

- Einen vorhandenen Chat.
- Ein Gruppensystem (z. B. ESX oder QB).

#### Was soll mein Skript tun?

Wenn ich "/teamchat NACHRICHT" eingebe, soll diese Nachricht an alle Admins weitergeleitet werden. Dazu muss ich überprüfen, ob die Person zur Admin-Gruppe gehört, und die Nachricht dann an alle Admins senden.

Es ist nicht notwendig, alles detailliert zu dokumentieren, aber eine grobe Vorstellung hilft, die Struktur des Scripts zu behalten und zu wissen, wo du anfangen kannst.

## Erstellung des Skripts

Um das Skript zu erstellen, gehe in den "resources"-Ordner deines FiveM-Servers und erstelle einen Ordner. Der Name sollte keine Leerzeichen oder Sonderzeichen enthalten und leicht zu merken sein.

In diesem Ordner erstellst du eine Datei namens "fxmanifest.lua".

> [!info] Visual Studio Code ermöglicht es dir, ganze Ordner in Visual Studio Code zu öffnen, um eine bessere Strukturierung zu ermöglichen. Ich empfehle dir dies ebenfalls (links oben auf "File" -> "Open Folder" und wähle den Ordner deiner Ressourcen).

Diese Datei gibt an, woraus dein Script besteht:

```lua
fx_version 'cerulean'

game 'gta5'

name "Teamchat" -- Der Name unseres Scripts

author 'Ludaro' -- Unser Name

description 'Ein Teamchat für coole Leute!' -- Eine kurze Beschreibung

```

Nun müssen wir überlegen:

- Welche Lua-Dateien benötigen wir? (Client, Server, Shared).

Für unser Teamchat-Skript benötigen wir eine Server-Lua-Datei, um die Gruppe abzurufen, und eine Client-Lua-Datei, um das Kommando zu erstellen. Außerdem benötigen wir eine Konfigurationsdatei, die "shared" sein muss, damit sie von Client und Server aus gelesen werden kann.

Dies konfigurieren wir in unserem "fxmanifest.lua"-Dokument unter dem, was wir bereits geschrieben haben:

```lua
client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua'
}

```

Nun ist unsere Struktur fertig, und wir können mit der "client.lua"-Datei beginnen!

Aber bevor wir das tun, schauen wir uns den Unterschied zwischen Server- und Client-Skripts genauer an.

# Unterschied zwischen Server und Client Skripts

## Warum gibt es diesen Unterschied?

Der Unterschied zwischen Server- und Clientdateien besteht darin, dass alles, was im Client (im Spiel) ausgeführt wird, potenziell von anderen gelesen, gestohlen oder sogar manipuliert werden kann. Das ist aus Sicherheitsgründen problematisch. Daher gibt es eine klare Trennung zwischen dem Code, der auf dem Server und

 dem Code, der auf dem Client ausgeführt wird. Es gibt jedoch Schnittstellen, um diese Trennung zu überwinden, die als "Events" bezeichnet werden. Im Folgenden findest du eine kurze Übersicht über die Aufgabenverteilung zwischen Client und Server:

## Client

- Alles, was direkt mit dem Spielgeschehen zu tun hat (z. B. das automatische Erzeugen von Objekten, das Abspielen von Animationen usw.).
- Alles, was die Darstellung und das Verhalten des eigenen Spielcharakters betrifft.

## Server

- Alles, was Spielerdaten betrifft (z. B. Gruppenzugehörigkeit, Beruf, Name).
- Alles, was mit der Datenbank zu tun hat.
- Alles, was die Synchronisation und Koordination aller Spieler betrifft.

Ich hoffe, das klärt den Unterschied zwischen Server und Client für dich! Wenn du weitere Fragen hast, stehe ich gerne zur Verfügung.

> [!info] Diese Wiki ist noch nicht fertig und wird noch erstellt. Schau später wieder vorbei!

Aber wie funktioniert das eigentlich? Verwirrend, oder? Keine Sorge, wir schauen uns das in den nächsten Schritten genauer an..