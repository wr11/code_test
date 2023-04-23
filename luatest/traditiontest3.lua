local utf8 = require("utf8")
-- 要查找的字符串
local str = "啊"
print(utf8.len(str))

-- 遍历字符串中的每一个字符
for _, c in utf8.codes(str) do
    -- 判断字符是否为中文繁体字
    print(c)
end