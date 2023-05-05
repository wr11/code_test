require("util")

classDef("Return", {
    exception_type = EXCEPTION_TYPE_RETURN,
    message = "Return",
})
function Return:ctor(msg)
    self.value = msg
end

function test()
	error(Return:new(12138))
end

o = coroutine.create(test)
b, r = coroutine.resume(o)
print(b, r.value, type(r))