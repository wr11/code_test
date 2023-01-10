import os
import queue
import onlinereload.reloader as reloader
import sys
import threading
import time

_win32 = (sys.platform == 'win32')


def _normalize_filename(filename):
    if filename is not None:
        if filename.endswith('.pyc') or filename.endswith('.pyo'):
            filename = filename[:-1]
        elif filename.endswith('$py.class'):
            filename = filename[:-9] + '.py'
    return filename

class Reloader(object):

    def __init__(self, interval=1):
        self.monitor = ModuleMonitor(interval=interval)
        self.monitor.start()

    def poll(self):
        modulenames = set()
        while not self.monitor.queue.empty():
            try:
                modulenames.add(self.monitor.queue.get_nowait())
            except queue.Empty:
                break
        if modulenames:
            self._reload(modulenames)

    def _reload(self, modulenames):
        for name in modulenames:
            mod = sys.modules.get(name, None)
            if not mod:
                continue
            reloader.reload(mod)

class ModuleMonitor(threading.Thread):
    """Monitor module source file changes"""

    def __init__(self, interval=1):
        threading.Thread.__init__(self)
        self.daemon = True
        self.mtimes = {}
        self.queue = queue.Queue()
        self.interval = interval

    def run(self):
        while True:
            self._scan()
            time.sleep(self.interval)

    def _scan(self):
        moduledict = dict(sys.modules)
        for modulename, module in moduledict.items():
            # We're only interested in file-based modules (not C extensions).
            filename = getattr(module, '__file__', None)
            if not filename:
                continue
            # We're only interested in the source .py files.
            filename = _normalize_filename(filename)

            # stat() the file.  This might fail if the module is part of a
            # bundle (.egg).  We simply skip those modules because they're
            # not really reloadable anyway.
            try:
                stat = os.stat(filename)
            except OSError:
                continue

            # Check the modification time.  We need to adjust on Windows.
            mtime = stat.st_mtime
            if _win32:
                mtime -= stat.st_ctime

            # Check if we've seen this file before.  We don't need to do
            # anything for new files.
            bChange = False
            if modulename in self.mtimes:
                # If this file's mtime has changed, queue it for reload.
                if mtime != self.mtimes[modulename]:
                    self.queue.put(modulename)
                    bChange = True

            # Record this filename's current mtime.
            self.mtimes[modulename] = mtime

            if bChange:
                g_Reloader.poll()

if "g_Reloader" not in globals():
    g_Reloader = None

def Init():
    global g_Reloader
    g_Reloader = Reloader(1)