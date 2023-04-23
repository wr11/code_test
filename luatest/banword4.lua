-- Trie树
require "util"

local Trie = {}

function Trie:new()
    local trie = {}
    setmetatable(trie, self)
    self.__index = self
    trie.root = {}  -- 使用空表作为根节点
    return trie
end

function Trie:insert(word)
    local node = self.root
    for i = 1, #word do
        local char = string.sub(word, i, i)
        if not node[char] then
            node[char] = {}  -- 如果不存在该子节点，则创建一个空表
        end
        node = node[char]
    end
    node.isEnd = true  -- 标记为一个单词的结尾
end

function Trie:search(text)
    local node = self.root
    local banWord = {}
    for i = 1, #text do
        local char = string.sub(text, i, i)
        local lastNode = node
        if not node[char] then
            if lastNode.isEnd then
                return true, banWord
            end
            node = self.root
        end
        if node[char] then
            node = node[char]
            table.insert(banWord, char)
        end
    end
    if node.isEnd then
        return true, banWord  -- 如果当前节点是某个单词的结尾，则说明包含违禁词
    end
    return false, banWord
end

-- 创建一个Trie树，并插入违禁词
local trie = Trie:new()
local forbiddenWords = {"违禁词1"}
-- local forbiddenWords = {"ban1", "ban2", "ban3"}
for _, word in ipairs(forbiddenWords) do
    trie:insert(word)
end

local bBan, word = trie:search("woshi 违禁词")
print(bBan, table.concat(word))

-- -- 读取用户输入的文本
-- print("请输入一段文字：")
-- local inputText = io.read("*l")

-- -- 检查输入文本中是否包含违禁词语
-- if trie:search(inputText) then
--     print("输入文本包含违禁词语！")
-- else
--     print("输入文本不包含违禁词语。")
-- end