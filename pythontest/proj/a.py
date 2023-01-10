# def A():
# 	pass

# def OnReload():
# 	A()

# import pymysql
# import pymysql.cursors
# from msgpack import packb, unpackb

# class CMysqlConn:
# 	def __init__(self, sCursorType="DictCursor"):
# 		self.m_Config = {
# 			"host":'localhost',
# 			"user":'root',
# 			"password":'mytool2021',
# 			"db":'test',
# 			"charset":'utf8',
# 			"cursorclass":eval("pymysql.cursors.%s" % sCursorType),
# 		}
# 		self.m_Conn = self.MakeConnection()

# 	def MakeConnection(self):
# 		conn = pymysql.connect(**self.m_Config)
# 		return conn

# 	def GetConnection(self):
# 		return self.m_Conn

# if "g_MysqlConn" not in globals():
# 	g_MysqlConn = CMysqlConn()

# def GetMysqlConnect():
# 	return g_MysqlConn.GetConnection()

# def A():
# 	con = GetMysqlConnect()
# 	d = {"content":"hhhhhh", "pass":"1231", "type":1}
# 	d1 = {"content":"ffghfg", "pass":"165", "type":2}
# 	# data1 = (3, packb(d))
# 	# data2 = (4, packb(d1))
# 	# lst = [str(data1), str(data2)]
# 	# lstVal = ",".join(lst)
# 	lstVal = "(%s,%s),(%s,%s)"
# 	with con.cursor() as oCursor:
# 		# sSqlState = "insert into test values %s"%lstVal
# 		# oCursor.execute(sSqlState, [3, packb(d), 4, packb(d1)])
# 		# result = oCursor.fetchall()
# 		# print(result)

# 		lstFilter = [[1,2],]
# 		sSqlState = "select * from test where id in %s"
# 		oCursor.execute(sSqlState, lstFilter)
# 		result = oCursor.fetchall()
# 		print(result)
# 	con.commit()

# A()

# def A(a):
# 	match a:
# 		case 1:
# 			print("ssssss")
# 		case _:
# 			print("ddddd")

# A(1)
# A(2)

def GGG():
	a=600606
	print("test GGG", a)