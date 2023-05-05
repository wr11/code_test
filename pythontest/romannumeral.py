import re


def roman_numerals(text):
	pattern = r"[IVXLCDM]+"
	return re.findall(pattern, text)


if __name__ == '__main__':
	while True:
		a = roman_numerals(input(">>>"))
		print(a)