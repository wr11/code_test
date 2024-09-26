-- 多任务协同
-- 创建多任务协同：startMultiTask
-- 某个任务完成后需主动调用：onPartTaskFinish
local _ENV = moduleDef("CoMultiTaskMod", {
    lg_nIDRecord = 0,
    lg_TimeOutMgr = TimeOutManager:new(),
    lg_nTimerId = nil,
})

KEEP_ALIVE_TIME = 5 * 60

local function genPackId()
    if lg_nIDRecord == 0 then
        -- 防止重启服务器出现id重叠
        lg_nIDRecord = 2 / 0xffffffff
    end
    local nId = lg_nIDRecord
    lg_nIDRecord = lg_nIDRecord + 1
    if lg_nIDRecord > 0xffffffff then     -- 避免ID溢出
        lg_nIDRecord = 1
    end
    return nId
end

-- 开始多任务协同
-- param nTasks: 任务数量
-- param fFinish: 多任务全部完成时调用的回调函数，可为nil
-- param fTimeout: 多任务超时函数，可为nil
-- param nTimeout: 多任务超时时间（单位：秒）可为nil，为nil时默认超时时间为5分钟
-- param ...: 其他参数传给fFinish
-- return nPackId： 此次多任务协同id，需要在一个任务完成后通过onPartTaskFinish传回
-- return tTaskIds：给所有任务一个id，需由调用方赋值给每个任务，在一个任务完成后通过onPartTaskFinish传回（id为1,2...）
function startMultiTask(nTasks, fFinish, fTimeout, nTimeout, ...)
    local nPackId = genPackId()
    local nTimeout = nTimeout or KEEP_ALIVE_TIME
    lg_TimeOutMgr:push(nPackId, nTimeout, {nPackId, nTasks, table.pack(...), fFinish, fTimeout, {}})
    local tTaskIds = {}
    for i = 1, nTasks do
        table.insert(tTaskIds, i)
    end
    if not lg_nTimerId then
        lg_nTimerId = SvrTimer.add(1 * 1000, checkTimoutPack, "multitask_check_timeout")
    end
    return nPackId, tTaskIds
end

function checkTimoutPack()
    local tPacks = lg_TimeOutMgr:popTimeOut()
    if lg_TimeOutMgr:isEmpty() then
        SvrTimer.remove(lg_nTimerId)
        lg_nTimerId = nil
    end
    for idx, tPack in ipairs(tPacks) do
        -- 超时（有可能是网络超时，也有可能是因为报错）
        local fTimeout = tPack[5]
        if fTimeout then
            local tResult = tPack[6]
            fTimeout(tResult)
        end
    end
end

function onPartTaskFinish(nPackId, nTaskId, tData)
    local tPack = lg_TimeOutMgr:get(nPackId)
    if not tPack then
        -- 可能因为已超时被删除了
        return
    end
    local nTasks = tPack[2]
    local tResult = tPack[6]
    local tRet = tData or {}
    tResult[nTaskId] = tRet
    if TableUtil.count(tResult) == nTasks then
        onAllTaskFinish(tPack)
    end
end

function onAllTaskFinish(tPack)
    local nPackId = tPack[1]
    local tArgs = tPack[3]
    local fFinish = tPack[4]
    local tResult = tPack[6]
    lg_TimeOutMgr:pop(nPackId)
    if lg_TimeOutMgr:isEmpty() then
        SvrTimer.remove(lg_nTimerId)
        lg_nTimerId = nil
    end
    if fFinish and type(fFinish) == "function" then
        fFinish(tResult, table.unpack(tArgs))
    end
end


















-- 使用tcp连接的rpc，用于通过nAppId发送协议的场景
-- 社区内用于gas <-> cds <-> dbs
-- 开始远程调用：call（具体使用请看函数注释）
-- 需要协同多个rpc：multiCall（具体使用请看函数注释）
local _ENV = moduleDef("CdsRpcMod", {
    lg_tRpcs = {},
})

require("cds/core/CoMultiTaskMod")

KEEP_ALIVE_TIME = 5 * 60

