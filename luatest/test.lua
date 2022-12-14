function a()
    local k=10
    b(function()
        print("ffffff",k)
    end)
end

function b(fun)
    fun()
end

a()