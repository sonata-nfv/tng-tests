import time
import subprocess
import resource
import sys
import os
from psutil import Process


def main(command, *args, **kwargs):
    FNULL = open(os.devnull, 'w')
    memory_usages = 0
    t = time.time()
    p = subprocess.Popen(command, *args, **kwargs)
    _p = Process(p.pid)
    while p.poll() is None:
        memory_usages = (_p.memory_info().rss
                         if _p.memory_info().rss > memory_usages
                         else memory_usages)
    process_time = time.time() - t
    memory_usage = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
    return str(process_time), str(memory_usage), str(memory_usages)


ret = " ".join(main(sys.argv[1:]))

with open("sub_proc_return", "w") as f:
    f.write(ret)