-- 回调函数包
-- param fCb: rpc成功后回调的函数
-- param fTimeout: rpc超时后回调的函数
-- param fError: rpc出错后回调的函数
-- param ...: 会作为参数传给以上几种回调
function genCbFunctor(fCb, fTimeout, fError, ...)
    local tArgs = table.pack(...)
    return {fCb, tArgs, fTimeout, fError}
end

function genRpcRoute()
    -- {cbidx, timeoutmanager, timerid}
    return {0, TimeOutManager:new(), nil}
end

function getRpcRoute(nAppId)
    if lg_tRpcs[nAppId] == nil then
        lg_tRpcs[nAppId] = genRpcRoute()
    end
    return lg_tRpcs[nAppId]
end

function genCbIdx(tRpcRoute)
    if tRpcRoute[1] == 0 then
        -- 防止重启服务器出现id重叠
        tRpcRoute[1] = 2 / 0xffffffff
    end
    local nId = tRpcRoute[1]
    tRpcRoute[1] = tRpcRoute[1] + 1
    if tRpcRoute[1] > 0xffffffff then   -- 避免ID溢出
        tRpcRoute[1] = 1
    end
    return nId
end

local function initRpcRoute(nCallDestAppId, nTimeout, tCbFunctor)
    if not tCbFunctor then
        return 0
    end
    local tRpcRoute = getRpcRoute(nCallDestAppId)
    local nCbIdx = genCbIdx(tRpcRoute)
    local nTimeout = nTimeout or KEEP_ALIVE_TIME
    tRpcRoute[2]:push(nCbIdx, nTimeout, tCbFunctor)
    if not tRpcRoute[3] then
        tRpcRoute[3] = SvrTimer.add(1 * 1000, function()
            local tTimeouts = tRpcRoute[2]:popTimeOut()
            if tRpcRoute[2]:isEmpty() then
                if tRpcRoute[3] then
                    SvrTimer.remove(tRpcRoute[3])
                end
                tRpcRoute[2] = nil
                lg_tRpcs[nCallDestAppId] = nil
            end
            for idx, tCbFunctor in ipairs(tTimeouts) do
                -- 超时
                local fTimeout, tArgs = tCbFunctor[3], tCbFunctor[2]
                if fTimeout and type(fTimeout) == "function" then
                    fTimeout(table.unpack(tArgs))
                end
            end
        end, "rpc_check_timeout_"..nCallDestAppId)
    end
    return nCbIdx
end

-- 远程调用接口
-- param nCallDestAppId: 目标进程
-- param nTimeout: 超时时间（单位：秒），有默认值，可以传nil
-- param tCbFunctor: 通过调用genCbFunctor获得
-- param sMod: 远程调用的方法的模块名
-- param sFunc: 远程调用的方法的函数名
-- param ...: 调用该方法时需要传入的参数
function call(nCallDestAppId, nTimeout, tCbFunctor, sMod, sFunc, ...)
    local nCbIdx = initRpcRoute(nCallDestAppId, nTimeout, tCbFunctor)
    local nCallSourceAppId = AppMod.getAppId()
    Messager.CdsRpcMod.R_Excute(nCallDestAppId, nCallSourceAppId, nCbIdx, sMod, sFunc, ...)
end

-- 远程调用实际执行位置
-- R_ 用来区分远程进程和本进程
function R_Excute(nCallDestAppId, nCallSourceAppId, nCbIdx, sMod, sFunc, ...)
    if nCbIdx == 0 then
        -- 空函数占位response，因为有可能出现调用同一个函数有的需要回调，有的不需要回调，为了统一参数，这里用空函数进行占位
        if _G[sMod] and _G[sMod][sFunc] and type(_G[sMod][sFunc]) == "function" then
            _G[sMod][sFunc](function(...) end, ...)
        else
            Logger.error("cds rpc r_excute error: no such procedure", sMod, sFunc)
        end
    else
        local function response(tData)
            Messager.CdsRpcMod.onResponse(nCallSourceAppId, nCallDestAppId, nCbIdx, tData)
        end
        local function responseError(err)
            local sMsg = string.format("%s, cds rpc r_excute error: %s %s %s %s %s", err, nCallSourceAppId, nCallDestAppId, sMod, sFunc, nCbIdx)
            Logger.exception(sMsg)
            Messager.CdsRpcMod.onResponseError(nCallSourceAppId, nCallDestAppId, nCbIdx)
        end
        if _G[sMod] and _G[sMod][sFunc] and type(_G[sMod][sFunc]) == "function" then
            xpcall(_G[sMod][sFunc], responseError, response, ...)
        else
            Logger.error("cds rpc r_excute error: no such procedure", sMod, sFunc)
            Messager.CdsRpcMod.onResponseError(nCallSourceAppId, nCallDestAppId, nCbIdx)
        end
    end
