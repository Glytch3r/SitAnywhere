SitAnywhere = SitAnywhere or {}

SitAnywhere_Action = ISBaseTimedAction:derive("SitAnywhere_Action")

function SitAnywhere_Action:isValid()
    return true
end

function SitAnywhere_Action:waitToStart()
    self.character:faceLocation(self.faceX, self.faceY)
    self.character:faceLocationF(self.faceX, self.faceY)
    return self.character:shouldBeTurning()
end

function SitAnywhere_Action:start()
    self.character:setVariable("ExerciseStarted", false)
    self.character:setVariable("ExerciseEnded", true)
    self.character:setVariable("IsSittingInChair", 'IsSitting')
    self:setActionAnim("Bob_SitAnywhereStart")
    self.character:reportEvent("EventSitOnGround")
    self.action:setUseProgressBar(false)
end

function SitAnywhere_Action:stop()
    ISBaseTimedAction.stop(self)
end

function SitAnywhere_Action:perform()
    local pl = self.character
    local facing = tostring(self.facing)

    --pl:setVariable("SittingToggleStart", facing)
    --pl:reportEvent("EventSitOnGround")

    local md = pl:getModData()
    md.IsSittingOnSeat = true
    ScanForPlayers("ChangeAnimVar", {"SittingToggleStart", tostring(self.facing), "SittingToggleLoop", "IsSitting"..tostring(self.facing), "IsSittingInChair",  "IsSitting"..tostring(self.facing)})
    ISBaseTimedAction.perform(self)
end


function SitAnywhere.pause(sec, callback)
    local start = getTimestampMs()
    local duration = sec * 1000

    local function tick()
        local now = getTimestampMs()
        if now - start >= duration then
            Events.OnTick.Remove(tick)
            if callback then callback() end
        end
    end

    Events.OnTick.Add(tick)
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

function SitAnywhere.sendSitToggleCommand(pl, facing1, facing2, facing3)
    if not isClient() then return end
    print(facing1)
    print(facing2)
    print(facing3)
    ScanForPlayers("Changefacing", { pl:getOnlineID(), "SittingToggleStart", facing1, "SittingToggleLoop", facing2, "IsSittingInChair", facing3 })
end


function SitAnywhere.SitLoop(pl, facing, faceX, faceY, facing2, sitAnim)
    pl = pl or getPlayer()
    local md = pl:getModData()
    local rested = false

    local ticker = function()
        if md.IsSittingOnSeat then
            pl:setBlockMovement(true)
            pl:nullifyAiming()

            if pl:pressedMovement(true) then
                md.IsSittingOnSeat = false
                if pl:shouldBeTurning() or pl:shouldBeTurning90() or pl:shouldBeTurningAround() then
                    pl:StopAllActionQueue()
                    pl:faceLocation(faceX, faceY)
                end
            end
            
            if not pl:hasTimedActions() and not rested then
                if pl:getStats():getEndurance() < 1 then
                    pl:updateEnduranceWhileSitting()
                else
                    HaloTextHelper.addTextWithArrow(pl, getText("IGUI_HaloNote_WellRested"), true, 80, 200, 0)
                    rested = true
                end
            end
        else
            md.IsSittingOnSeat = false
            pl:setBlockMovement(false)
            pl:nullifyAiming()
            pl:clearVariable("SittingToggleStart")
            pl:clearVariable("SittingToggleLoop")
            pl:clearVariable("IsSittingInChair")
            Events.OnMainMenuEnter.Remove(SitAnywhere.OnMenu)
            Events.OnPlayerMove.Remove(SitAnywhere.OnMove)
            Events.OnTick.Remove(tick)
        end
    end

    SitAnywhere.OnMenu = function()
        md.IsSittingOnSeat = false
    end

    SitAnywhere.OnMove = function()
        md.IsSittingOnSeat = false
    end

    --Events.OnMainMenuEnter.Add(SitAnywhere.OnMenu)
    --Events.OnPlayerMove.Add(SitAnywhere.OnMove)
    --Events.OnTick.Add(ticker)
end
