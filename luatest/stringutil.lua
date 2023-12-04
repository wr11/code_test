---@module StringUtil
local _ENV = moduleDef("StringUtil", {})

------------------------------------------------------
--
-- 专门处理string相关
-- 
-- 接口：
-- split(str, delimiter, isToNumber, maxSplit)
-- contains(s, str)
-- isStart(s, prefix)
-- isEnd(s, suffix)
--
------------------------------------------------------

-- 字符串分割（正则无效）
function split(str, delimiter, isToNumber, maxSplit)
    maxSplit = maxSplit or #str
    local result = {}
    local from  = 1
    local v
    local cSplit = 0
    local delim_from, delim_to = string.find(str, delimiter, from, true)
    while delim_from and cSplit < maxSplit do
        v = string.sub(str, from , delim_from-1 )
        if isToNumber then
            v = tonumber(v)
        end
        table.insert(result, v)
        cSplit = cSplit + 1
        from  = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from, true)
    end
    v = string.sub( str, from)
    if isToNumber then
        v = tonumber(v) 
    end
    table.insert(result, v)
    return result
end

function replace(str, old, new)
    return string.gsub(str, old, new)
end

function split2Number(str, delimiter)
    return split(str, delimiter, true)
end

-- 字符串s是否包含str（正则无效）
function contains(s, str)
    local start = string.find(s, str, 1, true)
    return start ~= nil and start >= 1
end

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

function getAllTextFromFile(path)
    local file = io.open(path, "r")
    local text = file:read("*a")
    file:close()
    return text
end

function isEmpty(s)
    return s == nil or s == ""
end

function trim(str)
    if not str then
        return
    end
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
end


-- fmt的格式 absasd{1}asdad{2}adasd{3}
-- 其中{}中的值可以是任意字符串或者数字，数字的话不一定要按大小顺序。 tParams的key只要对应{}中的值就可以
-- 当tParams中有num键值的时候，isStrKey使用true，不然会匹配不到
function formatDesc(fmt, tParams, isStrKey)
    local _tParams
    if not isStrKey then
        _tParams = {}
        for k, v in pairs(tParams) do
            _tParams[tostring(k)] = v
        end
    else
        _tParams = tParams
    end

    local ret = string.gsub(fmt, "{(%w+)}", _tParams)
    return ret
end

function getStrPsSkParams(sFmt, tPsSkParams)
    if not tPsSkParams then
        return {}
    end
    local tParams = {}
    local bPercent
    for sIndex, sPercent in string.gmatch(sFmt, "{PsSk(%d+)(%%?)}") do
        bPercent = not isEmpty(sPercent)
        tParams[sIndex] = RoleAttrCfgMod.toAttrValueStringOverload(bPercent, tPsSkParams[tonumber(sIndex)])
    end
    return tParams
end

local function matchPsSkKey(sCapture)
    return string.match(sCapture, "PsSk(%w+)")
end

local function getReplByNumKey(sCapture, tParams, tPsSkParams)
    local sPsSkKey = matchPsSkKey(sCapture)
    if sPsSkKey then
        return tPsSkParams[tonumber(sPsSkKey)]
    else
        return tParams[tonumber(sCapture)]
    end
end

local function getReplByStrKey(sCapture, tParams, tPsSkParams)
    local sPsSkKey = matchPsSkKey(sCapture)
    if sPsSkKey then
        return tPsSkParams[sPsSkKey]
    else
        return tParams[sCapture]
    end
end

function formatDescWithPsSk(sFmt, tParams, tPsSkParams, bIsStrKey)
    tParams, tPsSkParams = tParams or {}, tPsSkParams or {}

    local fGetRepl = bIsStrKey and getReplByStrKey or getReplByNumKey
    local sNew = string.gsub(sFmt, "{(%w+)%%?}", function (sCapture)
        return fGetRepl(sCapture, tParams, tPsSkParams)
    end)
    return sNew
end

--是否包含数字
function isContainNums(str)
    return string.find(str, "%d")
end

function nonBreakingSpace()
    return " "
end

--只包含中文、字母和数字
function onlyContainChineseAndAlphaAndNum(str)
    for i,codePoint in utf8.codes(str) do 
        --unicode编码象形文字 CJK Unified Ideographs
        if not ( codePoint >= 0x4E00 and codePoint <= 0x9FFF )  and
                --大写字母
                not (codePoint >= 0x41 and codePoint <= 0x5a) and
                --小写字母
                not (codePoint >= 0x61 and codePoint <= 0x7a) and
                --数字
                not (codePoint >= 48 and codePoint <= 57)  then
            return false
        end
    end
    return true
end

--只包含字母和空格
function onlyContainAlphaAndSpaceAndNum(str)
    for i,codePoint in utf8.codes(str) do
        if not (codePoint >= 0x41 and codePoint <= 0x5a) and --大写字母
                not (codePoint >= 0x61 and codePoint <= 0x7a) and --小写字母
                not (codePoint == 32) and      --空格
                not (codePoint >= 48 and codePoint <= 57) then --数字
            return false
        end
    end
    return true
end

function onlyWhiteSpace(str)
    for _,codePoint in utf8.codes(str) do 
        if codePoint ~= 32 then 
            return false
        end
    end
    return true
end

--是否包含一些标记符号，用以聊天文本输入判断
function isContainMarkup(str)
    return string.find(str,"<.->")
end