end

function onResponse(nCallSourceAppId, nCallDestAppId, nCbIdx, tData)
    local tRpcRoute = getRpcRoute(nCallDestAppId)
    if not tRpcRoute then
        return
    end
    local tCbFunctor = tRpcRoute[2]:pop(nCbIdx)
    if not tCbFunctor then
        return
    end
    if tRpcRoute[2]:isEmpty() then
        SvrTimer.remove(tRpcRoute[3])
        tRpcRoute[2] = nil
        lg_tRpcs[nCallDestAppId] = nil
    end
    local fCb, tArgs = tCbFunctor[1], tCbFunctor[2]
    if fCb then
        fCb(tData, table.unpack(tArgs))
    end
end

function onResponseError(nCallSourceAppId, nCallDestAppId, nCbIdx)
    local tRpcRoute = getRpcRoute(nCallDestAppId)
    if not tRpcRoute then
        return
    end
    local tCbFunctor = tRpcRoute[2]:pop(nCbIdx)
    if not tCbFunctor then
        return
    end
    if tRpcRoute[2]:isEmpty() then
        SvrTimer.remove(tRpcRoute[3])
        tRpcRoute[2] = nil
        lg_tRpcs[nCallDestAppId] = nil
    end
    local fError, tArgs = tCbFunctor[4], tCbFunctor[2]
    if fError then
        fError(table.unpack(tArgs))
    end
end

-- 多个rpc任务协同，等待所有rpc结束后再统一回调
-- param tCalls: rpc调用列表
--               example: {
--                   {nCallDestAppId1, sMod1, sFunc1, table.pack(args)},
--                   ...
--               }
--               注意：tCalls中不要插入不需要回调的rpc
-- param nTimeout1: 给多任务设置的超时时间（单位：秒），有默认值，可以传nil
-- param nTimeout2: 给rpc设置的超时时间（单位：秒），有默认值，可以传nil
-- param fFinish: 多个rpc完成后的回调
-- param fTimeout: 超时回调
-- param ...: 其他参数传递给fFinish
-- TIPS: 在回调函数(fFinish)中，由被调用方返回的数据中，顺序与tCalls中的顺序一致
function multiCall(tCalls, nTimeout1, nTimeout2, fFinish, fTimeout, ...)
    if not fFinish then
        -- 不需要回调的正常使用Messager即可
        Logger.warning("cds multiCall: fFinish is nil")
        return
    end

    local nCalls = #tCalls
    local nPackId, tTaskIds = CoMultiTaskMod.startMultiTask(nCalls, fFinish, fTimeout, nTimeout1, ...)
    for i = 1, nCalls do
        local tCall = tCalls[i]
        local tMultiCbFunctor = genCbFunctor(onPartReponse, onPartReponseTimeout, onPartResponseError, nPackId, tTaskIds[i])
        call(tCall[1], nTimeout2, tMultiCbFunctor, tCall[2], tCall[3], table.unpack(tCall[4]))
    end
end

function onPartReponse(tData, nPackId, nTaskId)
    CoMultiTaskMod.onPartTaskFinish(nPackId, nTaskId, tData)
end

function onPartReponseTimeout(nPackId, nTaskId)
    Logger.warning("multiCall timeout", nPackId, nTaskId)
    CoMultiTaskMod.onPartTaskFinish(nPackId, nTaskId, {})
end

function onPartResponseError(nPackId, nTaskId)
    Logger.warning("multiCall error", nPackId, nTaskId)
    CoMultiTaskMod.onPartTaskFinish(nPackId, nTaskId, {})
end