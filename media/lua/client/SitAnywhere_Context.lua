----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------
SitAnywhere = SitAnywhere or {}


SitAnywhere.dirIcons ={
    ['N'] = getTexture("media/ui/LootableMaps/map_arrownortheast.png"),
    ['W'] = getTexture("media/ui/LootableMaps/map_arrownorthwest.png"),
    ['E'] = getTexture("media/ui/LootableMaps/map_arrowsoutheast.png"),
    ['S'] = getTexture("media/ui/LootableMaps/map_arrowsouthwest.png")
}
SitAnywhere.fStr ={
    ['N'] = "North",
    ['W'] = "West",
    ['E'] = "East",
    ['S'] = "South"
}

SitAnywhere.sitFaceDir = {"N","S","E","WE"}



function SitAnywhere.context(plNum, context, worldobjects, test)


    local pl = getSpecificPlayer(plNum)
    if not pl then return end

    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end

    local md = pl:getModData()
    --if md.IsSittingOnSeat then return end

    local Main = context:addOptionOnTop("Sit Anywhere")
    Main.iconTexture = getTexture("media/ui/Moodles/ComfortGold.png")
    local opt = ISContextMenu:getNew(context)
    context:addSubMenu(Main, opt)

    for _, dir in ipairs(SitAnywhere.sitFaceDir) do
        dir = dir:sub(1,1)
        local caption = SitAnywhere.fStr[dir]
        local op =  opt:addOption(tostring(caption), worldobjects, function()
            print(dir)
            local cursor = SitAnywhere_Cursor:new(pl, dir)            
            getCell():setDrag(cursor, plNum)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            --Events.OnTick.Add(SitAnywhere.tickFunc)
            context:hideAndChildren()
        end)
        op.iconTexture = SitAnywhere.dirIcons[tostring(dir)]
    end

    if SandboxVars.SitAnywhere.DisableLifestyleSitMenu then
        local list = {
            getText("ContextMenu_Sit_Action"),
            getText("ContextMenu_Sit_Action_Couch"),
            getText("ContextMenu_Sit_Action_Stool"),
            getText("ContextMenu_Sit_Info"),
        }


        for _, str in ipairs(list) do
            local opt2 = context:getOptionFromName(str)
            if opt2 then
                context:removeOptionByName(str)
                local opt3 =  context:addOptionOnTop(str, worldobjects, nil)                
                opt3.notAvailable = true
                opt3.iconTexture = getTexture('media/ui/moodles/ComfortRed.png')
                local tooltip = ISToolTip:new();
                tooltip:initialise();
                tooltip.description = "Disabled by SitAnywhere Mod Sandbox Options"
                opt3.toolTip = tooltip
            end
        end

    end



end

Events.OnFillWorldObjectContextMenu.Remove(SitAnywhere.context)
Events.OnFillWorldObjectContextMenu.Add(SitAnywhere.context)

-----------------------            ---------------------------

