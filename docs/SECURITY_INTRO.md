## Security

Please read the following resources to get an overview of Ruby and Rails security before opening PRs.

[Ruby on Rails Security Cheatsheet](https://www.owasp.org/index.php/Ruby_on_Rails_Cheatsheet)

Get familiar with Brakeman and run it often. It runs as part of the build but it is easier to run it before opening your PR and fixing it there.

[Brakeman Scanner](http://brakemanscanner.org/)

### Cryptography
If you need to encrypt, sign or hash something here are the recommended libraries. Do not roll your own library and use only libraries that have been reviewed by the community.

#### Hashing
Ruby has built in hash function that can be used. MD5 and SHA1 are considered broken and should not be used. SHA2 is still considered secure.

Example:
```
> require 'digest'
> Digest::SHA2.hexdigest 'abc'
> "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
```

#### Password hashing
Bcrypt or Scrypt are the preferred methods for hashing passwords. More details are here:

[Bcrypt](https://github.com/codahale/bcrypt-ruby)

#### Encryption
RbNaCl is a great library that makes encryption in Ruby relatively easy. Be cautious when deciding to use encryption, there are a million ways to make a mistake and they're often overlooked.

[RbNaCl](https://github.com/cryptosphere/rbnacl)

#### Signing
Rails has a built in method to sign messages.

[Message Verifier](http://api.rubyonrails.org/classes/ActiveSupport/MessageVerifier.html)

#### Random Token
If you need to generate a random token, for a reset password email for example, use SecureRandom that is built into Ruby.

[SecureRandom](https://ruby-doc.org/stdlib-2.3.0/libdoc/securerandom/rdoc/SecureRandom.html)

#### More reading:

Checkout [this document]( https://github.com/DCAFEngineering/dcaf_case_management/docs/SECURITY_INTRO.md) on basic Ruby on Rails security.

[Ruby on Rails Security Guide](http://guides.rubyonrails.org/security.html)

[An Overview of Cryptography](http://www.garykessler.net/library/crypto.html)

[Password Hashing](https://crackstation.net/hashing-security.htm)