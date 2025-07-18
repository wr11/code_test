import asyncio
import time

async def get_after(delay, what):
    await asyncio.sleep(delay)
    return what

async def main():
    print("start at {time.strftime('%X')}")