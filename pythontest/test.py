import subprocess
lua_wrapper = """
local original_globals = _G
local accessed_uninitialized = false

-- 自定义的全局表，捕获对未赋值变量的访问
local custom_globals = setmetatable({}, {
__index = function(t, k)
accessed_uninitialized = true
print("Accessed uninitialized global variable: " .. tostring(k))
end,
__newindex = original_globals
})

-- 将全局环境设置为自定义的表
setmetatable(_G, custom_globals)

-- 这里执行用户的Lua代码
%s

-- 恢复原始的全局环境，以避免污染
setmetatable(_G, {__index = original_globals, __newindex = original_globals})

if accessed_uninitialized then
os.exit(1)
end
"""

def check_uninitialized_variables(lua_code):
    # 创建一个完整的Lua脚本，包括检测未赋值变量的包装器
    complete_lua_code = lua_wrapper % lua_code
    with open('temp.lua', 'w') as file:
        file.write(complete_lua_code)

    # 使用subprocess运行Lua脚本
    try:
        subprocess.run(['lua54', 'temp.lua'], check=True)
        print("No uninitialized variables detected.")
    except subprocess.CalledProcessError:
        print("Uninitialized global variables were accessed in the Lua code.")

# 示例Lua代码
lua_code = """
a = 5
print(a)  -- 正确使用
print(b)  -- 'b' 没有被初始化，应该会被检测到
"""

check_uninitialized_variables(lua_code)