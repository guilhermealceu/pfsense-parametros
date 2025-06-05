#!/bin/sh
grep -E 'login|sshd' /var/log/system.log | tail -n 1
