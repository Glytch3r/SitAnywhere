
SitAnywhere = SitAnywhere or {}

function SitAnywhere.isCanSitHere(sq)
    if not sq then return false end
    local flr = SitAnywhere.getFlr(sq)
    if not flr then return false end
    
    if sq:getModData()['SitAnywhere'] ~= nil then
        return sq:getModData()['SitAnywhere'] 
    end
    return false
end

function SitAnywhere.setCanSitHere(sq, val)
    if not sq then return end
    local flr = SitAnywhere.getFlr(sq)
    if not flr then return end
    flr:getModData()['SitAnywhere'] = val
    --flr:transmitCompleteItemToClients()
    flr:transmitCompleteItemToServer()
    flr:transmitModData()
end


function SitAnywhere.getFlr(sq)
    if not sq then return nil end
    local flr = sq:getFloor()
    return flr or nil
end



