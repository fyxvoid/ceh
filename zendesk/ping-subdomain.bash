#!/bin/bash

for subdomain in $(cat subdomain.txt); do
	ping -c 1 $subdomain
done
