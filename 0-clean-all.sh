#!/usr/bin/env zsh

cd PKI/CA

echo "******* Cleaning & creating data folder"
rm -f ./index.*
rm -f ./serial
rm -f ./serial.*
rm -f ./crlnumber
rm -f ./configuration/openssl-CA.cnf
rm -f ./configuration/openssl-CA.cnf-e
rm -rf ./certs ./crl ./newcerts ./private ./csr

cd ..
cd subCA

echo "******* Cleaning & creating data folder"
rm -f ./index.*
rm -f ./serial
rm -f ./serial.*
rm -f ./crlnumber
rm -f ./configuration/openssl-intermediate-CA.cnf
rm -f ./configuration/openssl-intermediate-CA.cnf-e
rm -f ./configuration/openssl-intermediate-CA2.cnf
rm -f ./configuration/openssl-intermediate-CA2.cnf-e
rm -rf ./certs ./crl ./newcerts ./private ./csr

cd ../..

echo "******* Cleaning server"
cd server
for dir in */; do
    cd $dir
    rm -rf *.*
    cd ..
done
cd ..

echo "******* Cleaning client"
cd client
for dir in */; do
    cd $dir
    rm -rf *.*
    cd ..
done

cd ..
