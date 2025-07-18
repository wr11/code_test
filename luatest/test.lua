require "util"

-- local t = {
--     {_id = "100001,1", nTime = 10},
--     {_id = "100001,2", nTime = 10},
--     {_id = "200001,2", nTime = 10},
--     {_id = "100001,3", nTime = 11},
--     {_id = "100001,4", nTime = 13},
-- }
-- table.sort(t, function(a,b)
--     if a.nTime == b.nTime then
--         return a._id > b._id
--     else
--         return a.nTime > b.nTime
--     end
-- end)
-- PT(t)

-- function exampleFunction()
--     print("This is an example function.")
--   end
   
--   -- 获取函数信息
--   local info = debug.getinfo(exampleFunction)
--    print(info.short_src)
--   -- 打印函数信息
--   for k, v in pairs(info) do
--     if type(v) ~= 'table' then
--       print(k, ':', v)
--     end
--   end

-- a = {1,2,3,4,4,5}
-- for i = 1,#a do
--     if a[i] == 4 then
--         table.remove(a, i)
--     end
-- end
-- PT(a)

local a = {}
local m = 100000
for i = 1, 100000 do
    a[tostring(i)] = true
end
local time1 = os.clock()
for i = 1, 10000000 do
    k = a["100000"]
end
local time2 = os.clock()
print(time2 - time1)