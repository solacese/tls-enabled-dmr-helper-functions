#!/bin/bash
cd `dirname $0`
. dmr_funcs.sh


if [ "$1" == "create" ]; then
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 1:  CREATE CLUSTER ON BLUE AWS NODE  
  # USAGE:   create_cluster <host> <cluster> <cert> <cname>
  # EXAMPLE: create_cluster ec2-0-0-0-0.compute-1.amazonaws.com pubSubStandardSingleNode-AWS-BLUE.pem pubSubStandardSingleNode-AWS-BLUE
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 2:  CREATE A LINK BETWEEN BLUE AWS CLUSTER AND RED AWS CLUSTER 
  # USAGE:   create_link <host> <local-cluster> <remote-cluster> <connect-via> <cname>
  # EXAMPLE: create_link ec2-0-0-0-0.compute-1.amazonaws.com aws-blue aws-red none pubSubStandardSingleNode-AWS-RED
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

 # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 3:  CREATE CHANNEL BETWEEN DEFAULT MSG-VPN OF BLUE AWS CLUSTER AND DEFAULT MSG-VPN OF RED AWS CLUSTER 
  # USAGE:   create_channel <host> <local-msg-vpn> <remote-cluster> <remote-msg-vpn>
  # EXAMPLE: create_channel  ec2-0-0-0-0.compute-1.amazonaws.com default aws-red default
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

elif [ "$1" == "destroy" ]; then
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 1:  DESTROY CLUSTER ON BLUE AWS NODE  
  # USAGE:   delete_dmr_cluster <host> <local-cluster>
  # EXAMPLE: delete_dmr_cluster ec2-0-0-0-0.compute-1.amazonaws.com aws-blue
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 2:  DESTROY DMR BRIDGE BETWEEN DEFAULT MSG-VPN OF BLUE AWS CLUSTER AND RED AWS CLUSTER
  # USAGE:   delete_dmr_bridge <host> <vpn> <remote-cluster>
  # EXAMPLE: delete_dmr_bridge ec2-0-0-0-0.compute-1.amazonaws.com default aws-red
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

else
  echo ""
  echo "	USAGE: $0 <create | destroy>"
  echo ""
  exit 0

fi
