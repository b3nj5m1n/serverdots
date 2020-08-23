#!/bin/bash

# Generates ssl certificates suitable for use with android
echo "basicConstraints=CA:true" > "android_options.txt"


openssl genrsa -out priv_and_pub.key 2048
openssl req -new -days 3650 -key priv_and_pub.key -out CA.pem
openssl x509 -req -days 3650 -in CA.pem -signkey priv_and_pub.key -extfile ./android_options.txt -out CA.crt

echo "Import CA.der.crt in android"
openssl x509 -inform PEM -outform DER -in CA.crt -out CA.der.crt
