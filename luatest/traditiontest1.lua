local text = "中文繁體字"

-- 利用正则表达式匹配繁体字
local tChinese = {}
for w in string.gmatch(text, "[\228-\233][\128-\191][\128-\191]") do
    local s = string.char(
        (string.byte(w, 1) >> 2) + 0xE0,
        (string.byte(w, 1) & 0x03) * 0x40 + (string.byte(w, 2) >> 2) + 0x80,
        (string.byte(w, 2) & 0x03) * 0x40 + (string.byte(w, 3) & 0x3F) + 0x80
    )
    if (s:match("[\233-\255][\128-\191][\128-\191]")) then
        table.insert(tChinese, s)
    end
end

-- 输出结果
for i,v in ipairs(tChinese) do
    print(v)
end