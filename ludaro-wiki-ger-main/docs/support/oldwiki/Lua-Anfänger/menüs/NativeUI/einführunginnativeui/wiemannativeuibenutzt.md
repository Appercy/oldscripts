Wie man zum verdammten Bumbatz dieses Menü benutzt >-<

**NativeUI** und **NativeUIReloaded** sind fast die gleichen mit einigen kleinen Feature- und Performance-Unterschieden. Ich würde empfehlen, **NativeUIReloaded** zu verwenden, wenn möglich, aber beide arbeiten mit dem gleichen Code (außer dem fxmanifest).

Um **NativeUI** oder **NativeUIReloaded** (ich werde beide als **NativeUI** bezeichnen) zu verwenden, muss man sie erst einmal herunterladen. Es ist sehr, sehr wichtig, sie nicht umzubenennen, da sie Exporte verwenden und sonst nicht funktionieren!

Wenn du beide in deinem Skript verwenden möchtest, solltest du zwei Dinge tun:

1. Die fxmanifest einstellen

   Wenn du **NativeUI** benutzen möchtest, geh in deine fxmanifest und unter `client_scripts` musst du eintragen:

   ```markdown
   client_scripts {
       '@NativeUI/NativeUI.lua',
       'client.lua' -- your client scripts here
   }
   ```

   Wenn du **NativeUIReloaded** benutzen möchtest, geh in deine fxmanifest und unter `client_scripts` musst du eintragen:

   ```markdown
   client_scripts {
       '@NativeUILua_Reloaded/src/NativeUIReloaded.lua',
       'client.lua' -- your client scripts here
   }
   ```

   Für diesen Schritt (nach fxmanifest) und alle anderen Schritte ist es egal, welche **NativeUI**-Version du hast. Wenn es einen Unterschied gibt, werde ich ihn durch diese Warnungen hervorheben.

2. **NativeUI** Benutzen!

   Um **NativeUI** zu benutzen, müssen wir es erst an der obersten Stelle des Scripts initialisieren/deklarieren (alles wird in der `client.lua` gemacht).

   `_menuPool` kann umbenannt werden zu egal was du möchtest. Ich nenne es nur `menuPool`, weil ich das so gelernt habe. Dieser Code sollte über deinem Menü in der `client.lua` stehen:

   ```markdown
   _menuPool = NativeUI.CreatePool()
   ```

   Danach erstellen wir einen Thread, um das Menü jede Millisekunde aufzurufen (zum Aktualisieren). Du kannst auch einen schon verwendeten Thread benutzen, solange er keine `Wait()` Argumente beinhaltet.

   ```markdown
   Citizen.CreateThread(function()
       while true do
           Citizen.Wait(1)
           if _menuPool:IsAnyMenuOpen() then
               _menuPool:ProcessMenus()
           else
               Citizen.Wait(150) -- this small line is making it more performant than ever!
           end
       end
   end)
   ```

   Jetzt, da wir **NativeUI** im Script haben, können wir jetzt anfangen mit dem...

# Erstellen des NativeUI Menüs

Um jetzt einmal zu erläutern, wie man ein Menü benutzt, erstellen wir ein Menü, das ein Menü öffnet, wenn wir "E" drücken.

Um zu wissen, wie man das Menü erstellt und andere Dinge, sollte man erstmal meine Nutzvollen-Infos für Lua Anfänger Durchlesen, wenn man sich nicht vertraut fühlt.

Zuallererst erstellen wir eine Funktion für das Menü, damit wir es später wieder aufrufen können.

Trage statt "YOUR MENU NAME" und "YOUR MENU DESCRIPTION" deinen Menünamen und Beschreibung rein:

```markdown
function OpenMenu()
    mainmenu = NativeUI.CreateMenu("YOUR MENU NAME","YOUR MENU DESCRIPTION")
    _menuPool:Add(mainmenu)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
    mainmenu:Visible(true)
end
```

Diese Funktion heißt für uns `OpenMenu()`. `OpenMenu()` und `mainmenu` sind nur Namen, die ich so nenne. Du kannst diese umbenennen, wie du willst. Das war's, du hast dein erstes Menü, leicht, nicht wahr? ❤️ Was für eine Legende du bist!

# Benutzung des NativeUI Menüs

Lass uns jetzt mal sagen, wir wollen es nur öffnen, wenn...

```markdown
local Truckmenu = vector3(1233.8623, -3235.2698, 5.5287)
```

Statt `Truckmenu` kannst du eine Koordinate nehmen, die du möchtest.

```markdown
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local pedCoord = GetEntityCoords(PlayerPedId())
        if #(Truckmenu - pedCoord) < 3.0 then
            ESX.ShowHelpNotification("Drücke Hier um dein Truckermenü zu Öffnen! ❤️") -- zeigt eine Nachricht links oben
            if IsControlJustReleased(0, 38) then
                OpenMenu()
            end
        end
    end
end)
```

```markdown
Citizen.CreateThread(function()
    while true do
        _menuPool:ProcessMenus()
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if isPedInAnyVehicle(ped) then
            if IsControlJustReleased(0, 38) then
                OpenMenu()
            end
        end
    end
end)
```

Der Code ist geklaut von meinem Truckermenü. Das war's, wir haben unser erstes Menü erstellt. Wie man Items macht und andere Dinge wird in weiteren Titeln erklärt! ❤️

Wenn du sonst noch Fragen hast, habe keine Angst mir auf Discord zu schreiben oder mich auf meinen Discord anzuschreiben und dort zu fragen! ❤️

Downloade dir **NativeUI** [hier](https://example.com) oder **NativeUIReloaded** [hier](https://example.com).
```

Bitte ersetze die Platzhalter "YOUR MENU NAME" und "YOUR MENU DESCRIPTION" durch die tatsächlichen Menüinformationen und die Links am Ende des Textes mit den entsprechenden Download-Links.