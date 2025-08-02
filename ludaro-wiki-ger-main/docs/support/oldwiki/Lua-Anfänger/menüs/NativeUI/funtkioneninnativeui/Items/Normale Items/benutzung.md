# Grundlegende Elemente

Grundlegende Elemente sind einfach Ihre allgemeinen Schaltflächen, und hier erfahren Sie, wie Sie sie hinzufügen und verwenden können:

Angenommen, Ihr Menü in Schritt eins heißt `mainmenu`. Wenn Sie ein Element hinzufügen möchten, schreiben Sie einfach (unter den Code, der Ihr `mainmenu` erstellt hat):

```lua
local deinNameFuerDeinElementHier = NativeUI.CreateItem("SeitenName", "beschreibung")
mainmenu:AddItem(deinNameFürDeinElementHier)
```

`deinNameFürDeinElementHier` kann durch jeden Namen ersetzt werden. Er dient nur dazu, das Element zu identifizieren, das Sie verwenden möchten. Ersetzen Sie ihn durch den Namen Ihres Elements.

Angenommen, wir möchten, dass beim Drücken der Schaltfläche der Spieler zu den Koordinaten 0, 0, 0 teleportiert wird. Dann sollten wir es folgendermaßen tun:

```lua
deinNameFuerDeinElementHier.Activated = function(sender, index)
  -- Alles hier drin wird ausgelöst, wenn das Element gedrückt (aktiviert) wird
  SetEntityCoords(PlayerPedId(), 0, 0, 0, 0, 0, 0, false)
  print("Du bist jetzt bei 0 0 0 haha!") 
end
-- Alles nach dem "end" wird ausgeführt, aber alles in der "Activated"-Funktion wird nur ausgeführt, wenn das Element Aktiviert wird
```

Das war's! Einfach im Spiel verwenden.