-- 定义跳表节点
require("util")

local Node = {}

Node.__index = Node


function Node.new(key, value, level)

    local self = setmetatable({}, Node)

    self.key = key

    self.value = value

    self.level = level

    self.forward = {}

    return self

end


-- 定义跳表

local SkipList = {}

SkipList.__index = SkipList


function SkipList.new(max_level, p)

    local self = setmetatable({}, SkipList)

    self.max_level = max_level or 16

    self.p = p or 0.5

    self.head = Node.new(nil, nil, self.max_level)

    return self

end


function SkipList:find(key)

    local current = self.head

    for i = self.max_level, 1, -1 do

        while current.forward[i] and current.forward[i].key < key do

            current = current.forward[i]

        end

    end

    current = current.forward[1]

    if current and current.key == key then

        return current.value

    else

        return nil

    end

end


function SkipList:insert(key, value)

    local update = {}

    local current = self.head

    for i = self.max_level, 1, -1 do

        while current.forward[i] and current.forward[i].key < key do

            current = current.forward[i]

        end

        update[i] = current

    end

    current = current.forward[1]

    if current and current.key == key then

        current.value = value

    else

        local level = 1

        while math.random() < self.p and level < self.max_level do

            level = level + 1

        end

        local node = Node.new(key, value, level)

        for i = 1, level do

            node.forward[i] = update[i].forward[i]

            update[i].forward[i] = node

        end

    end

end


function SkipList:delete(key)

    local update = {}

    local current = self.head

    for i = self.max_level, 1, -1 do

        while current.forward[i] and current.forward[i].key < key do

            current = current.forward[i]

        end

        update[i] = current

    end
    current = current.forward[1]

    if current and current.key == key then

        for i = 1, current.level do

            if update[i].forward[i] == current then

                update[i].forward[i] = current.forward[i]

            else

                break

            end

        end

    end

end

o = SkipList.new()
printTable(o)
o:insert("a", 1)
printTable(o)
o:insert("b", 2)
printTable(o)
o:insert("c", 3)
o:insert("d", 4)
o:insert("e", 5)
o:insert("f", 6)
o:insert("g", 7)
print(o:find("b"))