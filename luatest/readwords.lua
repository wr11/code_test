local forbiddenWords = {} -- 定义列表

local file = io.open("forbiddenWords.txt", "r") -- 打开forbiddenWords.txt文件
if file then
  for line in file:lines() do -- 逐行读取文件内容
    if line ~= "" then -- 判断是否为空行
      table.insert(forbiddenWords, line) -- 将每行数据加入列表
    end
  end
  file:close() -- 关闭文件
end

-- 打印列表中的数据
for i, word in ipairs(forbiddenWords) do
  print(i, word)
end