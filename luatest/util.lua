-- 将 Lua table 类型数据转换成字符串
-- 判断字符串str是否start开头
function isStart(s, prefix)
    if prefix == nil then return true end
    return string.sub(s,1,string.len(prefix)) == prefix
end

-- 判断字符串str是否end结尾
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

-- 打印 Lua table 类型数据
function printTable(t)
    print(table2strNoFormat(t))
end

local t = {
    name = "张三",
    age = 18,
    gender = "男",
    interests = {"游泳", "篮球", "音乐"},
    job = {
        title = "软件工程师",
        salary = 10000
    }
}

-- printTable(t)