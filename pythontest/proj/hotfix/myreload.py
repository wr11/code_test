LOCAL_ROOT = "proj"

import timer
def Init():
	print("reload inited")
	timer.Call_out(5, "ProjReload", MyReload)

def MyReload():
	print("reloading === ")
	LookFile(True, True)
	timer.Call_out(5, "ProjReload", MyReload)

def LookFile(bReload = False, bNotifyNew = False):
	import os
	sCurPath = os.getcwd()
	sCurPath = "%s\proj"%(sCurPath)
	lstFile = os.listdir(sCurPath)
	for sName in lstFile:
		ReloadPyFile(sCurPath, sName, bReload, bNotifyNew)

def ReloadPyFile(sCurPath, sName, bReload, bNotifyNew):
	import sys
	if sName.endswith(".py"):
		if bReload:
			from importlib import reload, import_module
			lstMod = []
			sMod = sName.split(".")[0]
			iIndex = sCurPath.find(LOCAL_ROOT)
			sPath = sCurPath[iIndex + len(LOCAL_ROOT)+1:]
			if not sPath:
				lstPath = []
			else:
				lstPath = sPath.split("\\")
			if sMod not in  ("__init__",):
				lstPath.append(sMod)
			iLen = len(lstPath)
			for i in range(iLen):
				lstMod.append(".".join(lstPath[i:]))
			for sModName in lstMod:
				obj = import_module(sModName)
				oNewModule = reload(obj)
			func = getattr(oNewModule, "OnReload", None)
			if func:
				func()
	elif "." not in sName:
		import os
		sCurPath = sCurPath + "\%s"%sName
		sys.path.append(sCurPath)
		lstFile = os.listdir(sCurPath)
		for sFile in lstFile:
			ReloadPyFile(sCurPath, sFile, bReload, bNotifyNew)