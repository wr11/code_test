--所在Excel文件:【391】系列任务_CfgSeriesEvent.xlsx
--所在标签页:事件

-- sheetName: 事件|id,INT|formal,BOOL|taskID,INT|name,STRING|title,STRING|desc,STRING

local T=TranslateConfig or function(s) return s end

local tSheet1_DefaultValue_t={taskID=0,name="",title="",desc="",}
local tSheet1_DefaultValue_mt={__index=tSheet1_DefaultValue_t}

local tSheet1_KeyIndexMap={id=1,formal=2,taskID=3,name=4,title=5,desc=6,}
local tSheet1_KeyIndex_mt={__index=function(t,k) local v=rawget(t,tSheet1_KeyIndexMap[k]) if v~=nil and v~=math.huge then return v end return tSheet1_DefaultValue_t[k] end,__pairs=function(t) return InitCfgMod.array_mt_pairs(t,tSheet1_KeyIndexMap,tSheet1_DefaultValue_t) end,__ipairs=InitCfgMod.array_mt_ipairs,}

_G._cfg.CfgSeriesEventEvent={
    --@region 【391】系列任务_CfgSeriesEvent.xlsx 事件
    [10010101]=setmetatable({10010101,true,110038,T("城内巡查110038","CfgSeriesEventEvent_name",10010101),T("城内巡查","CfgSeriesEventEvent_title",10010101),T("城里的日常巡查，是帮助你熟悉珍珠城的好差事。\n我标记了城里几处地方，过去转一转，顺便违禁词1调查下街头巷尾有没有异常情况出现。","CfgSeriesEventEvent_desc",10010101),},tSheet1_KeyIndex_mt),
    [10010102]=setmetatable({10010102,true,110039,T("城内巡查110039","CfgSeriesEventEvent_name",10010102),T("城内巡查","CfgSeriesEventEvent_title",10010102),T("城里的日常巡查，是帮助你熟悉珍珠城的好差事。\n我标记了城里几处地方，过去转一转，顺便调查下街头巷尾有没有异常情况出现。","CfgSeriesEventEvent_desc",10010102),},tSheet1_KeyIndex_mt),
    [10010201]=setmetatable({10010201,true,110040,T("商路巡查110040","CfgSeriesEventEvent_name",10010201),T("商路巡查","CfgSeriesEventEvent_title",10010201),T("城外商路的巡查，是保障斧头帮货运生意的重要一环。\n我会把巡查的地址发给你，别忘了带上家伙。要是半路遇到找茬的敌人，就顺手干掉他们。","CfgSeriesEventEvent_desc",10010201),},tSheet1_KeyIndex_mt),
    [10010202]=setmetatable({10010202,true,110041,T("商路巡查110041","CfgSeriesEventEvent_name",10010202),T("商路巡查","CfgSeriesEventEvent_title",10010202),T("城外商路的巡查，是保障斧头帮货运生意的重要一环。\n我会把巡查的地址发给你，别忘了带上家伙。要是半路遇到找茬的敌人，就顺手干掉他们。","CfgSeriesEventEvent_desc",10010202),},tSheet1_KeyIndex_mt),
    [10010301]=setmetatable({10010301,true,110042,T("岗哨执勤110042","CfgSeriesEventEvent_name",10010301),T("岗哨执勤","CfgSeriesEventEvent_title",10010301),T("最近一段时间，城里总有混混闹事，该轮到咱们出马了：\n背好你的枪，然后去站好一班岗，镇一镇那群爱挑事的家伙。","CfgSeriesEventEvent_desc",10010301),},tSheet1_KeyIndex_mt),
    [10010302]=setmetatable({10010302,true,110043,T("岗哨执勤110043","CfgSeriesEventEvent_name",10010302),T("岗哨执勤","CfgSeriesEventEvent_title",10010302),T("最近一段时间，城里总有混混闹事，该轮到咱们出马了：\n背好你的枪，然后去站好一班岗，镇一镇那群爱挑事的家伙。","CfgSeriesEventEvent_desc",10010302),},tSheet1_KeyIndex_mt),
    [10010401]=setmetatable({10010401,true,110044,T("物资派送110044","CfgSeriesEventEvent_name",10010401),T("物资派送","CfgSeriesEventEvent_title",10010401),T("珍珠城里有一些行动不便的百姓。为他们派送物资，也是斧头帮弟兄需要承担的职责。\n所以，赶快清点好这里的包裹，然后把它们送到百姓手上。","CfgSeriesEventEvent_desc",10010401),},tSheet1_KeyIndex_mt),
    [10010402]=setmetatable({10010402,true,110044,T("物资派送110044","CfgSeriesEventEvent_name",10010402),T("物资派送","CfgSeriesEventEvent_title",10010402),T("珍珠城里有一些行动不便的百姓。为他们派送物资，也是斧头帮弟兄需要承担的职责。\n所以，赶快清点好这里的包裹，然后把它们送到百姓手上。","CfgSeriesEventEvent_desc",10010402),},tSheet1_KeyIndex_mt),
    [10010403]=setmetatable({10010403,true,110044,T("物资派送110044","CfgSeriesEventEvent_name",10010403),T("物资派送","CfgSeriesEventEvent_title",10010403),T("珍珠城里有一些行动不便的百姓。为他们派送物资，也是斧头帮弟兄需要承担的职责。\n所以，赶快清点好这里的包裹，然后把它们送到百姓手上。","CfgSeriesEventEvent_desc",10010403),},tSheet1_KeyIndex_mt),
    [10010501]=setmetatable({10010501,true,110046,T("商路守卫110046","CfgSeriesEventEvent_name",10010501),T("违禁词1","CfgSeriesEventEvent_title",10010501),T("违禁词1商路恢复通行后，城外的匪徒又活跃起来了。总想着霸占我们的商道。\n\n好在我们查到了那伙人的据点。找到他们，再让他们滚出我们的地盘。","CfgSeriesEventEvent_desc",10010501),},tSheet1_KeyIndex_mt),
    [10010502]=setmetatable({10010502,true,110047,T("商路守卫110047","CfgSeriesEventEvent_name",10010502),T("商路守卫","CfgSeriesEventEvent_title",10010502),T("违商路恢复通行后，城外的匪徒又活跃起来了。总想着霸占我们的商道。\n\n好在我们查到了那伙人的据点。找到他们，再让他们滚出我们的地盘禁词1。","CfgSeriesEventEvent_desc",10010502),},tSheet1_KeyIndex_mt),
    --@endregion 【391】系列任务_CfgSeriesEvent.xlsx 事件
}

local tChineseFieldList={"name","title","desc"}
InitCfgMod.init("CfgSeriesEventEvent",tChineseFieldList)
