import numpy as np

# 计算分位数示例
data = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]

# 计算不同分位数
q1 = np.quantile(data, 0.25)  # 第一四分位数
median = np.quantile(data, 0.5)  # 中位数
q3 = np.quantile(data, 0.75)  # 第三四分位数

print(f"Q1(25%分位数): {q1}")
print(f"中位数(50%分位数): {median}")
print(f"Q3(75%分位数): {q3}")