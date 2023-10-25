import time
import pyautogui
import keyboard
import pydirectinput

# a=int(input("点击次数："))
# b=float(input("点击间隔/s："))
# c=float(input("将鼠标移动至指定位置所需要的时间/s："))

# print("请开始移动鼠标，%s秒后开始点击"%(c))
# time.sleep(c)

# z=pyautogui.position()

# print("移动结束，当前鼠标位置：", z)
# print("连续点击开始，间隔%s, 按esc可以退出")

# while a>0:
#     pyautogui.click(z[0], z[1])
#     a-=1
#     time.sleep(b)
#     if keyboard.is_pressed("esc"):
#         break

pydirectinput.moveTo(1570, 400)
pydirectinput.doubleClick()