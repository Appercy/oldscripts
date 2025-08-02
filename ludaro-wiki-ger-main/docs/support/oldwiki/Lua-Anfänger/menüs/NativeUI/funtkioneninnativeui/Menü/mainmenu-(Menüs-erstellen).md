In diesem Abschnitt werde ich dir zeigen, wie du ein Menü erstellen kannst.

## Menü erstellen

Das gesamte Menü wird mit dieser Zeile erstellt:

```lua
mainmenu = NativeUI.CreateMenu("Name", "Beschreibung")
```

In `NativeUI.CreateMenu` kannst du folgende Informationen einfügen (in dieser Reihenfolge), wobei einige mit einem * markiert sind diese müssen Angegeben werden:

- Name (als Überschrift)*
- Beschreibung *
- X-Koordinate
- Y-Koordinate
- TxtDictionary
- TxtName 
- Überschrift (Heading)
- Rote Farbkomponente (Rot)
- Grüne Farbkomponente (Grün)
- Blaue Farbkomponente (Blau)
- Alpha-Wert (Transparenz)

Um das Menü anzuzeigen, füge die folgenden Zeilen hinzu:

```lua
_menuPool:RefreshIndex() -- Aktualisiert den Pool, um das Menü hinzuzufügen

_menuPool:MouseControlsEnabled(false) -- Deaktiviert die Maus, damit wir uns frei bewegen können

_menuPool:MouseEdgeEnabled(false) -- Verhindert, dass die Maus den Bildschirm verlässt

_menuPool:ControlDisablingEnabled(false) -- Aktiviert die Steuerung, sodass nicht alle Steuerelemente deaktiviert werden

mainmenu:Visible(true) -- Macht unser Menü sichtbar
```

Beachte dabei, dass `mainmenu` dem Namen deines Menüs von oben entsprechen muss!