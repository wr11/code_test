
local original_globals = _G
local accessed_uninitialized = false

-- �Զ����ȫ�ֱ������δ��ֵ�����ķ���
local custom_globals = setmetatable({}, {
__index = function(t, k)
accessed_uninitialized = true
print("Accessed uninitialized global variable: " .. tostring(k))
end,
__newindex = original_globals
})

-- ��ȫ�ֻ�������Ϊ�Զ���ı�
setmetatable(_G, custom_globals)

-- ����ִ���û���Lua����

a = 5
print(a)  -- ��ȷʹ��
print(b)  -- 'b' û�б���ʼ����Ӧ�ûᱻ��⵽


-- �ָ�ԭʼ��ȫ�ֻ������Ա�����Ⱦ
setmetatable(_G, {__index = original_globals, __newindex = original_globals})

if accessed_uninitialized then
os.exit(1)
end
