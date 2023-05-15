local tTest1 = {}
function test1(tRole)
    tTest1.nRoleId = tRole.nRoleId
    tTest1.sRoleName = tRole.sRoleName
    tTest1.nLevel = tRole.nLevel
    tTest1.nSex =  tRole.nSex
    tTest1.nIndex = tRole.nIndex
    tTest1.tFeature = tRole.tFeature
    tTest1.vip_lv = tRole.vip_lv
    return tTest1
end

function test2(tRole)
    return {
        nRoleId = tRole.nRoleId,
        sRoleName = tRole.sRoleName,
        nLevel = tRole.nLevel,
        nSex =  tRole.nSex,
        nIndex = tRole.nIndex,
        tFeature = tRole.tFeature,
        vip_lv = tRole.vip_lv,
    }
end

function test3(tRole)
    local tTest3 = {}
    tTest3.nRoleId = tRole.nRoleId
    tTest3.sRoleName = tRole.sRoleName
    tTest3.nLevel = tRole.nLevel
    tTest3.nSex =  tRole.nSex
    tTest3.nIndex = tRole.nIndex
    tTest3.tFeature = tRole.tFeature
    tTest3.vip_lv = tRole.vip_lv
    print("===", tTest3)
    return tTest3
end

function main1()
    collectgarbage("stop")
    local tRole = {
        nRoleId = 1400100001,
        sRoleName = "test",
        nLevel = 30,
        nSex =  1,
        nIndex = 10,
        tFeature = {},
        vip_lv = 9,
    }
    local clock1 = os.clock()
    local mem1 = collectgarbage("count")

    for i=1,100000 do
        test1(tRole)
    end
    local clock2 = os.clock()
    local mem2 = collectgarbage("count")
    
    for i=1,100000 do
        test2(tRole)
    end
    local clock3 = os.clock()
    local mem3 = collectgarbage("count")

    for i=1,100000 do
        test3(tRole)
    end
    local clock4 = os.clock()
    local mem4 = collectgarbage("count")

    print("test1: ",clock2 - clock1, mem2 - mem1)
    print("test2: ",clock3 - clock2, mem3 - mem2)
    print("test3: ",clock4 - clock3, mem4 - mem3)

    collectgarbage("restart")
end

function main2()
    local tRole = {
        nRoleId = 1400100001,
        sRoleName = "test",
        nLevel = 30,
        nSex =  1,
        nIndex = 10,
        tFeature = {},
        vip_lv = 9,
    }
    local t1 = test3(tRole)
    local t2 = test3(tRole)
    print(t1, t2)
end

main2()