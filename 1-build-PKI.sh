#!/usr/bin/env zsh

export pwdCA="$(openssl rand -base64 32)"

export pwdCAint="$(openssl rand -base64 32)"

cd PKI/CA
./createCA.sh $pwdCA

cd ..

cd subCA
./createIntermediateCA.sh $pwdCAint

CD ../..
