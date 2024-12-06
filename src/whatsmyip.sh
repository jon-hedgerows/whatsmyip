#!/bin/bash

VERSION=dev
PACKAGE=$(basename "$0")
DOMAIN=cloudflare.com  # this domain must be proxied by Cloudflare

# process command line arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo $PACKAGE "[ -a ] [ -i ] [ -l ]"
      echo $PACKAGE "[ -h ] [ -v ]"
      echo -a\|--all - show everything Cloudflare knows about you
      echo -i\|--ip\|--ipaddress - show your IP address
      echo -l\|--location - show your location
      echo -v\|--version - report the version, $PACKAGE $VERSION
      echo -h\|--help - show this help
      shift # past argument
      exit 0 # don't do anything else
      ;;
    -v|--V|--version)
      echo $PACKAGE $VERSION
      shift
      exit 0 # don't do anything else
      ;;
    -a|--all)
      ALL="1"
      shift # past argument
      ;;
    -i|--ip|--ipaddress|--ip-address)
      ADDRESS="1"
      shift
      ;;
    -l|--location)
      LOCATION="1"
      shift
      ;;
    -d|--domain)
      # undocumented feature: -d domain uses the cloudflare-proxied domain to look up the address.
      DOMAIN="$2"
      shift
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# return the ip address if nothing specified
if [ "$ALL$LOCATION" = "" ]; then
    ADDRESS="1"
fi

tmpfile=/tmp/$$.trace
curl --silent --url https://$DOMAIN/cdn-cgi/trace > $tmpfile

# this returns for example:
# fl=736f157
# h=cloudflare.com
# ip=192.0.2.247
# ts=1733512877.099
# visit_scheme=https
# uag=curl/7.81.0
# colo=LHR
# sliver=none
# http=http/2
# loc=GB
# tls=TLSv1.3
# sni=plaintext
# warp=off
# gateway=off
# rbi=off
# kex=X25519

if [ "$ALL" = "1" ]; then
    cat $tmpfile
else
    test "$ADDRESS" && cat $tmpfile | grep "^ip=" | cut -f2 -d=
    test "$LOCATION" && cat $tmpfile | grep "^loc=" | cut -f2 -d=
fi

rm -f $tmpfile
