## A lightweight and fast ECDSA implementation

### Overview

This is a Ruby fork of [ecdsa-python].

It is compatible with OpenSSL.
It preserves the [ecdsa-python] interface and wraps the builtin openSSl Ruby module.

### Speed

We ran a test on Ruby 2.6.3 on a MAC Pro i5 2019. The libraries ran 100 times and showed the average times displayed bellow:

| Library            | sign          | verify  |
| ------------------ |:-------------:| -------:|
| starkbank-ecdsa    |     1.0ms     | 1.0ms  |


### Sample Code

How to sign a json message for [Stark Bank]:

```ruby
require("ecdsa_ruby")

# Generate privateKey from PEM string
privateKey = EcdsaRuby::PrivateKey.fromPem("-----BEGIN EC PARAMETERS-----\nBgUrgQQACg==\n-----END EC PARAMETERS-----\n-----BEGIN EC PRIVATE KEY-----\nMHQCAQEEIODvZuS34wFbt0X53+P5EnSj6tMjfVK01dD1dgDH02RzoAcGBSuBBAAK\noUQDQgAE/nvHu/SQQaos9TUljQsUuKI15Zr5SabPrbwtbfT/408rkVVzq8vAisbB\nRmpeRREXj5aog/Mq8RrdYy75W9q/Ig==\n-----END EC PRIVATE KEY-----\n")

# Create message from json
message = JSON.stringify({
    "transfers": [
        {
            "amount": 100000000,
            "taxId": "594.739.480-42",
            "name": "Daenerys Targaryen Stormborn",
            "bankCode": "341",
            "branchCode": "2201",
            "accountNumber": "76543-8",
            "tags": ["daenerys", "targaryen", "transfer-1-external-id"]
        }
    ]
})

signature = EcdsaRuby::Ecdsa.sign(message, privateKey)

# Generate Signature in base64. This result can be sent to Stark Bank in header as Digital-Signature parameter
puts signature.toBase64()

# To double check if message matches the signature
publicKey = privateKey.publicKey()

puts EcdsaRuby::Ecdsa.verify(message, signature, publicKey)
```

Simple use:

```ruby
require("ecdsa_ruby")

# Generate new Keys
privateKey = EcdsaRuby::PrivateKey.new()
publicKey = privateKey.publicKey()

message = "My test message"

# Generate Signature
signature = EcdsaRuby::Ecdsa.sign(message, privateKey)

# Verify if signature is valid
puts EcdsaRuby::Ecdsa.verify(message, signature, publicKey)
```

### OpenSSL

This library is compatible with OpenSSL, so you can use it to generate keys:

```
openssl ecparam -name secp256k1 -genkey -out privateKey.pem
openssl ec -in privateKey.pem -pubout -out publicKey.pem
```

Create a message.txt file and sign it:

```
openssl dgst -sha256 -sign privateKey.pem -out signatureDer.txt message.txt
```

It's time to verify:

```ruby
require("ecdsa_ruby")

publicKeyPem = EcdsaRuby::Utils::File.read("publicKey.pem")
signatureDer = EcdsaRuby::Utils::File.read("signatureDer.txt", "binary")
message = EcdsaRuby::Utils::File.read("message.txt")

publicKey = PublicKey.fromPem(publicKeyPem)
signature = Signature.fromDer(signatureDer)

puts Ecdsa.verify(message, signature, publicKey)
```

You can also verify it on terminal:

```
openssl dgst -sha256 -verify publicKey.pem -signature signatureDer.txt message.txt
```

NOTE: If you want to create a Digital Signature to use in the [Stark Bank], you need to convert the binary signature to base64.

```
openssl base64 -in signatureDer.txt -out signatureBase64.txt
```

With this library, you can do it:

```ruby
ellipticcurve = require("@starkbank/ecdsa-node")
Signature = ellipticcurve.Signature
File = ellipticcurve.utils.File

signatureDer = EcdsaRuby::Utils::File.read("signatureDer.txt", "binary")

signature = EcdsaRuby::Signature.fromDer(signatureDer)

puts signature.toBase64()
```

[Stark Bank]: https:#starkbank.com

### How to install

```
gem install ecdsa_ruby
```

### Run all unit tests
Run tests script

```
ruby test/test.rb
```

[ecdsa-python]: https:#github.com/starkbank/ecdsa-python