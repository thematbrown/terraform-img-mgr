#!/bin/sh
yum install httpd
systemctl start httpd.service
systemctl enable httpd.service