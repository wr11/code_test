local str = "中文繁體字"
for char in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
    local code = utf8.codepoint(char)
    if code >= 0x4E00 and code <= 0x9FFF and code < 0x3400 or code > 0x4DBF and code < 0x20000 or code > 0x2A6DF then
        -- 这是一个中文繁体字
        -- 可以在这里进行处理，比如计数或者替换成其他字符
        print("=============")
    else
        -- 不是中文繁体字
        print("----------")
    end
end