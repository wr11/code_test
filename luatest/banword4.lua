-- Trie��
require "util"

local Trie = {}

function Trie:new()
    local trie = {}
    setmetatable(trie, self)
    self.__index = self
    trie.root = {}  -- ʹ�ÿձ���Ϊ���ڵ�
    return trie
end

function Trie:insert(word)
    local node = self.root
    for i = 1, #word do
        local char = string.sub(word, i, i)
        if not node[char] then
            node[char] = {}  -- ��������ڸ��ӽڵ㣬�򴴽�һ���ձ�
        end
        node = node[char]
    end
    node.isEnd = true  -- ���Ϊһ�����ʵĽ�β
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
        return true, banWord  -- �����ǰ�ڵ���ĳ�����ʵĽ�β����˵������Υ����
    end
    return false, banWord
end

-- ����һ��Trie����������Υ����
local trie = Trie:new()
local forbiddenWords = {"Υ����1"}
-- local forbiddenWords = {"ban1", "ban2", "ban3"}
for _, word in ipairs(forbiddenWords) do
    trie:insert(word)
end

local bBan, word = trie:search("woshi Υ����")
print(bBan, table.concat(word))

-- -- ��ȡ�û�������ı�
-- print("������һ�����֣�")
-- local inputText = io.read("*l")

-- -- ��������ı����Ƿ����Υ������
-- if trie:search(inputText) then
--     print("�����ı�����Υ�����")
-- else
--     print("�����ı�������Υ�����")
-- end