import onlinereload.reloader as reloader
reloader.enable()

import hotfix
def run():
	hotfix.Init()

import onlinereload.monitor as monitor

if __name__ == "__main__":
    monitor.Init()
    run()