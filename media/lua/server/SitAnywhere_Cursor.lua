SitAnywhere = SitAnywhere or {}




SitAnywhere_Cursor = ISBuildingObject:derive("SitAnywhere_Cursor")

function SitAnywhere_Cursor:create(x, y, z, north, sprite)
     local pl = self.character
    if not pl then return end
    if not pl:isAlive() then return end
    ISTimedActionQueue.clear(pl)
    local sq = getWorld():getCell():getGridSquare(x, y, z)

    ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, sq));

    ISTimedActionQueue.add(SitAnywhere_Action:new(pl, self.facing))
end

function SitAnywhere_Cursor:isValid(sq)
    return sq:TreatAsSolidFloor()
end

function SitAnywhere_Cursor:render(x, y, z, sq)
    if not SitAnywhere_Cursor.floorSprite then
        SitAnywhere_Cursor.floorSprite = IsoSprite.new()
        SitAnywhere_Cursor.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
    end
    local hc = ColorInfo.new(0, 0, 1, 1)
    if not self:isValid(sq) then
        hc = getCore():getBadHighlitedColor()
    end
    SitAnywhere_Cursor.floorSprite:RenderGhostTileColor(x, y, z, hc:getR(), hc:getG(), hc:getB(), 0.8)
end

function SitAnywhere_Cursor:new(character, facing)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o:init()
    o:setSprite("none")
    o:setNorthSprite("none")
    o.character = character
    --o.plNum = character:getPlayerNum()
    o.facing = facing or "S"
    o.noNeedHammer = true
    o.skipBuildAction = true
    return o
end


--[[ 
SitAnywhere = ISBuildingObject:derive("SitAnywhere")

function SitAnywhere:create(x, y, z, north, sprite)
	local square = getWorld():getCell():getGridSquare(x, y, z)
    ISTimedActionQueue.add(SitAnywhere_Action:new(self.character, self.facing))

end

function SitAnywhere:isValid(square)
	return ISWorldObjectContextMenu.canCleanBlood(self.character, square)
end

function SitAnywhere:render(x, y, z, square)
	if not SitAnywhere.floorSprite then
		SitAnywhere.floorSprite = IsoSprite.new()
		SitAnywhere.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
	end
	local hc = getCore():getGoodHighlitedColor()
	if not self:isValid(square) then
		hc = getCore():getBadHighlitedColor()
	end
	SitAnywhere.floorSprite:RenderGhostTileColor(x, y, z, hc:getR(), hc:getG(), hc:getB(), 0.8)
end

function SitAnywhere:new(sprite, northSprite, character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:init()
	o:setSprite(sprite)
	o:setNorthSprite(northSprite)
	o.character = character
	o.player = character:getPlayerNum()
	o.noNeedHammer = true
	o.skipBuildAction = true
	return o
end

 ]]