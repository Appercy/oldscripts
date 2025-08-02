# Was ist ein Submenu?

Ein Submenu ist ein Menü innerhalb eines Menüs. Du kannst es verwenden, wenn du beispielsweise ein zusätzliches Menü für jedes einzelne Item in deinem Inventar erstellen möchtest.

Ein Submenu erstellst du wie folgt:

```lua
submenu = _menuPool:AddSubMenu(mainmenu, "Name", "Beschreibung")
```

Bei der Erstellung eines Submenus müssen die folgenden Informationen hinzugefügt werden (die mit einem * markierten sind zwingend erforderlich):

- * Das Hauptmenü, zu dem das Submenu gehört
- * Der Name des Menüs
- * Die Beschreibung des Menüs
-  KeepPosition (ob es die Position behalten soll) (true oder false)
- KeepBanner (ob es das Banner vom Hauptmenü verwenden soll) (true oder false)

>[!information] Wenn du ein Item hinzufügen oder andere Funktionen zum Submenu hinzufügen möchtest, musst du es mit dem Menünamen (in unserem Fall `submenu.SubMenu`) wie folgt anfordern: (Alle Funktionen die auf das normale menü gehen gehen auch auf Submenus in diesem fall)

```lua
submenu.SubMenu:AddItem(item)
```

> [!info] Wenn du das Item im Submenu bearbeiten möchtest, gehst du genauso vor, wie bei jedem anderem normalem item jedoch mit `SubMenu.Item`:

```lua
Submenu.Item:RightLabel("hah!")
```
