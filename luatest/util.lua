local numbertostring_list = {}
for i = 1, 1024 do -- 65535 需要接近 4M内存
    numbertostring_list[i] = tostring(i)
end
_G.numbertostring = function(v)
    return numbertostring_list[v] or tostring(v)
end
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
_G.PT = printTable

--[[

local _ENV = moduleDef("TestMod", {
	var1 = 100,
	var2 = "kaka"
})

����
local _ENV = moduleDef("TestMod", function ()
	local M = {}
	M.var1 = 100,
	M.var2 = "kaka"
	return M
end)


-- ģ���ھͲ�Ҫ�ٶ����κα����ˣ����б�����������moduleDef���棡������

function func1()
	print("member func", var1, var2)
end

function func2()
	print("static func!!")
end
	
]]

--subModule ��ģ�飬reload��ʱ�򣬲��Ḳ��sModName��Ӧtable
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

-- ��Ĺ��췽��
function TestCls:ctor(p1, p2)
	self.var1 = p1
	self.var2 = p2
end

function TestCls:func1()
	print("member func", self.var1, self.var2, TestCls.staticVar1, TestCls.staticVar2)
end

----------------------
-- �ⲿ����

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


------------------------------------------------------
--
-- 专门处理table相关
--
-- 接口：
-- count(tb)
-- contains(tb,value)
-- map(tb,func(v,k,index))
-- printTable(tb, tableName, maxDepth)
-- safeGet(tRoot, ...)
-- getTable(sTablePath)
-- value2key(tb,value,gsubPattern)
-- table2str(tb, depth, maxDepth)
-- isEmpty(tb)
--
------------------------------------------------------

---@module TableUtil
local _ENV = moduleDef("TableUtil")

-- talbe计数
function count(tb)
    if not tb or not next(tb) then
        return 0
    end
    local dCount = 0
    for _, v in pairs(tb) do
        dCount = dCount + 1
    end
    return dCount
end

-- tb中是否包含value
function contains(tb,value)
    if not tb then
        return false
    end
    for k,v in pairs(tb) do
        if v == value then
            return true,k
        end
    end
    return false
end

-- 对每个元素执行func转换
function map(tb, func)
    local r = {}
    if not tb then
        return r
    end
    local index = 1
    for k,v in pairs(tb) do
        r[k] = func(v,k,index)
        index = index + 1
    end
    return r
end

-- 安全迭代访问table
-- 仅建议对局部变量是用,全局变量推荐用getTable方便代码搜索
function safeGet(tRoot,...)
    if tRoot == nil then
        return nil
    end
    local tb = tRoot
    for _,key in ipairs({...}) do
        if tb[key] then
            tb = tb[key]
        elseif tb[tonumber(key)] then
            tb = tb[tonumber(key)]
        else
            return nil
        end
    end
    return tb
end

-- 根据字符串返回talbe，字符串格式为:DataMod.myData.nRoleId
function getTable(sTablePath)
    local keys = StringUtil.split(sTablePath, ".")
    if count(keys) <= 0 then
        return nil
    end
    local tb = _G
    for k,key in pairs(keys) do
        if tb.key then
            tb = tb.key
        elseif tb[key] then
            tb = tb[key]
        elseif tb[tonumber(key)] then
            tb = tb[tonumber(key)]
        end
    end
    if tb == _G then
        return nil
    else
        return tb
    end
end

-- 在符合keyPattern的键值上反差键，可用于翻译枚举值
function value2key(tb,value,gsubPattern)
    if not tb then
        return nil
    end
    gsubPattern = gsubPattern or ".*"
    for k,v in pairs(tb) do
        if value == v then
            local t = type(k)
            if t == "string" then
                local s,c = string.gsub(k,gsubPattern,"%1",1)
                if c > 0 then
                    return s
                end
            elseif t == "number" then
                return k
            end
        end
    end
    return nil
end

function __getSpace(depth)
    local space = ""
    for i=1,depth do
        space = space .. "    "
    end
    return space
end

