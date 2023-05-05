class TreeNode:
    def __init__(self):
        self.children = {}
        self.is_word = False

class Tree:
    def __init__(self):
        self.root = TreeNode()

    def insert(self, word):
        node = self.root
        for c in word:
            if c not in node.children:
                node.children[c] = TreeNode()
            node = node.children[c]
        node.is_word = True

    def search(self, word):
        node = self.root
        banword = ""
        for c in word:
            if c not in node.children:
                if node.is_word:
                    return True, banword
                node = self.root
            else:
                node = node.children[c]
                banword = banword + c
        if node.is_word:
            return True, banword
        else:
            return False, banword
        
    def searchall(self, word):
        node = self.root
        banword = ""
        banwords = []
        for c in word:
            if c not in node.children:
                if node.is_word:
                    banwords.append(banword)
                    banword = ""
                node = self.root
                if c in node.children:
                    node = node.children[c]
                    banword = banword + c
            else:
                node = node.children[c]
                banword = banword + c
        if node.is_word:
            banwords.append(banword)
        return banwords

BANNED_WORDS = ['我', '违禁词', '你']

tree = Tree()
for word in BANNED_WORDS:
    tree.insert(word)

input_text = input("请输入一段文字：")

print(tree.searchall(input_text))