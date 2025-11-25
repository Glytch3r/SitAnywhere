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



function SitAnywhere.walkToFront(pl, sq, dir)
    pl = pl or getPlayer()
    
    sq = sq or pl:getSquare()
	dir = dir or "S"
	if AdjacentFreeTileFinder.privTrySquare(sq, dir) then
		ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, dir))
		return true
	end
	return false
end


function SitAnywhere.getTurnVar(pl)
    pl = pl or getPlayer()
    SitAnywhere.td = SitAnywhere.td or pl:getTurnDelta()
    return SitAnywhere.td
end
--[[ 
function SitAnywhere.dbg(pl)
	pl = pl or getPlayer()
	if not pl then return end
	if not pl:isAlive() then return end
	local s1 = pl:getVariableString("SittingToggleStart")
	local s2 = pl:getVariableString("SittingToggleLoop")
	local s3 = pl:getVariableString("IsSittingInChair")
	local msg = 'SittingToggleStart:  '..tostring(s1) ..'\nSittingToggleLoop:  '..tostring(s2) ..'\nIsSittingInChair:  '..tostring(s3)
    return msg
end ]]

function SitAnywhere.setTurnVar(pl, isStop)
    pl = pl or getPlayer()
    local speed = SitAnywhere.getTurnVar(pl)
    if isStop then
        speed = 0 
    end
    if pl:getTurnDelta() ~= speed then
        pl:setTurnDelta(speed)        
    end
end

function SitAnywhere.disabler(pl)
    local state = SitAnywhere.getState()     
    pl = pl or getPlayer()
    if state then
        local isStop = false
        if tostring(state) == 'PlayerSitOnGroundState' and pl:getVariableString("IsSittingInChair") ~= nil then
           -- pl:setBlockMovement(true)
            --pl:setIgnoreInputsForDirection(true);
            --pl:nullifyAiming()
            isStop = true
            if getCore():getDebug() then 
                local msg = SitAnywhere.dbg(pl)
                pl:setHaloNote(tostring(cls)..'\n'..tostring(SitAnywhere.dbg(pl)),150,250,150,300) 
            end	
        else
            pl:setVariable("forceGetUp", true)
            --pl:setIgnoreInputsForDirection(false);
            --pl:setBlockMovement(false)

        end
        --SitAnywhere.setTurnVar(pl, isStop)
    end
end
--[[ 
    local pl = getPlayer() 
    pl:setVariable("forceGetUp", true)
    pl:setIgnoreInputsForDirection(false);
    pl:setBlockMovement(false)
 ]]
--[[ 
Events.OnPlayerUpdate.Remove(SitAnywhere.disabler)
Events.OnPlayerUpdate.Add(SitAnywhere.disabler)
 ]]
function SitAnywhere.getState(pl)
    pl = pl or getPlayer()
    local s = tostring(pl:getCurrentState())
    local cls = s:match("([^@]+)"):match("([^.]+)$")
    --print(cls)

    if getCore():getDebug() then 
        local msg = SitAnywhere.dbg(pl)
        pl:setHaloNote(tostring(cls)..'\n'..tostring(SitAnywhere.dbg(pl)),150,250,150,300) 
    end	

    return cls or nil
end




function SitAnywhere.RequireAdmminSetup()
    return SandboxVars.SitAnywhere.RequireAdmminSetup
end

function SitAnywhere.DisableLifestyleSitMenu()
    return SandboxVars.SitAnywhere.DisableLifestyleSitMenu
end

function SitAnywhere.isAdm()
    local pl = getPlayer()
    return pl and ((string.lower(pl:getAccessLevel()) == "admin") or (isClient() and isAdmin()))
end


function SitAnywhere.getFrontSq(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return nil end
    local csq = pl:getCurrentSquare()
    return csq and csq:getAdjacentSquare(pl:getDir()) or nil
end

function SitAnywhere.getSprName(obj)
    if not obj then return nil end
    local spr = obj:getSprite()
    return spr and spr:getName() or nil
end

function SitAnywhere.GetObjClass(obj)
    if not obj or not obj.getClass then return nil end
    local cls = tostring(obj:getClass())
    return cls:match("([^%.]+)$") or cls
end
