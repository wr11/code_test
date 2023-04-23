-- 违禁词库
local forbiddenWords = {"(违禁词1)", "(违禁词2)", "(违禁词3)"}

-- 构造正则表达式
local pattern = table.concat(forbiddenWords, "|")

-- 检查输入文本中是否包含违禁词语
function checkForbiddenWords(text)
    print("====", pattern)
    return string.find(text, pattern) ~= nil
end

-- 读取用户输入的文本
print("请输入一段文字：")
local inputText = io.read("*l")

-- 检查输入文本中是否包含违禁词语
if checkForbiddenWords(inputText) then
    print("输入文本包含违禁词语！")
else
    print("输入文本不包含违禁词语。")
end