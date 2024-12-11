-- Set the FX version and game type
fx_version "cerulean"
game "gta5"
lua54 "yes"
name "Ludaro MyCharCreator V3"
-- Resource metadata
author "Ludaro // Luiis"
description "ahah"
version "beta01"
-- github "https://github.com/waschmaschvanlu/Ludaro-Versions/tree/main"
-- fx_raw "https://raw.githubusercontent.com/waschmaschvanlu/Ludaro-Versions/main/myMulticharV2.lua"
-- changelogfile "https://raw.githubusercontent.com/waschmaschvanlu/Ludaro-Versions/main/myMultiCharV2Changelog.lua"


client_scripts {
    "shared/*.lua",
    "client/open/translation.lua",
    "NativeUILua/Wrapper/Utility.lua",
    "NativeUILua/UIElements/UIVisual.lua",
    "NativeUILua/UIElements/UIResRectangle.lua",
    "NativeUILua/UIElements/UIResText.lua",
    "NativeUILua/UIElements/Sprite.lua",
    "NativeUILua/UIMenu/elements/Badge.lua",
    "NativeUILua/UIMenu/elements/Colours.lua",
    "NativeUILua/UIMenu/elements/ColoursPanel.lua",
    "NativeUILua/UIMenu/elements/StringMeasurer.lua",
    "NativeUILua/UIMenu/items/UIMenuItem.lua",
    "NativeUILua/UIMenu/items/UIMenuCheckboxItem.lua",
    "NativeUILua/UIMenu/items/UIMenuListItem.lua",
    "NativeUILua/UIMenu/items/UIMenuSliderItem.lua",
    "NativeUILua/UIMenu/items/UIMenuSliderHeritageItem.lua",
    "NativeUILua/UIMenu/items/UIMenuColouredItem.lua",
    "NativeUILua/UIMenu/items/UIMenuProgressItem.lua",
    "NativeUILua/UIMenu/items/UIMenuSliderProgressItem.lua",
    "NativeUILua/UIMenu/windows/UIMenuHeritageWindow.lua",
    "NativeUILua/UIMenu/panels/UIMenuGridPanel.lua",
    "NativeUILua/UIMenu/panels/UIMenuHorizontalOneLineGridPanel.lua",
    "NativeUILua/UIMenu/panels/UIMenuVerticalOneLineGridPanel.lua",
    "NativeUILua/UIMenu/panels/UIMenuColourPanel.lua",
    "NativeUILua/UIMenu/panels/UIMenuPercentagePanel.lua",
    "NativeUILua/UIMenu/panels/UIMenuStatisticsPanel.lua",
    "NativeUILua/UIMenu/UIMenu.lua",
    "NativeUILua/UIMenu/MenuPool.lua",
    'NativeUILua/UITimerBar/UITimerBarPool.lua',
    'NativeUILua/UITimerBar/items/UITimerBarItem.lua',
    'NativeUILua/UITimerBar/items/UITimerBarProgressItem.lua',
    'NativeUILua/UITimerBar/items/UITimerBarProgressWithIconItem.lua',
    'NativeUILua/UIProgressBar/UIProgressBarPool.lua',
    'NativeUILua/UIProgressBar/items/UIProgressBarItem.lua',
    "NativeUILua/NativeUI.lua",
    -- '@NativeUILua_Reloaded/src/NativeUIReloaded.lua',
    "client/open/*.lua",
    "client/closed/*.lua"
}
shared_scripts {
    '@es_extended/imports.lua',
    "shared/*.lua",
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    "shared/*.lua",
    "server/open/*.lua"
}



escrow_ignore {
    "client/open/*.lua",
    "server/open/*.lua",
    "shared/default.lua",
    "shared/*.lua",
}


dependencys {
    '/assetpacks',
    "bob74_ipl",
}
