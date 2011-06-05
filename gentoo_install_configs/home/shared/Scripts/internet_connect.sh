#!/bin/bash
sudo su
spwan ssh -D 8080 samchambers@97.86.15.78 -p 443

match_max 100000

expect "*?assword:*"

send -- "\r"
send -- "\r"
expect eof
