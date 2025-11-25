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





function SitAnywhere.context(plNum, context, worldobjects, test)
    local pl = getSpecificPlayer(plNum)
    if not pl then return end

    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end

    local playerData = pl:getModData()
    if playerData.IsSittingOnSeat then return end

    local Main = context:addOptionOnTop("Sit Anywhere")
    Main.iconTexture = getTexture("media/ui/chop_tree.png")
    local opt = ISContextMenu:getNew(context)
    context:addSubMenu(Main, opt)

    local sitFaceDir = {"N","S","E","W"}
    for _,dir in ipairs(sitFaceDir) do
        opt:addOption(dir, worldobjects, function()
            local cursor = SitAnywhere_Cursor:new(pl, dir)
            getCell():setDrag(cursor, plNum)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
    end

    if SandboxVars.SitAnywhere.DisableLifestyleSitMenu then
        local list = {
            "ContextMenu_Sit_Action",
            "ContextMenu_Sit_Action_Couch",
            "ContextMenu_Sit_Action_Stool"
        }
        for _,str in ipairs(list) do
            local opt2 = context:getOptionByName(getText(str))
            if opt2 then
                opt2.notAvailable = true
            end
        end
    end
end

Events.OnFillWorldObjectContextMenu.Remove(SitAnywhere.context)
Events.OnFillWorldObjectContextMenu.Add(SitAnywhere.context)

-----------------------            ---------------------------
