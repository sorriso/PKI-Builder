#!/usr/bin/env zsh

echo "******* BEGIN SubCA *********************************************************************************************"
# from https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
echo "Creating Intermediate CA"
echo "*********************************************************************************************"

if [ "$1" = "" ]; then
    echo "******* INTERMEDIATE CA password cannot be empty, please provide it through parameter"
    exit 1
fi

export INTERMEDIATECAPASSPHRASE=$1
export CAPASSPHRASE=""
export COUNTRY="FR"
export STATE="FR"
export LOCALITY="France"
export ORGA="iWorldCompany DEV"
export COMMON="iWorldCompany DEV intermediate CA"

echo "******* Cleaning & creating data folder"
rm ./index.*
rm ./serial
rm ./serial
rm ./crlnumber
rm ./configuration/*.cnf
rm ./configuration/*.cnf-e
rm -rf ./certs ./crl ./csr ./newcerts ./private
mkdir  ./certs ./crl ./csr ./newcerts ./private
echo $INTERMEDIATECAPASSPHRASE > ./private/pwd
chmod 700 ./private
touch ./index.txt
touch ./crlnumber
echo 1000 > serial

echo "******* Generating Intermediate CA private key"
# First generate CA private and public keys:
openssl genrsa -aes256 \
      -passout pass:$INTERMEDIATECAPASSPHRASE \
      -out ./private/ca.intermediate.key.pem 4096
chmod 400 ./private/ca.intermediate.key.pem

echo "******* Generating Intermediate CA configuration file"
cp ./configuration/openssl-intermediate-CA.cnf.template ./configuration/openssl-intermediate-CA.cnf
sed -i -e "s|_SCRIPTPATH|`pwd`|g" ./configuration/openssl-intermediate-CA.cnf
cp ./configuration/openssl-intermediate-CA2.cnf.template ./configuration/openssl-intermediate-CA2.cnf
sed -i -e "s|_SCRIPTPATH|`pwd`|g" ./configuration/openssl-intermediate-CA2.cnf

echo "******* Generating Intermediate CA certificate CSR"
openssl req -passin pass:$INTERMEDIATECAPASSPHRASE \
      -config ./configuration/openssl-intermediate-CA.cnf -new -sha256 \
      -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGA/CN=$COMMON" \
      -key ./private/ca.intermediate.key.pem \
      -out ./csr/intermediate.csr.pem

echo "******* Generating Intermediate CA certificate"
CAPASSPHRASE=`cat ../CA/private/pwd`
openssl ca -config ../CA/configuration/openssl-CA.cnf -extensions v3_intermediate_ca \
      -passin pass:$CAPASSPHRASE -batch  \
      -days 3650 -notext -md sha256 \
      -in ./csr/intermediate.csr.pem \
      -out ./certs/intermediate-CA.cert.pem
chmod 444 ./certs/intermediate-CA.cert.pem

echo "******* Verify the Intermediate CA certificate details"
openssl x509 -noout -text \
      -in ./certs/intermediate-CA.cert.pem

echo "******* Verify the Intermediate CA certificate against ROOT CA"
openssl verify -CAfile ../CA/certs/ca.cert.pem \
      ./certs/intermediate-CA.cert.pem

echo "******* Create the certificate chain file"
cat ./certs/intermediate-CA.cert.pem \
      ../CA/certs/ca.cert.pem > ./certs/rootCA.pem
chmod 444 ./certs/rootCA.pem

echo "******* END SubCA *********************************************************************************************"
