# whatsmyip

This script determines the current external IP address.

usage:  
`whatsmyip [options]`

This initiates a trace with Cloudflare, and uses the data returned to determine the external IP address in use. If multiple external IPs are available then this script cannot determine all of these, and may give inconsistent results.
