_G.InitCfgMod = {
    init = function(sConfigName)
    end,
    tEmpty = setmetatable({}, { 
        __newindex = function(t, k, v)
            printErrorTrace("config empty table, can not set new key-value")
        end,
    }),
    array_mt_pairs = function(tArray, tKeyIndex)
        local nTotalCount = 0
    
        local function pairs(tArray, sKey)
            local sNextKey, nIndex, value = sKey, nil, nil  
            repeat
                sNextKey, nIndex = next(tKeyIndex, sNextKey)
                if nIndex == nil then
                    value = nil
                    break
                end
                value = tArray[nIndex]
                if value == math.huge then
                    value = nil
                end
                nTotalCount = nTotalCount + 1
            until (value ~= nil or nTotalCount >= #tArray)
    
            if value ~= nil then
                return sNextKey, value
            end
        end
    
        return pairs, tArray, nil
    end,
    array_mt_ipairs = function(tArray)
        return function(tArray, nIndex) end, tArray, 0
    end,
}

local function init()
    _G._cfg = {}

    -- require("cfgHeader")
    -- require("cfgLevelDataHeader")
    -- require("check.checkHeader")
	-- require("cfgNpcDialogHeader")
    require("CfgSeriesEventEvent")
end

xpcall(init, function(err)
    print(err .. "\n" .. debug.traceback(tostring(err), 2))
end)