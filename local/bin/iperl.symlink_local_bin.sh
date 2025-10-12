#!/bin/sh
echo 'Welcome to iPerl 🐫'
rlwrap -A -pblue -S"perl> " perl -wnE'say eval()//$@'
