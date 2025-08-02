#wasist  #FiveM #scriptenlernen #Scripting  #ger
# Eine Variable

Variablen sind ein grundlegendes Konzept in der Programmierung und dienen dazu, Werte zu speichern. In Lua, der Programmiersprache von FiveM, gibt es verschiedene Arten von Variablen:

#### **String (Zeichenkette):**
Ein String ist eine Abfolge von Zeichen, wie Buchstaben, Zahlen oder Symbole. Strings werden in doppelten Anführungszeichen `"` oder einfachen Anführungszeichen `'` eingeschlossen. Zum Beispiel:

  ```lua
  local name = "Hallo, Welt!"
  ```

  Hier ist `name` eine Variable vom Typ String.


#### **Integer (Ganzzahl):** Ein Integer ist eine ganze Zahl ohne Dezimalstellen. Zum Beispiel:

  ```lua
  local alter = 25
  ```

  Die Variable `alter` ist vom Typ Integer und enthält den Wert 25.
  

#### **Float (Gleitkommazahl):** Ein Float ist eine Zahl mit Dezimalstellen. Zum Beispiel:

  ```lua
  local pi = 3.14159
  ```

  Die Variable `pi` ist vom Typ Float und enthält den Wert von Pi (π).

#### **Boolean (Wahrheitswert):**
Ein Boolean kann entweder `true` (wahr) oder `false` (falsch) sein. Sie werden oft für bedingte Aussagen und Schleifen verwendet. Zum Beispiel:

  ```lua
  local istWahr = true
  ```

  Die Variable `istWahr` ist vom Typ Boolean und enthält den Wert `true`.

#### **Table (Tabelle):**
Eine Tabelle ist eine komplexe Datenstruktur, die verschiedene Werte in einer geordneten Liste oder als Schlüssel-Wert-Paare speichern kann. Tabelle ist ein mächtiges Konzept in Lua und wird für viele Zwecke verwendet. Zum Beispiel:

  ```lua
  local spieler = {name = "Max", punkte = 100}
  ```

  Die Variable `spieler` ist vom Typ Table und enthält die Informationen über einen Spieler, einschließlich seines Namens und seiner Punktzahl.

Das Verständnis dieser verschiedenen Variablentypen ist entscheidend, um in der Programmierung effektiv arbeiten zu können. Du kannst diese Variablen verwenden, um Informationen zu speichern, zu verarbeiten und in deinen FiveM-Skripten zu verwenden.


# Eine Funktion

Eine Funktion in Lua ist eine benannte Gruppe von Anweisungen, die einen bestimmten Auftrag ausführen. Funktionen werden in Lua oft verwendet, um Code zu strukturieren, wiederzuverwenden und zu organisieren. Sie ermöglichen es, denselben Code an verschiedenen Stellen im Skript aufzurufen, was die Lesbarkeit und Wartbarkeit deines Codes verbessert.

Hier ist die Grundstruktur einer Funktion in Lua:

```lua
function funktionName()
    -- Hier kommt der Code der Funktion
end
```

Denk an eine Funktion wie an eine Buchseite. Wenn du das Buch öffnest und diese Seite liest, führst du alle Anweisungen aus, die auf dieser Seite stehen.

Hier ist ein einfaches Beispiel, wie wir eine Funktion verwenden, um die Berechnung von 2 * 2 auszuführen:

```lua
function berechneErgebnis()
    local ergebnis = 2 * 2
    print(ergebnis)
end

-- Jetzt rufen wir die Funktion auf, um das Ergebnis anzuzeigen
berechneErgebnis()
```

In diesem Beispiel haben wir eine Funktion namens `berechneErgebnis` erstellt. In dieser Funktion wird die Berechnung von 2 * 2 durchgeführt, und das Ergebnis wird in der Variable `ergebnis` gespeichert und dann mit `print` auf der Konsole ausgegeben. 

Wir rufen dann die Funktion `berechneErgebnis()` auf, und sie führt den darin enthaltenen Code aus. Das Ergebnis, das auf der Konsole angezeigt wird, ist `4`.

