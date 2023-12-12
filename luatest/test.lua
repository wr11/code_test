require("luatest/util")

a={{10001, 20, 1}, {10002, 10, 5}, {10003, 13, 4}, {10004, 11, 2}, {10005, 5, 3}, {10006, 53, 9}, {10007, 53, 8}, {10008, 20, 6}, {10009, 3, 7}}

table.sort(a, function(a, b)      -- 选出帮贡最多，如果相同则先进入帮会的成员
    if a[2] > b[2] then
        return true
    end
    if a[2] == b[2] then
        return a[3] < b[3]
    end
end)

PT(a)