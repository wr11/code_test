-- 定义一个包含繁体中文的字符串
-- local str = "繁體中文測試"
local str = "简体中文测试"

-- 定义一个正则表达式模式
local pattern = "[\u{4e00}-\u{9fff}\u{3400}-\u{4dbf}\u{20000}-\u{2a6df}\u{2a700}-\u{2b73f}\u{2b740}-\u{2b81f}\u{2b820}-\u{2ceaf}\u{f900}-\u{faff}\u{2f800}-\u{2fa1f}]"

-- 使用string.match函数匹配字符串中是否包含正则表达式模式
if string.match(str, pattern) then
    print("true")
else
    print("false")
end