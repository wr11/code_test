sequences = [
    [5,8,2,7],
    [1,6,5,3],
    [1,9,6,4],
    [1,6,7,6],
    [4,0,2,0],
    [2,0,4,4],
    [4,1,8,1],
    [2,6,1,0],
    [3,1,4,3],
    [7,9,2,5],
]

# sequences = [
#     [9,8,8,4],
#     [8,9,2,9],
#     [0,5,1,4],
#     [3,4,1,1],
#     [9,1,7,5],
#     [3,2,3,4],
#     [2,0,9,9],
#     [5,9,9,0],
#     [4,3,5,1],
#     [6,7,9,3],
# ]

statistic = {0:0, 1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0, 8:0, 9:0}
for i in range(len(sequences)):
    for j in range(len(sequences[i])):
        statistic[sequences[i][j]] += 1
statistic = sorted(statistic.items(), key=lambda x: x[1], reverse=True)
print(statistic)

num = [8,9,7,5,3,0,6,2,4,1]
gai = [1,0.5,0.5,0.5,0.5,0.7,0.7,0.5,0.5,0.3]