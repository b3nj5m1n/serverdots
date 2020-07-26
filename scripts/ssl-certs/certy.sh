#!/bin/bash

# Generates a self signed certificate
# First argument should be the directory to save to
# Second argument should be the domain to sign for

directory="$1"
domain="$2"
caKey="$3"

openssl req -x509 -out "$directory/$domain.crt" -keyout "$directory/$domain.key" \
    -key "$caKey" \
    -subj "/CN=$domain" -extensions EXT -config <( \
    printf "[dn]\nCN=$domain\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$domain\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
  # -newkey rsa:2048 -nodes -sha256 \
