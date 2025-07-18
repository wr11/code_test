import asyncio
import time

async def get_after(delay, what):
    await asyncio.sleep(delay)
    return what

async def main():
    print(f"start at {time.strftime('%X')}")
    
	task1 = asyncio.create_task(get_after(1, "task1"))
	task2 = asyncio.create_task(get_after(1, "task2"))
    
	t2 = await task2