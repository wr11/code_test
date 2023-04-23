-- Υ���ʿ�
local forbiddenWords = {"Υ����1", "Υ����2", "Υ����3"}

-- ��������ı����Ƿ����Υ������
function checkForbiddenWords(text)
    for i, word in ipairs(forbiddenWords) do
        if string.find(text, word, 1, true) then
            return true
        end
    end
    return false
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