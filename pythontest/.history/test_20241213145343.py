import asyncio
import time

async def get_after(delay, what):
    await asyncio.sleep(delay)