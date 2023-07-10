#!/usr/bin/env python3

import os
import subprocess
import time


DISCOVERY_FILE = "/vagrant/.kubedeploy/pending-worker-nodes.csv"

if __name__ == '__main__':
    ip_addresses = ""

    print("Waiting for discovery file...")
    while(not os.path.isfile(DISCOVERY_FILE)):
        time.sleep(5)

    while(os.path.isfile(DISCOVERY_FILE)):
        print("Reading discovery file...")
        try:
            file = open(DISCOVERY_FILE, "r")
            ip_addresses = file.read().split(",")
            file.close()
        except:
            print("Could not open file: {}.".format(DISCOVERY_FILE))
            print("Aborting worker node discovery.")
            exit(0)

        failed = []

        print("Pinging worker nodes...")
        for ip in ip_addresses:
            if ip == "":
                continue

            res = 1
            tries = 0

            while res != 0 and tries < 5:
                tries += 1
                cmd = subprocess.Popen(["ping", ip, "-c", "4"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                streamdata = cmd.communicate()[0]
                res = cmd.returncode
            
            if res == 0:
                print("Successfully pinged {}".format(ip))
            else:
                print("Failed to ping {}".format(ip))
                failed.append(ip)

        time.sleep(5)
