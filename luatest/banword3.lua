-- Υ���ʿ�
local forbiddenWords = {"(Υ����1)", "(Υ����2)", "(Υ����3)"}

-- ����������ʽ
local pattern = table.concat(forbiddenWords, "|")

-- ��������ı����Ƿ����Υ������
function checkForbiddenWords(text)
    print("====", pattern)
    return string.find(text, pattern) ~= nil
end

-- ��ȡ�û�������ı�
print("������һ�����֣�")
local inputText = io.read("*l")

-- ��������ı����Ƿ����Υ������
if checkForbiddenWords(inputText) then
    print("�����ı�����Υ�����")
else
    print("�����ı�������Υ�����")
end