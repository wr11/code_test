LOCAL_ROOT = "proj"

import timer
import a
def Init():
	print("hotfixtest inited")
	timer.Call_out(1, "ProjReload", MyReload)

def MyReload():
	print("testing ++++++++ ")
	a.GGG()
	timer.Call_out(1, "ProjReload", MyReload)