-- 【注意】不要使用该接口先格式化table然后在打印，请使用printTable/PT
-- 正式线上运行环境print/debug等日志被控制不能输出，但是如果在打印日志接口中格式化table，
-- table却又必须格式化，有性能隐藏大坑，确实需要使用者需清楚自己在干什么，瞎几把无脑调用的自己好好想想
function table2str(tb, depth, maxDepth, tbDict)
    tbDict = tbDict or {}
    if depth == nil then
        depth = 1
    end
    if maxDepth ~= nil and maxDepth > 0 and depth > maxDepth then
        return "{...}"
    end
    if type(tb) ~= "table" then
        return string.format("%s: %s\n",type(tb),tostring(tb))
    end

    local valmeta = getmetatable (tb)
    if valmeta and valmeta.__tostring then
        return valmeta.__tostring(tb)
    end

    if tbDict[tb] then
        return tostring(tb)
    end
    tbDict[tb] = true

    local str = "{\n" -- tostring(tb) .. "{\n"
    local space = __getSpace(depth)
    if isArray(tb) and #tb > 0 then -- 数组
        str = str .. space
        for k, v in ipairs(tb) do
            local comma = ", "
            if k == #tb then
                comma = "\n"
            elseif k % 10 == 0 then
                comma = ",\n" .. space
            end
            if type(v) == "string" then
                v = string.format('"%s"', v)
            elseif type(v) == "table" then
                v = table2str(v, depth + 1, maxDepth, tbDict)
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
                value = table2str(value, depth + 1, maxDepth, tbDict)
            end
            local comma = ","
            if k == #list then
                comma = ""
            end
            str = str .. string.format("%s%s = %s%s\n", space, key, value, comma)
        end
    end
    str = str .. string.format("%s%s",__getSpace(depth -1),"}")
    return str
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
    if isArray(tb) and #tb > 0 then -- 数组
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

function table2orderlist(tb,depth,suffix)
    local list = {}
    for k,v in pairs(tb) do
        local tv = type(v)
        local tk = type(k)
        local key = tostring(k)
        if StringUtil.isEnd(key, suffix) or StringUtil.isStart(key, suffix) then
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

function disorder(t)
    -- 排序函数必须是稳定排序，不能直接这样用
    -- table.sort(t, function() return Random.randomI(RandomType.SceneCommon, 1, 2) == 1 end)
    local randomFunc = Random.randomI
    local nRandomType = RandomType.SceneCommon
    for i = #t, 1, -1 do
        local j = randomFunc(nRandomType, 1, i)
        local tmp = t[j]
        t[j] = t[i]
        t[i] = tmp
    end
end

function disorder2(t, cnt)
    -- 排序函数必须是稳定排序，不能直接这样用
    -- table.sort(t, function() return Random.randomI(RandomType.SceneCommon, 1, 2) == 1 end)
    local randomFunc = Random.randomI
    local nRandomType = RandomType.SceneCommon
    for i = cnt, 1, -1 do
        local j = randomFunc(nRandomType, 1, i)
        local tmp = t[j]
        t[j] = t[i]
        t[i] = tmp
    end
end

function isEmpty(t)
    return t == nil or not next(t)
end

function keys(t)
    if t then
        -- 比直接使用table.insert(list, k)性能更优，相差四五倍
        local list = {}
        local n = 1
        for k in pairs(t) do
            list[n] = k
            n = n + 1
        end
        return list
    end
end

-- 如果t的key是数字的话，可以不传compare
function orderKeys(t, compare)
    local lst = keys(t)
    if lst then
        table.sort(lst, compare)
        return lst
    end
end

function values(t)
    if t then
        local list = {}
        local n = 1
        for _, v in pairs(t) do
            list[n] = v
            n = n + 1
        end
        return list
    end
end

-- @param object 要克隆的值
-- @return objectCopy 返回值的副本
function clone( object )
    local lookup_table = {}
    local function copyObj( object )
        if type( object ) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}
        lookup_table[object] = new_table
        local mt = getmetatable( object )
        for key, value in pairs( object ) do
            new_table[copyObj( key )] = copyObj( value )
        end
        if mt and mt.___sheetindex then --导表的table的原表自带___sheetindex
            return new_table --导表的table，不需要拷贝原表，直接复制值
        else
            return setmetatable( new_table, mt)
        end
    end
    return copyObj( object )
end

function simpleClone(t)
    if not t then
        return
    end

    local ret = {}
    for k, v in pairs(t) do
        ret[k] = v
    end
    return ret
end

function invertKV(t)
    local tNew = {}
    for k, v in pairs(t) do
        tNew[v] = k
    end

    return tNew
end

-- 一层table（注意字符和数字key混用可能会问题）
function key2str(t)
    if not t then return end

    local tr = {}
    for k, v in pairs(t) do
        tr[numbertostring(k)] = v
    end
    return tr
