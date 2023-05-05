-- 线程池
local threadPool = {}

-- 线程池最大线程数
local maxThreadCount = 5

-- 等待队列
local waitingQueue = {}

-- 空闲线程数
local idleThreadCount = 0

-- 创建线程
local function createThread()
  return coroutine.create(function()
    while true do
      local task = table.remove(waitingQueue, 1)
      if task then
        coroutine.resume(task)
      else
        idleThreadCount = idleThreadCount + 1
        coroutine.yield()
      end
    end
  end)
end

-- 初始化线程池
function threadPool.init(maxCount)
  maxThreadCount = maxCount or maxThreadCount
  for i = 1, maxThreadCount do
    table.insert(threadPool, createThread())
  end
end

-- 添加任务到等待队列
function threadPool.addTask(task)
  if idleThreadCount > 0 then
    local thread = table.remove(threadPool, 1)
    coroutine.resume(thread, task)
    idleThreadCount = idleThreadCount - 1
  else
    table.insert(waitingQueue, task)
  end
end

threadPool.init(3)

-- 添加任务到线程池
threadPool.addTask(coroutine.create(function()
  print("Task 1")
end))

threadPool.addTask(coroutine.create(function()
  print("Task 2")
end))

threadPool.addTask(coroutine.create(function()
  print("Task 3")
end))

while true do
    for i = #threadPool, 1, -1 do
      local thread = threadPool[i]
      local status = coroutine.status(thread)
      if status == "dead" then
        table.remove(threadPool, i)
      elseif status == "suspended" then
        coroutine.resume(thread)
      end
    end
    if #threadPool == 0 and #waitingQueue == 0 then
      break
    end
  end