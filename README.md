# PKI-Builder

A set of script to create a private CA, an intermediate CA, and use them to build client and server certificates

[!["You like it ?"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/sorriso)

## prerequisite:

- openssl installed

## How to make it working :

- run "1-build-PKI.sh" to create CA & intermediate CA

- create a sub folder in "server/" named with the DNS name or the IP

- run "2-build-server-cert.sh" to create server certificates

- run "3-build-server-dhparams.sh" to create server dh parameter

- create a sub folder in "client/" named with the machine name or the IP

- run "4-build-client-cert.sh" to create client certificates

The root certificate chain is stored in "/subCA/certs/rootCA.pem"
