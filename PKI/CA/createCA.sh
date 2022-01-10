#!/usr/bin/env zsh

echo "******* BEGIN CA *********************************************************************************************"
# from https://jamielinux.com/docs/openssl-certificate-authority/create-the-intermediate-pair.html
# http://www.g-loaded.eu/2005/11/10/be-your-own-ca/
echo "Creating CA"
echo "*********************************************************************************************"

if [ "$1" = "" ]; then
    echo "******* CA password cannot be empty, please provide it through parameter"
    exit 1
fi

export CAPASSPHRASE=$1
export COUNTRY="FR"
export STATE="FR"
export LOCALITY="France"
export ORGA="iWorldCompany DEV"
export COMMON="iWorldCompany DEV ROOT CA"

echo "******* Cleaning & creating data folder"
rm ./index.*
rm ./serial
rm ./serial.*
rm ./crlnumber
rm ./configuration/openssl-CA.cnf
rm ./configuration/openssl-CA.cnf-e
rm -rf ./certs ./crl ./newcerts ./private
mkdir ./certs ./crl ./newcerts ./private
echo $CAPASSPHRASE > ./private/pwd
chmod 700 private
touch ./index.txt
touch ./crlnumber
echo 1000 > serial

echo "******* Generating CA ROOT private key"
openssl genrsa -aes256 \
  -passout pass:$CAPASSPHRASE \
  -out ./private/ca.key.pem 4096
chmod 400 ./private/ca.key.pem

echo "******* Generating CA ROOT configuration file"
cp ./configuration/openssl-CA.cnf.template ./configuration/openssl-CA.cnf
sed -i -e "s|_SCRIPTPATH|`pwd`|g" ./configuration/openssl-CA.cnf

echo "******* Generating CA ROOT certificate"
openssl req -passin pass:$CAPASSPHRASE \
  -config ./configuration/openssl-CA.cnf \
  -new -x509 -days 7300 \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGA/CN=$COMMON" \
  -key ./private/ca.key.pem -sha256 -extensions v3_ca \
  -out ./certs/ca.cert.pem

chmod 444 ./certs/ca.cert.pem

echo "******* Verify the CA ROOT certificate"
openssl x509 -noout -text -in ./certs/ca.cert.pem

echo "******* END CA *********************************************************************************************"
