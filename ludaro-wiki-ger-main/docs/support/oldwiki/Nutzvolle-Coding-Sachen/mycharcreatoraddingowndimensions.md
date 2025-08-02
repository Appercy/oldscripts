
# 1. Making sure you have everything

if you have installed MyMulticharV3 you dont have to do step 2, you can skip to step 3

if you dont have MyMulticharv3 Installed then you have to do whats said in step 2

# 2. Adding a Bucket System to myCharcreator

### 1. Download the BUCKETS.lua
[download it here](https://drive.google.com/file/d/1GDWGnFXEDRkA6j55jMJVxzwBT7hO3Y9F/view?usp=drive_link)
(might require additional approval of me)
![[BUCKETS.lua]]
### 2. Install the Buckets.lua into myCharcreator
put it inside your script folder (myCharCreator) 
and then..

in your fxmanifest.lua you will find code that looks like this
```lua
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua',
  }
```

replace it with this:
```lua
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua',
	'BUCKETS.lua',
  }
```

now you have added buckets functionality to your mycharcreator
(buckets = dimensions) now we need to implement it in the script itself!

# 3. Implementing it into MyCharCreator

in your client.lua from myCharCreator search for this code,
![[Pasted image 20240109192627.png]]
and add the red circled code to yours!
```lua
 TriggerServerEvent("einreise:setroutingbucket")
```
(here is it again to copy)
```lua
 createmenu.OnMenuClosed = function(sender, item, index)
		DeleteSkinCam()
        TriggerServerEvent("einreise:resetroutingbucket")
    end
```
(here aswell)


and now you search for..
```lua
    saveItem.Activated = function(sender, item, index)

            FreezeEntityPosition(PlayerPedId(), false)

            mainMenu:Visible(false)

            TriggerEvent('skinchanger:getSkin', function(finalSkin)

                TriggerServerEvent('register:saveSkin', finalSkin)

                -- TriggerEvent('mySpawnSelector:open')

                --generateClothesMenu()

            end)
         
```

and replace it with..
```lua
    saveItem.Activated = function(sender, item, index)

            FreezeEntityPosition(PlayerPedId(), false)

            mainMenu:Visible(false)
			TriggerServerEvent("einreise:resetroutingbucket")
            TriggerEvent('skinchanger:getSkin', function(finalSkin)

                TriggerServerEvent('register:saveSkin', finalSkin)

                -- TriggerEvent('mySpawnSelector:open')

                --generateClothesMenu()

            end)
```

and voila!
:)