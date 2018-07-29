#!/bin/bash
printf "\nCREATING CONFIGURATION..\n"
echo -e "\nconfig.endpoints.core = '${ENDPOINT_CORE}';" >> /tmp/apitax/build/config.js

printf "\nAPP CONFIGURATION:\n\n"
cat /tmp/apitax/build/config.js

printf "\nBUILDING APP..\n"
npm run --prefix /tmp/apitax/build build
cp -r /tmp/apitax/build/dist /usr/share/nginx/html/dist
rm -rf /tmp/apitax

printf "\nBUILD COMPLETE. LAUNCHED.\n"

nginx -g "daemon off;"