end
function key2num(t)
    if not t then return end

    local tr = {}
    for k, v in pairs(t) do
        tr[tonumber(k)] = v
    end
    return tr
end

-- 两层table（注意字符和数字key混用可能会问题）
function key2str2(t)
    if not t then return end

    local tr = {}
    for k, v in pairs(t) do
        k = numbertostring(k)
        if type(v) == "table" then
            tr[k] = {}
            for k2, v2 in pairs(v) do
                tr[k][numbertostring(k2)] = v2
            end
        else
            tr[k] = v
        end
    end
    return tr
end
function key2num2(t)
    if not t then return end

    local tr = {}
    for k, v in pairs(t) do
        k = tonumber(k)
        if type(v) == "table" then
            tr[k] = {}
            for k2, v2 in pairs(v) do
                tr[k][tonumber(k2)] = v2
            end
        else
            tr[k] = v
        end
    end
    return tr
end

function removeListByKV(tList, k, v)
    for nIdx, tData in ipairs(tList) do
        if tData[k] == v then
            table.remove(tList, nIdx)
            return
        end
    end
end

function removeListByV(tList,v)
    for nIdx, tData in pairs(tList) do
        if tData == v then
            table.remove(tList, nIdx)
            return
        end
    end
end

function copyKeyValue(des, src)
    if not next(src) then return end
    if not des then return end
    for key, value in pairs(src) do
        des[key] = value
    end
end

function copyKeyValueRecursion(des, src)
    if not des then return end
    if not next(src) then return end

    for key, value in pairs(src) do
        if type(value) == "table" then
            copyKeyValueRecursion(des[key], value)
        else
            des[key] = value
        end
    end
end

-- 是否是数组
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

-- 数组去重
function array2set(tb)
    if not tb then
        return
    end
    local map = {}
    for _, v in pairs(tb) do
        map[v] = 1
    end

    local t = {}
    local n = 1
    for v, _ in pairs(map) do
        t[n] = v
        n = n + 1
    end
    return t
end

-- 两个数组是否含有相同元素
function arrayHadSame(tb1, tb2)
    if not tb1 or not tb2 then
        return
    end
    if tb1 == tb2 then
        return true
    end

    for _, v in pairs(tb1) do
        if contains(tb2, v) then
            return true
        end
    end
end

-- 两个数组元素key全部相同
function arrayKeyAllSame(tb1, tb2)
    if not tb1 or not tb2 then
        return
    end
    if tb1 == tb2 then
        return true
    end
    if count(tb1) ~= count(tb2) then
        return false
    end

    for k, _ in pairs(tb2) do
        if tb1[k] then
            if type(tb1[k]) ~= "table" and type(tb2[k]) ~= "table" then
                if type(tb1[k]) == "number" then
                    if tb1[k] ~= tb2[k] then
                        return false, k
                    end
                else
                    if tb1[k] ~= tb2[k] then
                        return false, k
                    end
                end
            elseif type(tb1[k]) == "table" and type(tb2[k]) == "table" then
                if not arrayKeyAllSame(tb1[k], tb2[k]) then
                    return false, k
                end
            end
        else
            return false
        end
    end
    return true
end

-- 求两个表的交集
function union(tb1, tb2)
    if not tb1 or not tb2 then
        return {}
    end

    local map = {}
    for _, v in pairs(tb1) do
        local num = map[v] or 0
        map[v] = num + 1
    end

    local tab = {}
    for k, v in pairs(tb2) do
        map[v] = (map[v] or 0) - 1
        local num = tab[v] or 0
        tab[v] = (map[v] >= 0) and (num + 1) or num
    end

    local list = {}
    local n = 1
    for k, num in pairs(tab) do
        for i = 1, num do
            list[n] = k
            n = n + 1
        end
    end
    return list
end

-- desc:移除数组一段数据 基于原数组操作
function remove(tb, from, to)
    assert(from > 0)
    assert(to > 0)
    assert(from <= to)
    assert(tb)
    if not next(tb) then return end
    local length = #tb
    assert(to <= length)
    if from == to then
        table.remove(tb, from)
    else
        local count = to - from + 1
        table.move(tb, to + 1, length, from, tb)
        while(count > 0) do
            table.remove(tb)
            count = count - 1
        end
    end
end

function clear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

