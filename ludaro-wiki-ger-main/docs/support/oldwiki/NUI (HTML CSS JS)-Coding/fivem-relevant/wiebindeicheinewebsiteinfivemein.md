
>[!info] Um alles auf dieser Seite zu verstehen, empfehle ich dir, im Vorhinein [[HTML-Anfänge]], [[CSS-Anfänge]], [[JavaScript-Anfänge]] und [[Wie ist eine Website aufgebaut]] zu lesen!

# Einbindung einer Website in ein FiveM-Script

In **FiveM** ist es möglich, Websites in deine Server-Ressourcen oder Skripte einzubinden. Dies ermöglicht es dir, Informationen, Benutzeroberflächen und mehr direkt im Spiel anzuzeigen.

## Schritt 1: Erstelle eine HTML-Seite

Bevor du eine Website in dein FiveM-Skript einbindest, erstelle eine HTML-Seite, die den Inhalt enthält, den du im Spiel anzeigen möchtest. Du kannst die HTML-Seite mit den gewünschten Elementen wie Text, Bilder, Formulare usw. gestalten.

## Schritt 2: Speichere die HTML-Seite in deinem Ressourcenordner

Die HTML-Datei sollte im Ressourcenordner deines FiveM-Servers oder Skripts gespeichert werden. Dieser Ordner kann je nach deiner FiveM-Konfiguration unterschiedlich benannt sein.

## Schritt 3: Erstelle ein Skript, um die Website einzubinden

Jetzt kannst du ein Lua-Skript erstellen, um die HTML-Seite in dein FiveM-Spiel zu integrieren. Hier ist ein einfaches Beispiel, das auf das Ausführen eines Befehls reagiert:

```lua
-- In deinem __resource.lua oder fxmanifest.lua:
files {
    'pfad/zur/deine-seite.html',
}
```

```lua
-- In deinem Lua-Skript:
RegisterCommand('zeigeWebsite', function()
    TriggerEvent('zeigeWebsite')
end, false)

RegisterNetEvent('zeigeWebsite')
AddEventHandler('zeigeWebsite', function()
    SendNUIMessage({
        type = 'open_website',
        url = 'https://deine-website.deine-seite.html'
    })
    SetNuiFocus(true, true)
end)
```

## Schritt 4: Stelle die Webschnittstelle in deinem JavaScript-Code bereit

In deiner HTML-Seite und in deinem JavaScript-Datei kannst du die Kommunikation mit FiveM einrichten. Hier ist ein Beispiel, wie die `deine-seite.html` und `deine-skript.js` aussehen könnten:

**deine-seite.html**:

```html
<!DOCTYPE html>
<html>
<head>
   
</head>
<body>
    <h1>Willkommen auf meinem FiveM-Server</h1>
</body>
</html>
```

Wenn wir jetzt das Skript starten, sehen wir einen weißen Bildschirm und den Text "Willkommen auf meinem FiveM-Server". Dies geschieht, da die Website jetzt geladen ist. Aber wie bauen wir sie jetzt um, damit sie sich nicht immer zeigt? Das zeige ich euch hier!

Zuerst erstellt ihr euch euer JavaScript in dem gleichen Ordner, wo die HTML-Datei drin ist. In unserem Beispiel nennen wir es "index.js".

Nun fügt ihr diese Zeile ganz oben in eure HTML-Datei ein, zwischen `<head>` und `</head>`:

```html
<script src="index.js"></script>
```

Am besten ersetzt ihr "index.js" durch den Namen eurer JavaScript-Datei.

Jetzt könnt ihr in eurer JavaScript-Datei zuerst folgende Zeile hinzufügen:

```javascript
document.body.style.display = 'none'; // Versteckt den gesamten Körper
```

Was das macht, ist, dass, sobald die Website geladen ist, ein CSS-Code hinzugefügt wird, der bewirkt, dass der Körper (die gesamte Website) nicht angezeigt wird.

Mit folgender Zeile könnt ihr den Körper wieder sichtbar machen:

```javascript
document.body.style.display = 'block'; // Zeigt den gesamten Körper wieder
```

Ihr möchtet jedoch, dass der Körper vorerst unsichtbar ist, sobald das Skript gestartet wird.

Um jetzt das Skript sichtbar zu machen, wenn ihr z.B. im Spiel den Befehl "/tablet" eingebt, müsst ihr NUI-Callbacks hinzufügen.

# Was sind NUI-Callbacks?

NUI-Callbacks, wie in [[was ist..]] erklärt, sind eine Möglichkeit, von eurem JavaScript zu eurer Lua zu sprechen und Dinge auszuführen. Im Grunde genommen sind sie wie Callbacks, die speziell für NUI-Anwendungen verwendet werden.

## Wie benutzt man einen NUI-Callback?

Wir setzen unser Beispiel fort, bei dem wir möchten, dass die Website im Spiel angezeigt wird, wenn der Befehl "/tablet" ausgeführt wird. Das funktioniert im Lua-Code wie folgt:

```lua
RegisterCommand(function(source, args, rawCommand)
    SendNUIMessage({
        show = true
    })
end)
```

Anstelle von "show" könnt ihr jeden gewünschten Wert verwenden. Jetzt senden wir "show = true" an das JavaScript.

("SetNuiFocus" aktiviert die Maus.)

Diese Nachricht wird im JavaScript abgefangen und sieht wie folgt aus:

```javascript
window.addEventListener('message', (event) => {
    var data = event.data; // Hier definieren wir das Table, das wir von der Lua-Seite erhalten

    if (data.show === true) {
        // Wenn "show = true"
        document.body.style.display = 'block'; // Zeigt den gesamten Körper
    } else {
        // Andernfalls
        document.body.style.display = 'none'; // Versteckt den gesamten Körper wieder
    }
});
```

Jetzt könnt ihr per Lua-Code steuern, wann die Website im Spiel angezeigt