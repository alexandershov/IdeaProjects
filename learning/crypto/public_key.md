## Public key cryptography

### How it works
I generate public and private key.
I keep private key to myself.
I share public key with the world.

Public key can encrypt the message.
Only private key can decrypt the message.

Actually reverse is also true. I can encrypt message with my private key. 
And it can be decrypted only with the public key. 
This reverse property can be used in signatures.

If someone wants to send some message to me, then they take my public key, encrypt their message with it and
send encrypted message to me.
I can decrypt this message with my private key.
Only my private key can decrypt encrypted message, so it's cool if anyone sees the encrypted message.
Without my private key they can't anything. 

### Signatures
Now someone (Alice) sent me some message. How do I verify that message is indeed from Alice?
Alice can take some hash of the message, encrypt it with her private key, and this part as a signature.
When I receive her message I decrypt main part the usual way.
Then I take the signature, decrypt it with Alice public key (using reverse property of public-private key).
Now I can calculate hash of the message with the hash from signature.
If they match, then I can be sure that:
* Message was sent by someone in possession of Alice private key (hopefully, Alice)
* Message was not tampered with (because hashes match)

### Details
I don't fully understand the math behind RSA.

The gist of it is that we generate 3 numbers.
E, D, and N.
These numbers have property that for each M < N: (M^E)^D mod N = M
E and N is a public key.
D is private key.
M stands for "Message".
E stands for "Encrypt".
D stands for "Decrypt".
N doesn't stand for anything.

The idea is that it's computationally expensive to find D knowing only N and E.
It has something do to with finding large prime factors. 
D and E are Very Large Numbers by the way. N - not so much for some mathy reason.

Encryption is done with S = (M^E) mod N.
We do decryption with (S^D) mod N.
Let's prove that we'll also get M this way.

M = (M^E)^D mod N = (M^E * ...(D times)... * M^E) mod N

Let's use property of modular product (A * B) mod N = ((A mod N) * (B mod N)) mod N

(M^E * ...(D times)... * M^E) mod N =

((M^E) mod N * ...(D times)... * (M^E) mod N) mod N = (S * ... * (D times) * S) mod N =
= S^D mod N
QED.


### Using OpenSSL to encrypt/decrypt

Generate keys (it'll ask for a passphrase):
```shell
openssl genrsa -aes128 -out my_private.pem 1024
```

View private key info (it contains also public info, not just private part):
```shell
$ openssl rsa -in my_private.pem -noout -text
modulus: <redacted>
publicExponent: 65537 (0x10001)
privateExponent: <redacted>
prime1: <redacted>
prime2: <redacted>
exponent1: <redacted>
exponent2: <redacted>
coefficient: <redacted>
```

`65537` is often (always?) used as `E`.

Extract public key from pem:
```shell
openssl rsa -in my_private.pem -pubout > my_public.pem
```

View public key info:
```shell
openssl rsa -in my_public.pem -pubin -text -noout
Public-Key: (1024 bit)
Modulus:
    00:bd:cc:38:22:86:ad:07:e7:20:61:40:d7:64:e3:
    1f:b5:a3:33:57:52:72:f8:cd:e4:d9:4e:24:bc:ae:
    f6:3a:9c:10:56:b8:b7:c2:9e:61:86:5e:98:1c:a4:
    10:d6:a5:d2:25:b5:d7:a8:e3:a8:2e:be:9d:f0:27:
    91:00:54:65:4f:db:c9:5a:b9:30:7d:ba:30:85:7d:
    38:1c:ca:4c:b1:bd:42:63:5a:02:7f:d6:46:33:4e:
    47:6f:bb:80:51:1b:4a:12:e1:17:6b:f6:37:95:68:
    e3:42:e2:cb:67:bc:03:66:8b:dc:30:44:be:9a:e3:
    26:12:56:0e:7c:94:c5:b8:77
Exponent: 65537 (0x10001)
```

Modulus is `N`, Exponent is `E`.

Encrypt message with public key:
```shell
openssl rsautl -encrypt -inkey my_public.pem -pubin -in /dev/stdin -out encrypted.txt
```

`encrypted.txt` is a binary file now.

Decrypt message with private key:
```shell
openssl rsautl -decrypt -inkey my_private.pem -in encrypted.txt
```
