-- 对一个列表中的元素分批执行一段逻辑
-- 初始化实例后调用start即可自动开始分批处理的进程，结束时会通过fOver回调通知调用方
classDef("FrameExcutor", {
    nInterval = 1 * 1000, -- 默认间隔1秒执行一次
    nExcutionCount = 100, -- 默认每次执行100个
    bInstant = true -- 是否在调用start后立即执行一次
})

--[[
FrameExcutor构造函数
@param sDesc: 用于报错打印等，不可为空
@param tList: 需要执行的列表(一定是列表)
@param fExcute: 具体的执行逻辑，参数在末尾的可省略参数中
@param nInterval: 间隔时间，单位毫秒，可以传nil，默认为1秒
@param nExcutionCount: 每次执行列表内的个数，可以传nil，默认为100
@param bInstant: 调用start后，是否立即执行一次，可以传nil，默认为true
@param fOver: 列表全部执行结束的回调，可以传nil
@param ... : fExcute的参数列表，无参数则不传
--]]
function FrameExcutor:ctor(sDesc, tList, fExcute, nInterval, nExcutionCount, bInstant, fOver, ...)
    self.tExcutionList = tList
    self.fExcutor = fExcute
    self.sDesc = sDesc

    if nInterval then
        self.nInterval = nInterval
    end
    if nExcutionCount then
        self.nExcutionCount = nExcutionCount
    end
    if bInstant ~= nil then
        self.bInstant = bInstant
    end
    if fOver ~= nil then
        self.fOver = fOver
    end
    self.tFuncParam = table.pack(...)
end

function FrameExcutor:start()
    self.nTimerId = 0
    self.nIndex = 1
    self.bEnd = false

    if self.bInstant then
        self:excute()
    end
    if not self.bEnd then
        self.nTimerId = SvrTimer.add(self.nInterval, function()
            self:excute()
        end, "FrameExcutor_" .. self.sDesc)
    end
end

function FrameExcutor:over()
    self.bEnd = true
    if self.nTimerId ~= 0 then
        SvrTimer.remove(self.nTimerId)
    end
    if self.fOver ~= nil then
        self.fOver()
    end
end

function FrameExcutor:excute()
    local nMax = math.min(#self.tExcutionList, self.nIndex + self.nExcutionCount - 1)
    for i = self.nIndex, nMax do
        xpcall(self.fExcutor, function(err)
            Logger.error("FrameExcutor Excute Error: ", self.sDesc, self.tExcutionList[i])
            Logger.error(err)
        end, self.tExcutionList[i], table.unpack(self.tFuncParam))
    end
    self.nIndex = nMax + 1
    if self.nIndex > #self.tExcutionList then
        self:over()
    end
end


-- 对象超时管理
classDef("TimeOutManager", {
})

function TimeOutManager:ctor()
    self.nPreTime = os.time()
	self.tTimeSlot = {}
	self.tFlag2TS = {}
end

function TimeOutManager:push(flag, time, task)          -- 需要保证flag唯一，否则会有覆盖危险
    if time <= 1 then
        time = 1
    end
    local nDDL = os.time() + time
    if not self.tTimeSlot[nDDL] then
        self.tTimeSlot[nDDL] = {}
    end
    local tSlot = self.tTimeSlot[nDDL]
    tSlot[flag] = task
    self.tFlag2TS[flag] = nDDL
end

function TimeOutManager:pop(flag)
    if not self.tFlag2TS[flag] then
        return
    end
    local nDDL = self.tFlag2TS[flag]
    self.tFlag2TS[flag] = nil

    local tSlot = self.tTimeSlot[nDDL]
    local task = tSlot[flag]
    tSlot[flag] = nil
    if not next(tSlot) then
        self.tTimeSlot[nDDL] = nil
    end
    return task
end

function TimeOutManager:get(flag)
    if not self.tFlag2TS[flag] then
        return
    end
    local nDDL = self.tFlag2TS[flag]
    local tSlot = self.tTimeSlot[nDDL]
    return tSlot[flag]
end

function TimeOutManager:popTimeOut()
    local nNowTime = os.time()
    local tPopTaskList = {}
    for i = self.nPreTime, nNowTime do
        if not self.tTimeSlot[i] then
            goto continue
        end
        local tSlot = self.tTimeSlot[i]
        self.tTimeSlot[i] = nil
        for flag, task in pairs(tSlot) do
            self.tFlag2TS[flag] = nil
            table.insert(tPopTaskList, task)
        end
        ::continue::
    end
    self.nPreTime = nNowTime + 1
    return tPopTaskList
end

function TimeOutManager:isEmpty()
    if not next(self.tFlag2TS) then
        return true
    else
        return false
    end
end

function TimeOutManager:keys()
    return TableUtil.keys(self.tFlag2TS)
end