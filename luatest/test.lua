-- require "util"

-- local t = {
--     {_id = "100001,1", nTime = 10},
--     {_id = "100001,2", nTime = 10},
--     {_id = "200001,2", nTime = 10},
--     {_id = "100001,3", nTime = 11},
--     {_id = "100001,4", nTime = 13},
-- }
-- table.sort(t, function(a,b)
--     if a.nTime == b.nTime then
--         return a._id > b._id
--     else
--         return a.nTime > b.nTime
--     end
-- end)
-- PT(t)

-- function exampleFunction()
--     print("This is an example function.")
--   end
   
--   -- 获取函数信息
--   local info = debug.getinfo(exampleFunction)
--    print(info.short_src)
--   -- 打印函数信息
--   for k, v in pairs(info) do
--     if type(v) ~= 'table' then
--       print(k, ':', v)
--     end
--   end

a = {[3]={{true,{{_id="554505001_5",nBase=0,nCheckTime=1726634841,nGrading=1,nHot=63,nLastHot=63,nLikes=1,nPublishIdx=5,nPushs=43,nReviewState=1,nRoleId=554505001,nStars=0,nSvrId=5001,nTag=2,nTime=1726324092,nViewDayNo=261,nViewDayNums=3,nViewNums=21,nViewWeekNo=37,nViewWeekNums=12,sDesc="",sRoleName="蟑螂恶霸",sTitle="龙猫",tComment={0},tPics={nOrigin=1,tUrls={"http://g119.fp.ps.netease.com/file/66e59d7c1843db3620d4a832mDkMsLvW05"}}}}}},[4]={{true,{{_id="454005001_6",nBase=0,nCheckTime=1726633617,nGrading=1,nHot=86,nLastHot=86,nLikes=5,nPublishIdx=6,nPushs=53,nReviewState=1,nRoleId=454005001,nStars=0,nSvrId=5001,nTag=2,nTime=1726327925,nViewDayNo=261,nViewDayNums=1,nViewNums=22,nViewWeekNo=37,nViewWeekNums=8,sDesc="她的名字丢啦，快教她捡回去！",sRoleName="醒醒",sTitle="收徒，空中习武",tComment={0},tPics={nOrigin=1,tUrls={"http://g119.fp.ps.netease.com/file/66e5ac7509cff7b1d795e909j18SA0GQ05"}}}}}},[5]={{true,{{_id="43405001_2",nBase=0,nCheckTime=1726646461,nGrading=1,nHot=77,nLastHot=77,nLikes=2,nPublishIdx=2,nPushs=9,nReviewState=1,nRoleId=43405001,nStars=0,nSvrId=5001,nTag=2,nTime=1726328746,nViewDayNo=260,nViewDayNums=6,nViewNums=24,nViewWeekNo=37,nViewWeekNums=11,sDesc="",sRoleName="忘川",sTitle="我的基地家居随拍",tComment={0},tPics={nOrigin=1,tUrls={"http://g119.fp.ps.netease.com/file/66e5afaaa9316067f90accaeEaijzVlb05"}}}}}},[6]={{true,{{_id="903005001_1",nBase=51,nCheckTime=1726588119,nGrading=1,nHot=12,nLastHot=12,nLikes=1,nPublishIdx=1,nPushs=64,nReviewState=1,nRoleId=903005001,nStars=0,nSvrId=5001,nTag=2,nTime=1726391702,nViewDayNo=260,nViewDayNums=2,nViewNums=4,nViewWeekNo=37,nViewWeekNums=3,sDesc="",sRoleName="仓鼠",sTitle="我的基地家居随拍",tComment={0},tPics={nOrigin=1,tUrls={"http://g119.fp.ps.netease.com/file/66e6a596dfe77bbec808cdbaci18rIvD05"}}},{_id="1090205001_1",nBase=121,nGrading=1,nHot=0,nLikes=0,nPublishIdx=1,nPushs=24,nReviewState=1,nRoleId=1090205001,nStars=0,nSvrId=5001,nTag=3,nTime=1726414871,nViewDayNo=258,nViewDayNums=0,nViewNums=0,nViewWeekNo=36,nViewWeekNums=0,sDesc="",sRoleName="一只摆烂的鱼",sTitle="我的随拍",tComment={0},tPics={nOrigin=2,tUrls={"http://g119.fp.ps.netease.com/file/66e70017a07d6cd0fff4acdcteUMFfip05"}}}}}},[7]={{true,{{_id="2063505001_1",nBase=0,nCheckTime=1726631416,nGrading=1,nHot=71,nLastHot=71,nLikes=1,nPublishIdx=1,nPushs=63,nReviewState=1,nRoleId=2063505001,nStars=0,nSvrId=5001,nTag=1,nTime=1726306504,nViewDayNo=261,nViewDayNums=2,nViewNums=22,nViewWeekNo=37,nViewWeekNums=15,sDesc="",sRoleName="煎饼狗子",sTitle="我美吗",tComment={0},tPics={nOrigin=3,data={nOrigin=3,nSex=2,sType="Cloth",tClothData={["2"]={nBigType=10,nCfgId=252034,tDyeItem={["290030"]=1,["290037"]=1}},["3"]={nBigType=10,nCfgId=411223,tDyeItem={}},["5"]={nBigType=10,nCfgId=411225,tDyeItem={}}},tDyeData={["252034"]={["1"]={nColorId=2,nDyeItemId=290037,nStrength=1.0},["2"]={nColorId=4,nDyeItemId=290030,nStrength=1.0}},["411223"]={},["411225"]={}}},tUrls={"http://g119.fp.ps.netease.com/file/66e558c8a43d001ffaba57dcWO2PPwAO05"}}}}}}}
print(#a)