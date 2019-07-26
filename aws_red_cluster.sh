#!/bin/bash
cd `dirname $0`
. dmr_funcs.sh

if [ "$1" == "create" ]; then
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 1:  CREATE CLUSTER ON RED AWS NODE  
  # USAGE:   create_cluster <host> <cluster> <cert> <cname>
  # EXAMPLE: create_cluster ec2-1-1-1-1.compute-1.amazonaws.com pubSubStandardSingleNode-AWS-RED.pem pubSubStandardSingleNode-AWS-RED
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 2:  CREATE A LINK BETWEEN RED AWS CLUSTER AND BLUE AWS CLUSTER 
  # USAGE:   create_link <host> <local-cluster> <remote-cluster> <connect-via> <cname>
  # EXAMPLE: create_link ec2-1-1-1-1.compute-1.amazonaws.com aws-red aws-blue none pubSubStandardSingleNode-AWS-BLUE
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 3:  CREATE CHANNEL BETWEEN DEFAULT MSG-VPN OF RED AWS CLUSTER AND DEFAULT MSG-VPN OF BLUE AWS CLUSTER 
  # USAGE:   create_channel <host> <local-msg-vpn> <remote-cluster> <remote-msg-vpn>
  # EXAMPLE: create_channel  ec2-1-1-1-1.compute-1.amazonaws.com default aws-blue default
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

elif [ "$1" == "destroy" ]; then
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 1:  DESTROY CLUSTER ON RED AWS NODE  
  # USAGE:   delete_dmr_cluster <host> <local-cluster>
  # EXAMPLE: delete_dmr_cluster ec2-1-1-1-1.compute-1.amazonaws.com aws-red
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
  # STEP 2:  DESTROY DMR BRIDGE BETWEEN DEFAULT MSG-VPN OF RED AWS CLUSTER AND BLUE CLUSTER
  # USAGE:   delete_dmr_bridge <host> <vpn> <remote-cluster>
  # EXAMPLE: delete_dmr_bridge ec2-1-1-1-1.compute-1.amazonaws.com default aws-blue
  # - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

else
  echo ""
  echo "	USAGE: $0 <create | destroy>"
  echo ""
  exit 0

fi
