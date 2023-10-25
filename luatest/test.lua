function a(...)
    print(...)
end

function b()
    arg1 = 1
    arg2 = 2
    local t = {arg1, arg2}
    table.pack(t)
    a(table.unpack(t))
end
b()