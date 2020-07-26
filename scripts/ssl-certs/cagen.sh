#!/bin/bash

# Generates a private key

openssl genrsa -des3 -out "$1" 2048
