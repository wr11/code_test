
function isStart(s, prefix)
    if prefix == nil then return true end
    return string.sub(s,1,string.len(prefix)) == prefix
end

function isEnd(s, suffix)
    if suffix == nil then return true end
    return suffix == '' or string.sub(s,-string.len(suffix)) == suffix
end
function table2orderlist(tb,depth,suffix)
    local list = {}
    for k,v in pairs(tb) do
        local tv = type(v)
        local tk = type(k)
        local key = tostring(k)
        if isEnd(key, suffix) or isStart(key, suffix) then
            local cateory = 1
            if tv == "function" then
                cateory = 2
            elseif tv == "userdata" then
                cateory = 3
            elseif tv == "table" then
                cateory = 3
            end
            table.insert( list, {depth = depth or 0, cateory = cateory, keyType = tk, valueType = tv, key = key, value = v})
        end
    end
    table.sort(list, function(a,b)
        if a.cateory == b.cateory then
            if a.keyType == "number" and a.keyType == b.keyType then
                return tonumber(a.key) < tonumber(b.key)
            else
                return a.key < b.key
            end
        else
            return a.cateory < b.cateory
        end
    end)
    return list
end

function isinteger(v) 
    return math.type(v) == "integer" 
end

function isArray(tb)
    if not tb then return end
    local len = 0
    local max = 0
    for k in pairs(tb) do
        if isinteger(k) and k > 0 then
            len = len + 1
            if k > max then max = k end
        else
            return false
        end
    end
    return len == max
end

function table2strNoFormat(tb, tbDict)
    local sType = type(tb)
    if sType ~= "table" then
        if sType == "string" then return string.format('"%s"', tb) end
        return tostring(tb)
    end

    tbDict = tbDict or {}
    if tbDict[tb] then
        return tostring(tb)
    end
    tbDict[tb] = true

    local str = "{"
    if isArray(tb) and #tb > 0 then -- ????
        for k, v in ipairs(tb) do
            local comma = ","
            if k == #tb then
                comma = ""
            end
            if type(v) == "string" then
                v = string.format('"%s"', v)
            elseif type(v) == "table" then
                v = table2strNoFormat(v, tbDict)
            else
                v = tostring(v)
            end
            str = str .. v .. comma
        end
    else
        local list = table2orderlist(tb)
        for k,v in ipairs(list) do
            local key = v.key
            local value = v.value
            if v.keyType == "string" then
                local b = string.byte(key, 1)
                if not (b and (b==95 or (65<=b and b<=90) or (97<=b and b<=122))) then
                    key = string.format('["%s"]', key)
                end
            elseif v.keyType == "number" then
                key = string.format('[%s]', key)
            end
            if v.valueType == "string" then
                value = string.format('"%s"', value)
            elseif v.valueType == "table" then
                value = table2strNoFormat(value, tbDict)
            end
            local comma = ","
            if k == #list then
                comma = ""
            end
            str = str .. string.format("%s=%s%s", key, value, comma)
        end
    end
    str = str .. "}"
    return str
end

function printTable(t)
    print(table2strNoFormat(t))
end

--[[

local _ENV = moduleDef("TestMod", {
	var1 = 100,
	var2 = "kaka"
})

或者
local _ENV = moduleDef("TestMod", function ()
	local M = {}
	M.var1 = 100,
	M.var2 = "kaka"
	return M
end)


-- 模块内就不要再定义任何变量了，所有变量都定义在moduleDef里面！！！！

function func1()
	print("member func", var1, var2)
end

function func2()
	print("static func!!")
end
	
]]

--subModule 子模块，reload的时候，不会覆盖sModName对应table
local mod_mt = {__index = _G}
function moduleDef(sModName, mod)
	if not _G[sModName] then
		if type(mod) == "table" then
			_G[sModName] = mod
		elseif type(mod) == "function" then
			_G[sModName] = mod()
		else
			assert(mod == nil)
			_G[sModName] = {}
		end

		_G[sModName].__sModName__ = sModName

		setmetatable(_G[sModName], mod_mt)
        if _G.isGac then
            if _G.moduleResetList then
                moduleResetRecord(sModName)
            end
        end
	end

	return _G[sModName]
end

local function __initClass(cls)
	local cls_mt = {__index = cls}
	function cls:new(...)
		local o = {}
		setmetatable(o, cls_mt)
		if cls.ctor ~= nil then
			o:ctor(...)
		end
		return o
	end
end

--[[
	
classDef("TestCls", {
	staticVar1 = 100,
	staticVar2 = "kaka"
})

-- 类的构造方法
function TestCls:ctor(p1, p2)
	self.var1 = p1
	self.var2 = p2
end

function TestCls:func1()
	print("member func", self.var1, self.var2, TestCls.staticVar1, TestCls.staticVar2)
end

----------------------
-- 外部调用

local inst = TestCls:new(1, 2)
inst:func1()

]]
function classDef(sClsName, cls)
	if not _G[sClsName] then
		if type(cls) == "table" then
			_G[sClsName] = cls
		elseif type(cls) == "function" then
			_G[sClsName] = cls()
		else
			assert(cls == nil)
			_G[sClsName] = {}
		end

		__initClass(_G[sClsName])

	end
	return _G[sClsName]
end

function createClass()
	local cls = {}
	__initClass(cls)
	return cls
end

function classDefCopyTable(tCls, tParentCls)
    for k, v in pairs(tParentCls) do
        tCls[k] = v
    end
end