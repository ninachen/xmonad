#!/bin/bash
str=`amixer sget Master`
str1=${str#Simple*\[}
echo ${str1%%]*]}
