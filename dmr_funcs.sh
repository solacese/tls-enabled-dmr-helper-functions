# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
#
# Solace DMR External Link Initialization Scripting
#
# Uses SEMPv1 only (for now).
#
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -


# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
# Printout / logging functions
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

function premsg() { printf "$*"; }
function line()   { printf '=%.0s' {1..60}; }
function msg()    { echo ""; echo "$*"; echo `line`; }



# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
# SEMP v1 functions; to be replace when SEMPv2 does global config
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

# POST SEMPv1 xml data via HTTPS
function post() {
  if [ "$#" -ne 2 ]; then
    echo "	USAGE: post <host> <quoted-semp-text>"
    exit 0
  fi
  vmr=$1
  semp="$2"
  curl -X POST -k -u admin:admin https://$vmr:943/SEMP -d "$semp" 2>/dev/null | grep 'execute-result'
}



# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
# SEMP xml variable substitution; replaces various well-known tokens
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

function sub()        { sed "s/$1/$2/"; }
function lclclstrsub(){ sub __CLUSTER__ $1; }
function certsub()    { sub __CERT__ $1; }
function cnamesub()   { sub __CNAME__ $1; }
function linksub()    { sub __LINK__ $1; }
function addrsub()    { sub __ADDR__ $1; }
function chansub()    { sub __CHAN__ $1; }
function vpnsub()     { sub __VPN__ $1; }
function rmtvpnsub()  { sub __REMOTEVPN__ $1; }
function rmtclstrsub(){ sub __REMOTECLUSTER__ $1; }

# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
# XML request template retrieval functions: retrieves list of XML templates 
# for SEMPv1 queries based on the set of requests needed.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

# Return all cluster config templates in execution order
function clusterfiles() { ls -1 semp/*cluster*.xml; }

# Return all channel config templates in execution order
function chanfiles() { ls -1 semp/*chan*.xml; }

# Return all link config templates in execution order
# ARGS: exists = [true|false]; initiator = [local|remote]
function lnkfiles() {
  exists=$1
  initiator=$2
  linkfiles=`ls -1 semp\/*link*.xml`
  if [ "$exists" == "true" ]; then
    rmfile=(semp/10a_link_create.xml)
    linkfiles=( "${linkfiles[@]/$rmfile}" )
  fi
  if [ "local" == "$initiator" ] || [ "none" == "$initiator" ]; then
    rmfile=(semp/15b_link_notinitiator.xml)
    linkfiles=( "${linkfiles[@]/$rmfile}" )
  fi
  if [ "remote" == "$initiator" ] || [ "none" == "$initiator" ]; then
    rmfile=(semp/14_link_connectvia.xml)
    linkfiles=( "${linkfiles[@]/$rmfile}" )
    rmfile=(semp/15a_link_localinitiator.xml)
    linkfiles=( "${linkfiles[@]/$rmfile}" )
  fi
  echo "$linkfiles"
}



# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
# CREATE FUNCTIONS: 
#
#    create_cluster <host> <cluster> <cert>"
#    create_link <host> <local-cluster> <remote-cluster> <connect-via>"
#    create_channel <host> <local-msg-vpn> <remote-cluster> <remote-msg-vpn>"
#
# This creates a Cluster configured to use SSL and client certificate auth.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

function create_cluster() {
  if [ "$#" -ne 4 ]; then
    echo "  USAGE: create_cluster <host> <cluster> <cert> <cname>"
    echo ""
    exit 0
  fi
  vmr=$1
  lclclstr=$2
  cert=$3
  cname=$4

  msg "Creating cluster $lclclstr"
  echo $msg
  for xml in `clusterfiles`; do
    echo $xml
    semp=`cat $xml | lclclstrsub $lclclstr | certsub $cert`
    premsg "$xml:	"
    post $vmr "$semp"
  done
  msg "Modifying #ACTIVE link"
  for xml in `lnkfiles true none`; do
    semp=`cat $xml | lclclstrsub $lclclstr | linksub "#ACTIVE" | certsub $cert | cnamesub $cname`
    premsg "$xml:	"
    post $vmr "$semp"
  done
}

function create_link() {
  if [ "$#" -ne 5 ]; then
    echo "  USAGE: create_link <host> <local-cluster> <remote-cluster> <connect-via> <cname>"
    echo ""
    exit 0
  fi
  vmr=$1
  lclclstr=$2
  rmtclstr=$3
  addr=$4
  cname=$5

  if [ "$addr" == "none" ]; then
    initiator=remote
  else
    initiator=local
  fi

  msg "Creating $rmtclstr data link"
  for xml in `lnkfiles false $initiator`; do
    semp=`cat $xml | lclclstrsub $lclclstr | linksub $rmtclstr | addrsub $addr | cnamesub $cname`
    premsg "$xml:	"
    post $vmr "$semp"
  done
}

function create_channel() {
  if [ "$#" -ne 4 ]; then
    echo "  USAGE: create_channel <host> <local-msg-vpn> <remote-cluster> <remote-msg-vpn>"
    echo ""
    exit 0
  fi
  vmr=$1
  vpn=$2
  rmtclstr=$3
  rvpn=$4

  msg "Creating channel/DMR bridge for $lclclstr:$vpn=>$rmtclstr:$rvpn"
  for xml in `chanfiles`; do
    semp=`cat $xml | vpnsub $vpn | rmtclstrsub $rmtclstr | rmtvpnsub $rvpn`
    premsg "$xml:	"
    post $vmr "$semp"
  done
}

# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -
# DESTROY FUNCTIONS: 
#
#    delete_dmr_cluster <host> <local-cluster>
#    delete_dmr_bridge <host> <vpn> <remote-cluster>
#
# This destroys a Cluster configured to use SSL and client certificate auth.
# - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + - + -

function delete_dmr_cluster() {
  if [ "$#" -ne 2 ]; then
    echo "  USAGE: delete_dmr_cluster <host> <local-cluster>"
    echo ""
    exit 0
  fi
  vmr=$1
  cluster=$2

  xml=semp/destroy/shutdown_cluster.xml
  semp=`cat $xml | lclclstrsub $cluster`
  premsg "$xml:	"
  post $vmr "$semp"

  xml=semp/destroy/delete_cluster.xml
  semp=`cat $xml | lclclstrsub $cluster`
  premsg "$xml:	"
  post $vmr "$semp"
}

function delete_dmr_bridge() {
  if [ "$#" -ne 3 ]; then
    echo "  USAGE: delete_dmr_bridge <host> <vpn> <remote-cluster>"
    exit 0
  fi
  vmr=$1
  vpn=$2
  cluster="$3"
  xml=semp/destroy/delete_dmrbridge.xml

  semp=`cat $xml | rmtclstrsub $cluster | vpnsub $vpn`
  premsg "$xml: "
  post $vmr "$semp"
}