**Übergabe von Argumenten an Funktionen:**

Funktionen können auch Argumente entgegennehmen, die ihnen Informationen übermitteln. Hier ist ein Beispiel:

```lua
function multipliziere(zahl1, zahl2)
    local ergebnis = zahl1 * zahl2
    print(ergebnis)
end

-- Jetzt rufen wir die Funktion auf und übergeben ihr zwei Zahlen
multipliziere(3, 5)
```

In diesem Fall haben wir eine Funktion namens `multipliziere` erstellt, die zwei Argumente erwartet: `zahl1` und `zahl2`. Innerhalb der Funktion werden diese Argumente genutzt, um die Multiplikation durchzuführen und das Ergebnis auszugeben.

Wenn wir die Funktion aufrufen (`multipliziere(3, 5)`), übergeben wir ihr die Werte `3` und `5` als Argumente. Die Funktion verwendet diese Werte, um das Ergebnis `15` zu berechnen und auf der Konsole auszugeben.

Das Verwenden von Argumenten ermöglicht es, Funktionen flexibel zu gestalten und sie für verschiedene Eingabewerte zu verwenden, ohne den Code ständig ändern zu müssen.

# `while (true)`-Schleifen

Eine `while (true)`-Schleife ist eine grundlegende Schleifenstruktur in der Programmierung, die dazu dient, einen bestimmten Codeblock endlos auszuführen.

**Was ist das?**

Eine `while (true)`-Schleife ist eine Art von Schleife, die so lange wiederholt wird, wie die Bedingung `true` ist. Sie wird oft verwendet, um Aufgaben zu wiederholen, die kontinuierlich ausgeführt werden müssen, ohne anzuhalten.

Hier ist ein einfaches Beispiel in Lua:

```lua
while true do
    -- Dieser Codeblock wird endlos wiederholt
    print("Dies wird immer wieder ausgeführt!")
end
```

In diesem Beispiel wird der Text "Dies wird immer wieder ausgeführt!" unendlich oft auf die Konsole gedruckt, da die Bedingung `true` niemals falsch wird.

Es ist jedoch wichtig zu beachten, dass `while (true)`-Schleifen vorsichtig verwendet werden sollten, da sie dazu führen können, dass deine Anwendung blockiert wird, wenn die Bedingung niemals `false` wird. Du solltest sicherstellen, dass es eine Möglichkeit gibt, die Schleife zu beenden, wenn dies notwendig ist. Zum Beispiel könntest du eine bestimmte Bedingung in der Schleife überprüfen und sie mit `break` beenden, wenn diese Bedingung erfüllt ist.

# Ein Thread

Ein Thread in Verbindung mit FiveM wird durch die Funktion `Citizen.CreateThread` erstellt.

**Was ist ein Thread?**

Ein Thread, auch außerhalb von FiveM als Coroutine bezeichnet, ist eine Funktion, die Code außerhalb des normalen Ablaufs ausführt. Wenn du beispielsweise Code hast, der 300 Sekunden warten soll, wird dieser Code innerhalb des Threads in einer Art "eigenen Ausführungsumgebung" ausgeführt. Lass mich erklären, was das bedeutet:

Stell dir vor, du hast einen Code, der 300 Sekunden warten muss. Wenn du diesen Code in einen Thread legst, wird eine neue "Instanz" dieses Codes erstellt. Diese Instanz hat ihre eigene Zeit und führt den Code aus, ohne den Rest deiner Anwendung zu blockieren. Das bedeutet, dass der Hauptteil deiner Anwendung weiterhin normal funktionieren kann, während der Thread im Hintergrund arbeitet.

Ein Thread in FiveM wird oft für sogenannte `while true`-Schleifen verwendet, um beispielsweise zu überprüfen, ob ein Spieler in der Nähe einer Koordinate ist. VORSICHT! Dies darf nicht zu oft gemacht werden, da der Server sonst abstürzen kann. Mit `Citizen.Wait(milliseconds)` gibst du dem Skript an, wie lange es warten soll.

