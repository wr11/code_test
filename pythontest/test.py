# throw()另外一个例子
def my_generator():
    try:
        yield 'a'
        yield 'b'
        yield 'c'
        yield 'd'
        yield 'e'
    except ValueError:
        print('触发“ValueError"了')
    except TypeError:
        print('触发“TypeError"了')

g=my_generator()
print(next(g))
print(next(g))
print('-------------------------')
print(g.throw(ValueError), "lllllllllllllllll")
# 触发异常,以下语句不执行
print('-------------------------')
print(next(g))
print(next(g))
print('-------------------------')
print(g.throw(TypeError))
print('-------------------------')
print(next(g))
