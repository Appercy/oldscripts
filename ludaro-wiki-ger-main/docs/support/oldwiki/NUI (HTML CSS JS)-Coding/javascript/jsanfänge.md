
>[!info]
> Um diese Seite zu verstehen, solltest du zuerst [[HTML-Anfänge]] und [[CSS-Anfänge]] gelesen haben.

# JavaScript-Anfänge

Nachdem du die Grundlagen von HTML und CSS gelernt hast, ist es an der Zeit, dich mit JavaScript vertraut zu machen. JavaScript ist eine Programmiersprache, die es ermöglicht, interaktive und dynamische Elemente zu deiner Webseite hinzuzufügen.

## Was ist JavaScript?

JavaScript ist eine weit verbreitete Programmiersprache, die in Webbrowsern ausgeführt wird. Mit JavaScript kannst du auf Elemente deiner Webseite zugreifen, sie ändern und auf Benutzeraktionen reagieren.

## Verknüpfung von HTML, CSS und JavaScript

Um JavaScript in deine Webseite zu integrieren, kannst du es direkt in deiner HTML-Datei hinzufügen. In der Regel platziert man den JavaScript-Code kurz vor dem schließenden `</body>`-Tag.

Hier ist ein einfaches Beispiel, wie du JavaScript in deine HTML-Seite einbindest:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Meine Webseite</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <!-- Hier ist der HTML-Inhalt deiner Webseite -->

    <script>
        // Hier kommt dein JavaScript-Code hin
    </script>
</body>
</html>
```

## Aufgabe: Text ändern mit JavaScript

In deinem HTML-Dokument aus dem vorherigen Tutorial haben wir einen Text mit einem grünen Hintergrund erstellt. Jetzt möchten wir diesen Text mit JavaScript ändern.

Deine Aufgabe besteht darin, den Text mit JavaScript in einen blauen Text umzuwandeln, wenn der Benutzer auf ihn klickt.

Hier ist ein Hinweis, wie du das machen kannst:

mit 
```js
// Finde das Element, auf das geklickt werden soll
// body p steht hier für unseren text
var textElement = document.querySelector('p');
```

definierst du deinen text als element (auszuwählen an p)

mit
```js
// Füge einen Eventlistener hinzu, um auf Klicks zu reagieren
textElement.addEventListener('click', function() {
    // Ändere den Text auf blau
    textElement.style.color = 'blue';
});
```
erstellst du einen sogennanten "EventListener" dieser Lauscht nach sachen die passieren, und Reagiert nur wenn etwas passiert was ihm angegeben wird (in unserem fall click!) und wenn click benutzt wird wird
```js
    // Ändere den Text auf blau
    textElement.style.color = 'blue';
```
ausgeführt, und dein Text wird somit zu blau geändert :) (wie wenn du in css color = "blue" eingeben würdest)

```js
// Finde das Element, auf das geklickt werden soll
// body p steht hier für unseren text
var textElement = document.querySelector('p');

// Füge einen Eventlistener hinzu, um auf Klicks zu reagieren
textElement.addEventListener('click', function() {
    // Ändere den Text auf blau
    textElement.style.color = 'blue';
});
```

Erstelle den JavaScript-Code, füge ihn in deine HTML-Datei ein und aktualisiere deine Webseite auf deinem Live-Server, um zu sehen, wie der Text auf Klicks reagiert und die Farbe ändert.

Das ist eine einfache Einführung in JavaScript. Mit JavaScript kannst du viel mehr tun, um deine Webseite zu dynamisieren und Benutzerinteraktionen hinzuzufügen. Viel Spaß beim Programmieren!