function tableUnionEqualsTable(tFinalList)
    local tRemoveIdDict={}
    local nListCount=TableUtil.count(tFinalList)

    for nIndex,v in pairs(tFinalList) do
        local nextIndex=nIndex+1
        if nextIndex<=nListCount then
            for i=nextIndex,nListCount,1  do
                local tEntity=tFinalList[i]
                printTable(tEntity,"tEntity getProcessGoods")
                if v==tEntity then
                    if tRemoveIdDict[i]==nil then
                        tRemoveIdDict[i]=i
                    end
                end
            end
        end
    end

    for nIndex=TableUtil.count(tFinalList),1,-1 do
        for k,v in pairs(tRemoveIdDict) do
            if nIndex==v then
                table.remove(tFinalList,v)
            end
        end
    end
    return tFinalList
end

---二分插入
---@param tToInsert table 有序数组
---@param value any
---@param bSmallToLarge boolean 是否是从小到大
---@param fCmpFunc function 判断每个元素是否比value小
---@return number | nil 返回插入位置
function getInsertPos(tToInsert, value, bSmallToLarge, fCmpFunc)
    if not tToInsert then
        printError("binary search error, tToInsert is nil")
        return
    end

    if #tToInsert == 0 then
        return 1
    end

    if not value then
        printError("binary search error, value is nil")
        return
    end

    if not fCmpFunc or type(fCmpFunc) ~= "function" then
        fCmpFunc = function (a, b)
            return a < b
        end
    end

    local nBegin, nEnd = 1, #tToInsert
    local nMid = (nBegin + nEnd) >> 1

    local function shouleInsertAfter(nPos)
        return (fCmpFunc(tToInsert[nPos], value) and bSmallToLarge) or (not (fCmpFunc(tToInsert[nPos], value) or bSmallToLarge))
    end

    while (nEnd - nBegin) > 1 do
        if shouleInsertAfter(nMid) then
            --比value小且从小到大 or 比value大且从大到小
            nBegin = nMid
            nMid = (nBegin + nEnd) >> 1
        else
            --比value小且从大到小 or 比value大且从小到大
            nEnd = nMid
            nMid = (nBegin + nEnd) >> 1
        end
    end

    if shouleInsertAfter(nBegin) then
        if shouleInsertAfter(nEnd) then
            return nEnd + 1
        else
            return nEnd
        end
    else
        return nBegin
    end
end

---二分查找
---@param tToSearch table
---@param value any
---@param bSmallToLarge boolean 是否是从小到大
---@param fEqual function 判断每个元素是否与value相等
---@param fCmpFunc function 判断每个元素是否比value小
---@return number | nil 返回找到的位置, 找不到返回-1, 报错返回nil
function binarySearch(tToSearch, value, bSmallToLarge, fEqual, fCmpFunc)
    if not tToSearch or #tToSearch <= 0 then
        printError("binary search error, tToInsert is nil")
        return
    end

    if not value then
        printError("binary search error, value is nil")
        return
    end

    if not fEqual or type(fEqual) ~= "function" then
        fEqual = function (a, b)
            return a == b
        end
    end

    if not fCmpFunc or type(fCmpFunc) ~= "function" then
        fCmpFunc = function (a, b)
            return a < b
        end
    end

    local nBegin, nEnd = 1, #tToSearch
    local nMid = (nBegin + nEnd) >> 1

    local function shouleFindAfter(nPos)
        return (fCmpFunc(tToSearch[nPos], value) and bSmallToLarge) or (not (fCmpFunc(tToSearch[nPos], value) or bSmallToLarge))
    end

    while nBegin <= nEnd do
        if fEqual(tToSearch[nMid], value) then
            return nMid
        end

        if shouleFindAfter(nMid) then
            nBegin = nMid + 1
            nMid = (nBegin + nEnd) >> 1
        else
            nEnd = nMid - 1
            nMid = (nBegin + nEnd) >> 1
        end
    end

    return -1
end

function hashTable2Array(t)
    local tr = {}
    if not t then
        return tr
    end

    local n = 1
    for v in pairs(t) do
        tr[n] = v
        n = n + 1
    end
    return tr
end

function array2HashTable(t)
    local tr = {}
    if not t then
        return tr
    end

    for _, v in ipairs(t) do
        tr[v] = true
    end
    return tr
end

function reverseTable(tTable)
    assert(tTable)
    local len = #tTable
    if len > 1 then
        local n = math.floor(len / 2)
        for i = 1, n do
            local i2 = len - i + 1
            tTable[i], tTable[i2] = tTable[i2], tTable[i]
        end
    end
    return tTable
end

