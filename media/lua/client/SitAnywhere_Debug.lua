--[[ SitAnywhere = SitAnywhere or {}

SitAnywhere_Action = ISBaseTimedAction:derive("SitAnywhere_Action")

function SitAnywhere_Action:isValid()
    return true
end

function SitAnywhere_Action:waitToStart()
    self.character:faceLocation(self.faceX, self.faceY)
    return self.character:shouldBeTurning()
end

function SitAnywhere_Action:update()
    self.animDelay = self.animDelay + getGameTime():getGameWorldSecondsSinceLastUpdate()
    if self.animDelay >= 15 then
        self:forceComplete()
    end
end

function SitAnywhere_Action:start()
    self:setActionAnim("Bob_IsSitStart")
    self.action:setUseProgressBar(false)
end

function SitAnywhere_Action:stop()
    ISBaseTimedAction.stop(self)
end

function SitAnywhere_Action:perform()
    local animVar = "N"
    local sitAnim = "IsSitting"
    if self.facing == "S" or self.facing == "E" then
        animVar = "S"
        sitAnim = "IsSittingS"
    end
    self.character:setVariable("SittingToggleStart", animVar)
    self.character:setVariable("SittingToggleLoop", animVar)
    self.character:setVariable("IsSittingInChair", sitAnim)

    self.character:reportEvent("EventSitOnGround")
    
    local md = self.character:getModData()
    md.IsSittingOnSeat = true
    md.IsSittingOnSeatSouth = (animVar == "S")
    
    SitAnywhere.SitLoop(self.character, self.facing, self.faceX, self.faceY)
    
    ISBaseTimedAction.perform(self)
end


function SitAnywhere_Action:new(character, facing)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.stopOnWalk = true
    o.stopOnRun = true
    o.stopOnAim = true
    o.maxTime = 3000
    o.facing = facing
    o.animDelay = 0
    
    local px, py = character:getX(), character:getY()
    if facing == "N" then
        o.faceX, o.faceY = px, py - 10
    elseif facing == "S" then
        o.faceX, o.faceY = px, py + 10
    elseif facing == "E" then
        o.faceX, o.faceY = px + 10, py
    elseif facing == "W" then
        o.faceX, o.faceY = px - 10, py
    end
    
    return o
end

function SitAnywhere.sendSitToggleCommand(animVar1, animVar2, animVar3)
    if not isClient() then return end
    if ScanForPlayers then
        ScanForPlayers("ChangeAnimVar", {"SittingToggleStart", animVar1, "SittingToggleLoop", animVar2, "IsSittingInChair", animVar3})
    end
end

function SitAnywhere.SitLoop(pl, facing, faceX, faceY)
    local md = pl:getModData()
    local isRested = false
    
    local animVar = "N"
    local sitAnim = "IsSitting"
    if facing == "S" or facing == "E" then
        animVar = "S"
        sitAnim = "IsSittingS"
    end
    
    SitAnywhere.sendSitToggleCommand(animVar, animVar, sitAnim)
    
    local tickFunc
    tickFunc = function()
        if md.IsSittingOnSeat then

            
            if not pl:hasTimedActions() and not isRested then
                if pl:getStats():getEndurance() < 1 then
                    pl:updateEnduranceWhileSitting()
                else
                    HaloTextHelper.addTextWithArrow(pl, getText("IGUI_HaloNote_WellRested"), true, 80, 200, 0)
                    isRested = true
                end
            end
            
            if pl:pressedMovement(true) then
                md.IsSittingOnSeat = false
                md.IsSittingOnSeatSouth = false
            end
            
            if pl:shouldBeTurning() or pl:shouldBeTurning90() or pl:shouldBeTurningAround() then
                pl:StopAllActionQueue()
                pl:faceLocation(faceX, faceY)
            end
        else
            md.IsSittingOnSeat = false
            md.IsSittingOnSeatSouth = false
     

            pl:clearVariable("SittingToggleStart")
            pl:clearVariable("SittingToggleLoop")
            pl:clearVariable("IsSittingInChair")
            SitAnywhere.sendSitToggleCommand(false, false, false)
            
            Events.OnMainMenuEnter.Remove(SitAnywhere.OnMenu)
            Events.OnPlayerMove.Remove(SitAnywhere.OnMove)
            Events.OnTick.Remove(tickFunc)
        end
    end
    
    SitAnywhere.OnMenu = function()
        md.IsSittingOnSeat = false
    end
    
    SitAnywhere.OnMove = function()
        md.IsSittingOnSeat = false
    end
    
    Events.OnMainMenuEnter.Add(SitAnywhere.OnMenu)
    Events.OnPlayerMove.Add(SitAnywhere.OnMove)
    Events.OnTick.Add(tickFunc)
end


 ]]