function checkVersionFormat(sVersion)
    local tVersion = split2Number(sVersion, ".")
    return #tVersion == 4 and 
        type(tVersion[1]) == "number" and 
        type(tVersion[2]) == "number" and 
        type(tVersion[3]) == "number" and 
        type(tVersion[4]) == "number"
end

--
-- lua
-- 判断utf8字符byte长度
-- 0xxxxxxx - 1 byte
-- 110yxxxx - 192, 2 byte
-- 1110yyyy - 225, 3 byte
-- 11110zzz - 240, 4 byte
local function chsize(char)
    if not char then
        print("not char")
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end


-- 截取utf8 字符串
-- str:            要截取的字符串
-- startChar:    开始字符下标,从1开始
-- numChars:    要截取的字符长度
function utf8sub(str, startChar, numChars)
    local startIndex = 1
    while startChar > 1 do
        local char = string.byte(str, startIndex)
        startIndex = startIndex + chsize(char)
        startChar = startChar - 1
    end
 
    local currentIndex = startIndex
 
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chsize(char)
        numChars = numChars -1
    end
    return str:sub(startIndex, currentIndex - 1)
end

--添加...
function shortHand(str, numChars)
    if utf8.len(str) <= numChars then
        return str
    else
        return utf8sub(str, 1, numChars).."..."
    end
end


function rfind(str, key)
	local rstr = string.reverse(str)
	local _, pos = string.find(rstr, key)
    if pos == nil then
        return pos
    end
	local rPos = string.len(rstr) - pos + 1
    return rPos
end

function insertStr(str,index,insertStr, flag)
    if flag and string.find(str, flag) ~=nil then
        index = index + #flag
    end
    local pre = string.sub(str, 1, index -1)
    local tail = string.sub(str, index, -1)
    local createStr = string.format("%s%s%s", pre, insertStr, tail)
    return createStr
end

function isContainChinese(str)
    for i, codePoint in utf8.codes(str) do 
        if (codePoint >= 0x4E00 and codePoint <= 0x9FFF) then
            return true
        end
    end
end

-- return str, bChange
function getNACorrectStr(str)
    if not isNA() then return str end

    if isContainChinese(str) then
        local sCorrect = ""
        local nStart
        for i, codePoint in utf8.codes(str) do 
            if not (codePoint >= 0x4E00 and codePoint <= 0x9FFF) then
                if not nStart then
                    nStart = i
                end
            else
                if nStart then
                    sCorrect = sCorrect .. str:sub(nStart, i - 1)
                    nStart = nil
                end
            end
        end
        if nStart then
            sCorrect = sCorrect .. str:sub(nStart, -1)
            nStart = nil
        end
        return sCorrect, true
    end
    return str, false
end

function getBindingDisplayString(displayString, controlPath, bSetting)
    --print("***************controlPath", controlPath)
    local s = displayString
    if controlPath then
        if controlPath == "leftAlt" then
            s = "LAlt"
        elseif controlPath == "rightAlt" then
            s = "RAlt"
        elseif controlPath == "leftCtrl" then
            s = "LCtrl"
        elseif controlPath == "rightCtrl" then
            s = "RCtrl"
        elseif controlPath == "leftShift" then
            s = "LShift"
        elseif controlPath == "rightShift" then
            s = "RShift"
        elseif controlPath == "escape" then
            s = "Esc"
        elseif controlPath == "capsLock" then
            s = "Caps"
        elseif controlPath == "pageUp" then
            s = "PgUp"
        elseif controlPath == "pageDown" then
            s = "PgDn"
        elseif controlPath == "backspace" then
            s = "BS"
        elseif controlPath == "insert" then
            s = "Ins"
        elseif controlPath == "" then
            s = _T("key_not_bind")
        elseif string.match(controlPath, "numpad") then --小键盘特殊处理
            local sTmp = string.gsub(controlPath, "numpad", "")
            if sTmp == "Period" then
                sTmp = "."
            elseif sTmp == "Divide" then
                sTmp = "/"
            elseif sTmp == "Multiply" then
                sTmp = "*"
            elseif sTmp == "Plus" then
                sTmp = "+"
            elseif sTmp == "Minus" then
                sTmp = "-"
            end
            s = "Num "..sTmp
        end
    end
    if bSetting and s == "" then
        s = _T("key_not_bind")
    end
    return s
end

function getQuickToUseBindKey(sBtnName)
    if sBtnName == _T("tips_btn_use") then
        return "E"
    elseif sBtnName == _T("tips_btn_destroy") then
        return "F"
    elseif sBtnName == _T("put_to_quick_to_use") then
        return "E"
    elseif sBtnName == _T("pvpbag_throwaway") then
        return "F"
    end
end

function firstToUpper(str)
    return (str:gsub("^%l",string.upper))
end

function utf8len(str)
    local len = 0
    for i = 1, #str do
        local byte = string.byte(str, i)
        if byte >= 0xC0 and byte <= 0xFD then
            len = len + 1
            i = i + 2
        else
            len = len + 1
        end
    end
    return len
end

function fillLenWithDefaultChar(sString, nLen, sDefault)
    if #sString >= nLen then
        return sString
    end
    local nDiff = nLen - #sString
    local t = {sString}
    for i = 1, nDiff do
        table.insert(t, sDefault)
    end
    return table.concat(t)
end

function stringToCharArray(str)
    local char_array = SimpleTypeWriterMod.getWordTable(str)
    return char_array
end

