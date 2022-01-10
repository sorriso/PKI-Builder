#!/usr/bin/env zsh

echo ""
echo ""
echo "******* BEGIN BATCH CERT SERVER *********************************************************************************************"

export localPath=$(pwd)
echo $localPath

cd server

for dir in */; do

    dir=${dir%*/}

    echo "******* Batch for : $dir"

    export dirName=$dir
    export ipName=$2

    export COUNTRY="FR"
    export STATE="FR"
    export LOCALITY="France"
    export ORGA="iWorldCompany DEV"
    export STRAT="Certificate"
    export MAIL="support@iWorldCompany.com"

    cd $dir
    rm -rf *.*

    echo "******* Generate CSR for server certificate"

    cp $localPath/PKI/subCA/configuration/openssl-intermediate-CA2.cnf ./openssl-intermediate-CA2.cnf
    sed -i -e "s|_SAN|`echo $dir`|g" ./openssl-intermediate-CA2.cnf

    openssl req -new -nodes -keyout ./server.key \
        -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGA/OU=$STRAT/CN=$dir Client/emailAddress=$MAIL" \
        -config ./openssl-intermediate-CA2.cnf -extensions server_cert \
        -batch \
        -out ./server.csr -days 3650

    echo "******* Create and Sign server certificate"

    INTERMEDIATECAPASSPHRASE=`cat $localPath/PKI/subCA/private/pwd`
    openssl ca -config ./openssl-intermediate-CA2.cnf \
        -extensions usr_cert -passin pass:$INTERMEDIATECAPASSPHRASE -batch \
        -out ./server.pem -infiles ./server.csr

    cp $localPath/PKI/subCA/certs/rootCA.pem .

    echo "******* Verify the Intermediate CA certificate against ROOT CA"
    openssl verify -CAfile ./rootCA.pem \
          ./server.pem

    rm -f *.cnf
    rm -f *.cnf-e
    rm -f *.csr

    cd ..

done

cd ..

echo "******* END BATCH CERT SERVER *********************************************************************************************"
