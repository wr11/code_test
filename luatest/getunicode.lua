-- 获取一个中文字符的Unicode值
function getSimpleUnicode(char)
    local byte1, byte2, byte3 = string.byte(char, 1, 3)
    local unicode = ((byte1 - 0xE0) * 0x1000) + ((byte2 - 0x80) * 0x40) + (byte3 - 0x80)
    return unicode
end

function getTraditionUnicode(char)
    local byte1, byte2 = string.byte(char, 1, 2)
    local unicode = ((byte1 - 0x81) * 0x100) + (byte2 - 0x40)
    if unicode >= 0x7F00 then
      unicode = unicode + 0x10000
    end
    return unicode
end
  -- 测试
local char1 = "鏡"
local char2 = "镜"
local unicode1 = getSimpleUnicode(char1)
local unicode2 = getSimpleUnicode(char2)

local unicode3 = getTraditionUnicode(char1)
local unicode4 = getTraditionUnicode(char2)
print(unicode1, unicode2)
print(unicode3, unicode4)