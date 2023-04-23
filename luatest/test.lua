-- 判断一个字符是否为繁体字
function isTraditionalChar(char1, char2)
    local pattern1 = "[\227-\255]"
    local b1 = string.match(char1, pattern1)
    local pattern2 = "[\128-\191]"
    local b2 = string.match(char2, pattern2)

    if b1 and b2 then
        return true
    else
        return false
    end
end

-- 检测一个字符串中是否有繁体字
function hasTraditionalChar(str)
  local len = string.len(str)
  for i = 1, len, 2 do
    if i + 1 > len then
        return false
    end
    local char1 = string.sub(str, i, i)
    local char2 = string.sub(str, i+1, i+1)
    if isTraditionalChar(char1, char2) then
      return true
    end
  end
  return false
end

-- 测试
local str1 = "abc123"
local str2 = "镜国文简体"
local str3 = "鏡國繁體字"
print(hasTraditionalChar(str1)) -- false
print(hasTraditionalChar(str2)) -- false
print(hasTraditionalChar(str3)) -- true

print(string.byte('國'))
print(string.byte('国'))