local function _tableAddNumber(tb, nOffset)
    for k, v in pairs(tb) do
        if type(v) == "number" then
            tb[k] = v + nOffset
        elseif type(v) == "table" then
            _tableAddNumber(v, nOffset)
        end
    end
end

--@desc 生成源table的一个影子table,源table赋值会同步到影子table
--      影子table的每个number值会有偏移
--      用于检查内存是否被修改
--@param 源table, 偏移值nOffset
function genShadowTable(tSource, nOffset)
    local tNew = {}
    local tShadow = TableUtil.clone(tSource)
    _tableAddNumber(tShadow, nOffset)
    local mt = {
        __index = tSource,
        __newindex = function(t, k, v)
            rawset(tSource, k, v)
            if type(v) == "number" then
                -- rawset(tShadow, k, v)
                rawset(tShadow, k, v + nOffset)
            end
        end
    }
    setmetatable(tNew, mt)
    return tNew, tShadow
end

--@desc tb2的元素tb1是
function isEqual(tb1, tb2, nOffset)
    if not tb1 or not tb2 then
        return
    end
    if tb1 == tb2 then
        return true
    end

    for k, v in pairs(tb2) do
        if tb1[k] then
            if type(tb1[k]) ~= "table" and type(tb2[k]) ~= "table" then
                if type(tb1[k]) == "number" then
                    if tb1[k] + nOffset ~= tb2[k] then
                        return false, k
                    end
                else
                    if tb1[k] ~= tb2[k] then
                        return false, k
                    end
                end
            elseif type(tb1[k]) == "table" and type(tb2[k]) == "table" then
                if not isEqual(tb1[k], tb2[k], nOffset) then
                    return false, k
                end
            end
            -- print("k==", k, tb1[k], tb2[k])
        end
    end
    return true
end

--将tb2的value插入到tb1, 不保证插入的顺序与tb2原顺序相同
function extend(tb1, tb2)
    if not tb1 or not tb2 then
        printError("extend error, table is nil  tb1 = ", tb1, " tb2 = ", tb2)
        return
    end

    for key, value in pairs(tb2) do
        table.insert(tb1, value)
    end
end

local function set(tb, bMergeRepeat)
    local set = {}
    for _, val in ipairs(tb) do
        if bMergeRepeat then
            set[val] = true
        else
            if not set[val] then
                set[val] = 0
            else
                set[val] = set[val] + 1
            end
        end
    end
    return set
end

-- @desc 判断列表tb2是否是列表tb1的子集
-- @param tb1: b为a的子集中的a
--        tb2: b为a的子集中的b
--        bMergeRepeat: true表示合并重复项，nil/false表示不合并重复项
function isArraySubset(tb1, tb2, bMergeRepeat)
    local set1 = set(tb1, bMergeRepeat)
    local set2 = set(tb2, bMergeRepeat)
    for k, v in pairs(set2) do
        if not set1[k] then
            return false
        end
        if not bMergeRepeat then
            if v > set1[k] then
                return false
            end
        end
    end
    return true
end

-- 获取两个列表的并集
function getUnion(a, b)
    local set = {}
    for _, v in ipairs(a) do
        set[v] = true
    end
    for _, v in ipairs(b) do
        set[v] = true
    end
    return keys(set)
end


--@desc 堆排序 获取列表中前k个元素
--@param bSorted:返回的k个元素是否需要排序
function getTop(arr, k, compareFunc, bSorted)
    local heap = {}
    local nLength = #arr
    k = nLength > k and k or nLength
    
    local function heapify(idx, size)
        local left = 2 * idx
        local right = 2 * idx + 1
        local smallest = idx

        if left <= size and compareFunc(arr[smallest],arr[left]) then
            smallest = left
        end

        if right <= size and compareFunc(arr[smallest],arr[right]) then
            smallest = right
        end

        if smallest ~= idx then
            arr[idx], arr[smallest] = arr[smallest], arr[idx]
            heapify(smallest, size)
        end
    end

    for i = math.floor(k / 2), 1, -1 do
        heapify(i, k)
    end

    for i = k + 1, nLength  do
        if compareFunc(arr[i],arr[1]) then
            arr[i], arr[1] = arr[1], arr[i]
            heapify(1, k)
        end
    end

    if bSorted then 
        for i = k, 1, -1 do
            heap[i] = arr[1]
            arr[i], arr[1] = arr[1], arr[i]
            heapify(1, i-1)
        end
    else 
        for i = 1, k do
            heap[i] = arr[i]
        end
    end 

    return heap
end
