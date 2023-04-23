local utf8 = require("utf8")

function containsTraditionalChinese(text)
  for _, c in utf8.codes(text) do
    -- 判断字符是否为繁体字
    if c >= 0x4E00 and c <= 0x9FFF and traditionalChineseChars[c] then
      return true
    end
  end
  return false
end

-- 繁体字对应的 Unicode 码值范围
traditionalChineseChars = {}
--   [0x4E00] = true, [0x4E01] = true, [0x4E03] = true, [0x4E07] = true,
--   [0x4E08] = true, [0x4E09] = true, [0x4E0A] = true, [0x4E0B] = true,
--   -- ... 省略部分范围
--   [0x9FCC] = true, [0x9FCD] = true, [0x9FCE] = true, [0x9FCF] = true


for i = 0x4E00, 0x9FCF do
    traditionalChineseChars[i] = true
end

-- 示例用法
local text = "中国"
if containsTraditionalChinese(text) then
  print("yes")
else
  print("fasle")
end