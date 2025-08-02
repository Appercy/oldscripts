>[!info] um diese Website zu verstehen solltest du zuerst [[html anfänge]] gelesen haben


Nachdem du die Grundlagen von HTML verstanden hast, ist es an der Zeit, dich mit den Grundlagen von CSS (Cascading Style Sheets) vertraut zu machen. CSS ist eine wichtige Technologie, die verwendet wird, um das Aussehen und die Formatierung von Webseiten zu gestalten.

## Was ist CSS?

CSS ist die Abkürzung für "Cascading Style Sheets" und ermöglicht es, das Erscheinungsbild von HTML-Elementen zu gestalten. Mit CSS kannst du Farben, Schriftarten, Abstände und viele andere visuelle Eigenschaften von Webseiten definieren.

# 

## Verknüpfung von HTML und CSS

Um deiner Webseite das Aussehen zu geben, das du möchtest, musst du CSS verwenden. Hier ist, wie du es in deine HTML-Seite einfügst:

1. **Öffne deine HTML-Datei:** Wenn du deine Webseite bearbeiten möchtest, öffne die entsprechende HTML-Datei in einem Texteditor.

2. **Finde den `<head>`-Bereich:** In deiner HTML-Datei gibt es einen Bereich namens `<head>`. Hier platzierst du zusätzliche Informationen, die deine Webseite betreffen, wie zum Beispiel CSS.

3. **CSS intern einfügen:** Wenn du CSS nur für diese eine Seite verwenden möchtest, füge es direkt im `<head>`-Bereich ein, indem du es zwischen `<style>`-Tags schreibst, so:

```html
<head>
    <style>
        /* Hier kommt dein CSS-Code hin */
    </style>
</head>
```

4. **CSS extern verlinken:** Wenn du planst, CSS auf mehreren Seiten zu verwenden, speichere es in einer separaten CSS-Datei und verlinke diese Datei mit deiner HTML-Seite, wie hier:

```html
<head>
    <link rel="stylesheet" type="text/css" href="dein-css-dateiname.css">
</head>
```

Das ist im Grunde genommen alles, um CSS in deine Webseite zu integrieren und sie zu gestalten, 



# Beispielaufgabe
Klar, hier ist eine vereinfachte Version des Textes:

"Du hast die Wahl, ob du deinen CSS-Code in einer separaten .css-Datei speichern möchtest oder ihn direkt zwischen den `<style></style>`-Tags in deiner HTML-Datei platzierst.

Die Aufgabe besteht darin, unseren Text einen grünen Hintergrund zu geben und ihn größer erscheinen zu lassen!

So geht's:

In unserem `<style></style>`-Bereich oder in unserer CSS-Datei schreiben wir folgendes:

```css
body {
  /* Hier geben wir Anweisungen */
}
```

Wir wählen `body`, da wir unseren Text im `<body>`-Tag platziert haben. Wenn er sich an anderer Stelle befinden würde, würden wir stattdessen einen anderen Auswahlnamen verwenden. Dann fügen wir zwei geschweifte Klammern hinzu, um unsere Anweisungen einzufügen.

Hier ist eine wichtige Information: In CSS wird jede Anweisung mit einem Semikolon (`;`) abgeschlossen.

Nun wollen wir, dass unser Hintergrund grün wird. Das erreichen wir so:

```css
body {
  background-color: green;
}
```

Wenn wir jetzt speichern und die Vorschau in unserem Live-Server aktualisieren, sehen wir, dass der grüne Hintergrund die gesamte Webseite einnimmt. Aber warum ist das so? Das liegt daran, dass die Anweisung `body { background-color: green; }` besagt, dass der Hintergrund für den gesamten `<body>`-Bereich der Webseite grün sein soll. Der `<body>`-Bereich erstreckt sich über die gesamte Seite, daher wird der Hintergrund der gesamten Webseite grün.

Aber was ist mit der Textgröße? Nun, um den Text größer zu machen, können wir folgendes tun:

```css
body {
  background-color: green;
  font-size: 20px;
}
```

Hier haben wir die Eigenschaft `font-size` hinzugefügt und ihr den Wert `20px` gegeben. Das bedeutet, dass der Text auf der Webseite jetzt größer erscheinen wird, da die Schriftgröße auf 20 Pixel festgelegt ist.

Speichere deine Änderungen und aktualisiere die Webseite auf deinem Live-Server erneut. Du solltest jetzt sehen, dass der Text einen grünen Hintergrund hat und größer ist.

Das ist eine grundlegende Einführung in die Verwendung von CSS, um das Aussehen deiner Webseite anzupassen. Mit CSS kannst du viele weitere Anpassungen vornehmen, wie Farben ändern, Abstände einstellen und vieles mehr. Es ist ein mächtiges Werkzeug, um deine Webseite nach deinen Vorstellungen zu gestalten."

Falls du noch weitere Fragen hast oder mehr über CSS erfahren möchtest, stehe ich gerne zur Verfügung.


## Weiterführende Ressourcen

- [W3Schools CSS-Tutorial](https://www.w3schools.com/css/)
- [MDN Web Docs CSS](https://developer.mozilla.org/en-US/docs/Web/CSS)

Jetzt, da du die Grundlagen von HTML und CSS kennst, bist du bereit, tiefer in die Webentwicklung einzusteigen und dein Wissen weiter auszubauen.