Einige Skripte müssen jede Millisekunde laufen, aber zum Beispiel das Überprüfen, ob ein Spieler dauerhaft in einem Auto ist, kann auch 20 ms länger dauern. Das stört den Spieler nicht und gibt dem Server etwas mehr Zeit zum Atmen.

Ein Thread muss nicht jede Millisekunde laufen. Du kannst dies steuern, indem du Folgendes in deinen Thread einfügst (entweder am Anfang oder am Ende des Threads):

```lua
ms = 5000 -- wie viele Millisekunden gewartet werden sollen

Citizen.Wait(ms)
```

Das sagt dem Thread, wie lange er bei jedem Durchgang warten soll. Wenn wir beispielsweise "Heyo!" alle 5 Sekunden ausgeben wollen, würden wir das so schreiben:

```lua
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- 5000 Millisekunden sind 5 Sekunden
        print("Heyo")
    end
end)
```

# Ein NUI

NUI steht leider nicht für "Native UI", sondern für "Natural User Interface". NUIs sind in FiveM eingebundene HTML-Websites, die als Menüs mit JavaScript dazwischen fungieren. Sie sind komplexer und für Anfänger schwerer zu verwenden.

# NativeUI

NativeUI ist ein natives Menü, das bereits in GTA 5 existiert. Das werden wir meistens verwenden, da ich ein Fan davon bin.

# Server/Client Event

Ein Server/Client Event ist eine Funktion, die jedoch nur vom Client oder dem Server verwendet werden kann. Solche Events können von jedem Skript aus ausgeführt werden, wenn sie registriert sind. Weitere Informationen dazu findest du [hier](https://docs.fivem.net/docs/scripting-reference/runtimes/lua/server-functions/).

# Callback

Callbacks gibt es in verschiedenen Formen. Ich empfehle die ESX-Callback-Variante, die in jedem

 ESX-Framework enthalten ist. Eine andere Alternative, die ich empfehle, ist kimi_callbacks.

Ein Callback ist eine Art von Code, der einen "Aufruf" an den Server sendet und eine Antwort ("Rückmeldung") an den Client zurückgibt.

**Beispiel:**

Du verwendest einen ESX-Callback, um Job- und Gruppeninformationen vom Server zum Client zu übertragen.

Die gesamte Wiki ist auch von [hier](https://docs.fivem.net/docs/scripting-reference/) inspiriert ;) 

# MySQL

MySQL, auch als "Datenbank" bezeichnet, steht für eine Datenbank, die oft auf demselben Server gehostet wird. Man nennt es MySQL, da dies die Sprache der Datenbank ist, durch die man darauf zugreift. Dies geschieht oft über eine Website namens PHPMyAdmin, (ich empfehle [HeidiSQL](https://www.heidisql.com), da es einfacher zu benutzen und zu verstehen ist).

# Server und Client 

# Warum der Unterschied?

Der Unterschied zwischen einer Client- und Serverdatei besteht darin, dass alles, was im Client (im Spiel) ausgeführt wird, potenziell von anderen gelesen, gestohlen oder sogar abgelegt werden kann. Dies ist nicht wirklich gut. Daher gibt es eine Aufteilung zwischen dem Code, der auf dem Server und dem Client ausgeführt wird. es gibt jedoch Schnittstellen, um das Ganze zu überbrücken, sogenannte Events Im Folgenden finden Sie eine kurze Zusammenfassung der Aufgabenverteilung zwischen Client und Server:

## Client

- Alles, was mit dem Spiel selbst zu tun hat (zz. B.automatisches Spawnen von Objekten, Abspielen von Animationen usw.)
- Alles, was mit dem Spieler selbst zu tun hat

## Server

- Alles, was mit Spielerdaten zu tun hat (z. B. Gruppe, Job, Name)
- Alles, was mit der Datenbank zu tun hat
- Alles, was mit Synchronisation zu tun hat



Wenn du hier fertig bist geht es weiter zu [[Erstellung deines Ersten Scripts]]
