#!/usr/bin/env zsh

echo ""
echo ""
echo "******* BEGIN BATCH CERT client *********************************************************************************************"

export localPath=$(pwd)
echo $localPath

cd client

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

    echo "******* Generate CSR for client certificate"

    cp $localPath/PKI/subCA/configuration/openssl-intermediate-CA2.cnf ./openssl-intermediate-CA2.cnf
    sed -i -e "s|_SAN|`echo $dir`|g" ./openssl-intermediate-CA2.cnf

    openssl req -new -nodes -keyout ./client.key \
        -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGA/OU=$STRAT/CN=$dir Client/emailAddress=$MAIL" \
        -config ./openssl-intermediate-CA2.cnf -extensions usr_cert \
        -batch \
        -out ./client.csr -days 3650

    echo "******* Create and Sign client certificate"

    INTERMEDIATECAPASSPHRASE=`cat $localPath/PKI/subCA/private/pwd`
    openssl ca -config ./openssl-intermediate-CA2.cnf \
        -extensions usr_cert -passin pass:$INTERMEDIATECAPASSPHRASE -batch \
        -out ./client.pem -infiles ./client.csr

    cp $localPath/PKI/subCA/certs/rootCA.pem .

    echo "******* Verify the Intermediate CA certificate against ROOT CA"
    openssl verify -CAfile ./rootCA.pem \
          ./client.pem

    rm -f *.cnf
    rm -f *.cnf-e
    rm -f *.csr

    cd ..

done

cd ..

echo "******* END BATCH CERT client *********************************************************************************************"
