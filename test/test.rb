require 'starkbank-ecdsa'

$success = 0
$failure = 0

def assertEqual(a, b) 
    if a != b
        $failure += 1
        puts "      FAIL: #{a} != #{b}"
    else
        $success += 1
        puts "      success"
    end
end

def header(text)
    puts "\n  #{text} test:"
end

def subHeader(text)
    puts "    #{text}:"
end


puts "\n\nRunning ECDSA-Ruby tests:"

header("ECDSA")

subHeader("testVerifyRightMessage")
privateKey = EllipticCurve::PrivateKey.new()
publicKey = privateKey.publicKey()
message = "This is the right message"
signature = EllipticCurve::Ecdsa.sign(message, privateKey)
assertEqual(EllipticCurve::Ecdsa.verify(message, signature, publicKey), true)

subHeader("testVerifyWrongMessage")
privateKey = EllipticCurve::PrivateKey.new()
publicKey = privateKey.publicKey()
message1 = "This is the right message"
message2 = "This is the wrong message"
signature = EllipticCurve::Ecdsa.sign(message1, privateKey)
assertEqual(EllipticCurve::Ecdsa.verify(message2, signature, publicKey), false)


header("openSSL")

subHeader("testAssign")
# Generated by: openssl ecparam -name secp256k1 -genkey -out privateKey.pem
privateKeyPem = EllipticCurve::Utils::File.read("test/privateKey.pem")
privateKey = EllipticCurve::PrivateKey.fromPem(privateKeyPem)
message = EllipticCurve::Utils::File.read("test/message.txt")
signature = EllipticCurve::Ecdsa.sign(message, privateKey)
publicKey = privateKey.publicKey()
assertEqual(EllipticCurve::Ecdsa.verify(message, signature, publicKey), true)

subHeader("testVerifySignature")
# openssl ec -in privateKey.pem -pubout -out publicKey.pem
publicKeyPem = EllipticCurve::Utils::File.read("test/publicKey.pem")
# openssl dgst -sha256 -sign privateKey.pem -out signature.binary message.txt
signatureDer = EllipticCurve::Utils::File.read("test/signatureDer.txt", "binary")
message = EllipticCurve::Utils::File.read("test/message.txt")
publicKey = EllipticCurve::PublicKey.fromPem(publicKeyPem)
signature = EllipticCurve::Signature.fromDer(signatureDer)
assertEqual(EllipticCurve::Ecdsa.verify(message, signature, publicKey), true)


header("PrivateKey")

subHeader("testPemConversion")
privateKey1 = EllipticCurve::PrivateKey.new()
pem = privateKey1.toPem()
privateKey2 = EllipticCurve::PrivateKey.fromPem(pem)
assertEqual(privateKey1.toPem, privateKey2.toPem)

subHeader("testDerConversion")
privateKey1 = EllipticCurve::PrivateKey.new()
der = privateKey1.toDer()
privateKey2 = EllipticCurve::PrivateKey.fromDer(der)
assertEqual(privateKey1.toPem, privateKey2.toPem)

subHeader("testStringConversion")
privateKey1 = EllipticCurve::PrivateKey.new()
string = privateKey1.toString()
privateKey2 = EllipticCurve::PrivateKey.fromString(string)
assertEqual(privateKey1.toPem, privateKey2.toPem)


header("PublicKey")

subHeader("testPemConversion")
privateKey = EllipticCurve::PrivateKey.new()
publicKey1 = privateKey.publicKey()
pem = publicKey1.toPem()
publicKey2 = EllipticCurve::PublicKey.fromPem(pem)
assertEqual(publicKey1.toPem, publicKey2.toPem)

subHeader("testDerConversion")
privateKey = EllipticCurve::PrivateKey.new()
publicKey1 = privateKey.publicKey()
der = publicKey1.toDer()
publicKey2 = EllipticCurve::PublicKey.fromDer(der)
assertEqual(publicKey1.toPem, publicKey2.toPem)


subHeader("testStringConversion")
privateKey = EllipticCurve::PrivateKey.new()
publicKey1 = privateKey.publicKey()
string = publicKey1.toString()
publicKey2 = EllipticCurve::PublicKey.fromString(string)
assertEqual(publicKey1.toPem, publicKey2.toPem)


header("Signature")

subHeader("testDerConversion")
privateKey = EllipticCurve::PrivateKey.new()
message = "This is a text message"
signature1 = EllipticCurve::Ecdsa.sign(message, privateKey)
der = signature1.toDer()
signature2 = EllipticCurve::Signature.fromDer(der)
assertEqual(signature1.r, signature2.r)
assertEqual(signature1.s, signature2.s)

subHeader("testBase64Conversion")
privateKey = EllipticCurve::PrivateKey.new()
message = "This is a text message"
signature1 = EllipticCurve::Ecdsa.sign(message, privateKey)
base64 = signature1.toBase64()
signature2 = EllipticCurve::Signature.fromBase64(base64)
assertEqual(signature1.r, signature2.r)
assertEqual(signature1.s, signature2.s)


if $failure == 0
    puts "\n\nALL #{$success} TESTS SUCCESSFUL\n\n"
else
    puts "\n\n#{$failure}/#{$failure + $success} FAILURES OCCURRED\n\n"
end
