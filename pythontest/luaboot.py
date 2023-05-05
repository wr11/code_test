from lupa import LuaRuntime
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute('require("start")')
dict = lua.globals()._cfg.CfgSeriesEventEvent
for k, v in dict.items():
    for m,n in v.items():
        print(n)