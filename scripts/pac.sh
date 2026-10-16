#!/bin/sh

# ANSI Color -- use these variables to easily have different color
#    and format output. Make sure to output the reset sequence after 
#    colors (f = foreground, b = background), and use the 'off'
#    feature for anything you turn on.

initializeANSI()
{
 esc=""

  blackf="${esc}[30m";   redf="${esc}[31m";    greenf="${esc}[32m"
  yellowf="${esc}[33m"   bluef="${esc}[34m";   purplef="${esc}[35m"
  cyanf="${esc}[36m";    whitef="${esc}[37m"
  
  blackb="${esc}[40m";   redb="${esc}[41m";    greenb="${esc}[42m"
  yellowb="${esc}[43m"   blueb="${esc}[44m";   purpleb="${esc}[45m"
  cyanb="${esc}[46m";    whiteb="${esc}[47m"

  brblackf="${esc}[90m"; brredf="${esc}[91m";  brgreenf="${esc}[92m"
  bryellowf="${esc}[93m" brbluef="${esc}[94m"; brpurplef="${esc}[95m"
  brcyanf="${esc}[96m";  brwhitef="${esc}[97m"

  boldon="${esc}[1m";    boldoff="${esc}[22m"
  italicson="${esc}[3m"; italicsoff="${esc}[23m"
  ulon="${esc}[4m";      uloff="${esc}[24m"
  invon="${esc}[7m";     invoff="${esc}[27m"

  reset="${esc}[0m"
}

# note in this first use that switching colors doesn't require a reset
# first - the new color overrides the old one.

clear 

initializeANSI

cat << EOF

 ${yellowf}  ▄███████▄${reset}   ${redf}  ▄██████▄${reset}    ${greenf}  ▄██████▄${reset}    ${bluef}  ▄██████▄${reset}    ${purplef}  ▄██████▄${reset}    ${cyanf}  ▄██████▄${reset}
 ${yellowf}▄█████████▀▀${reset}  ${redf}▄${whitef}█▀█${redf}██${whitef}█▀█${redf}██▄${reset}  ${greenf}▄${whitef}█▀█${greenf}██${whitef}█▀█${greenf}██▄${reset}  ${bluef}▄${whitef}█▀█${bluef}██${whitef}█▀█${bluef}██▄${reset}  ${purplef}▄${whitef}█▀█${purplef}██${whitef}█▀█${purplef}██▄${reset}  ${cyanf}▄${whitef}█▀█${cyanf}██${whitef}█▀█${cyanf}██▄${reset}
 ${yellowf}███████▀${reset}      ${redf}█${whitef}▄▄█${redf}██${whitef}▄▄█${redf}███${reset}  ${greenf}█${whitef}▄▄█${greenf}██${whitef}▄▄█${greenf}███${reset}  ${bluef}█${whitef}▄▄█${bluef}██${whitef}▄▄█${bluef}███${reset}  ${purplef}█${whitef}▄▄█${purplef}██${whitef}▄▄█${purplef}███${reset}  ${cyanf}█${whitef}▄▄█${cyanf}██${whitef}▄▄█${cyanf}███${reset}
 ${yellowf}███████▄${reset}      ${redf}████████████${reset}  ${greenf}████████████${reset}  ${bluef}████████████${reset}  ${purplef}████████████${reset}  ${cyanf}████████████${reset}
 ${yellowf}▀█████████▄▄${reset}  ${redf}██▀██▀▀██▀██${reset}  ${greenf}██▀██▀▀██▀██${reset}  ${bluef}██▀██▀▀██▀██${reset}  ${purplef}██▀██▀▀██▀██${reset}  ${cyanf}██▀██▀▀██▀██${reset}
 ${yellowf}  ▀███████▀${reset}   ${redf}▀   ▀  ▀   ▀${reset}  ${greenf}▀   ▀  ▀   ▀${reset}  ${bluef}▀   ▀  ▀   ▀${reset}  ${purplef}▀   ▀  ▀   ▀${reset}  ${cyanf}▀   ▀  ▀   ▀${reset}
 
 ${boldon}${bryellowf}  ▄███████▄   ${brredf}  ▄██████▄    ${brgreenf}  ▄██████▄    ${brbluef}  ▄██████▄    ${brpurplef}  ▄██████▄    ${brcyanf}  ▄██████▄${reset}
 ${boldon}${bryellowf}▄█████████▀▀  ${brredf}▄${brwhitef}█▀█${brredf}██${brwhitef}█▀█${brredf}██▄  ${brgreenf}▄${brwhitef}█▀█${brgreenf}██${brwhitef}█▀█${brgreenf}██▄  ${brbluef}▄${brwhitef}█▀█${brbluef}██${brwhitef}█▀█${brbluef}██▄  ${brpurplef}▄${brwhitef}█▀█${brpurplef}██${brwhitef}█▀█${brpurplef}██▄  ${brcyanf}▄${brwhitef}█▀█${brcyanf}██${brwhitef}█▀█${brcyanf}██▄${reset}
 ${boldon}${bryellowf}███████▀      ${brredf}█${brwhitef}▄▄█${brredf}██${brwhitef}▄▄█${brredf}███  ${brgreenf}█${brwhitef}▄▄█${brgreenf}██${brwhitef}▄▄█${brgreenf}███  ${brbluef}█${brwhitef}▄▄█${brbluef}██${brwhitef}▄▄█${brbluef}███  ${brpurplef}█${brwhitef}▄▄█${brpurplef}██${brwhitef}▄▄█${brpurplef}███  ${brcyanf}█${brwhitef}▄▄█${brcyanf}██${brwhitef}▄▄█${brcyanf}███${reset}
 ${boldon}${bryellowf}███████▄      ${brredf}████████████  ${brgreenf}████████████  ${brbluef}████████████  ${brpurplef}████████████  ${brcyanf}████████████${reset}
 ${boldon}${bryellowf}▀█████████▄▄  ${brredf}██▀██▀▀██▀██  ${brgreenf}██▀██▀▀██▀██  ${brbluef}██▀██▀▀██▀██  ${brpurplef}██▀██▀▀██▀██  ${brcyanf}██▀██▀▀██▀██${reset}
 ${boldon}${bryellowf}  ▀███████▀   ${brredf}▀   ▀  ▀   ▀  ${brgreenf}▀   ▀  ▀   ▀  ${brbluef}▀   ▀  ▀   ▀  ${brpurplef}▀   ▀  ▀   ▀  ${brcyanf}▀   ▀  ▀   ▀${reset}
