def A(**kwargs):
    B(**kwargs)

def B(**kwargs):
    print(kwargs)

A()