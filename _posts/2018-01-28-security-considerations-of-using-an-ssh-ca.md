---
layout: post
title:  Security considerations of using an SSH CA
---

If you study the `ssh-keygen(1)` man page of newer OpenSSH versions, you might notice options regarding certificate-based authentication.

## Difference from conventional keypair-based authentication

When using classic ssh keypair authentication, the user gives their public key to the server administrator, who in turn will add it to the `~/.ssh/authorized_keys` file.
Or replace the administrator with an automation tool of your choice.
By adding and removing pubkeys from said file, the server has explicit information about which clients are allowed to log in into which account.

When using an SSH certificate authority, another keypair comes into play.
The CA keypair is generated on a third machine, and its pubkey is registered once on the server.
To give an user access, the server administrator takes the users public key and generates a certificate for it.
The certificate contains the public key as well as the username the key owner may login as.
The user places the certificate next to their private key on their client machine, no further modifications on the server is necessary.

When authenticating, the user's ssh client presents the certificate to the server, which in turn checks its validity against the CA's public key.

## Advantages

- The `authorized_keys` on servers don't need to be managed anymore, this is especially useful for large server farms
- Certificates can be restricted in terms of their validity times or feature sets (like hard-coding "no-port-forwarding" into the certificate)
- User key rotation is just a matter of regenerating a keypair and getting it signed
- Auditing: A certificate has a comment field, which the SSH Server logs on user login
- The CA can also sign SSH host (server) keys

## Disadvantages

- Auditing: Server does not have information about which users are potentially able to log in
- The CA needs to maintain a list of issued certificates to be able to revoke them
- A revocation list needs to be properly maintained and distributed in-time
- Central point of failure: The CA must be properly protected, best by being in an air-gapped system.

## Idea regarding updating the revocation list

The SSH daemon supports the `AuthorizedKeysCommand` directive.
When used, users attempting to log in will trigger the server to run an external command, which then may fetch additional valid public keys for that user and supply them to sshd via stdout.
This is typically used in companies to centrally manage public keys via LDAP.

When authenticating, the ssh client tries to offer all available public keys to the server.
To be able to properly accept or reject public keys, the server already needs to have the external command executed.
This means that the command will have already returned before the server attempts to verifying the clients public key or certificate.

We can exploit this by using the `AuthorizedKeysCommand` directive to trigger a refetch of the revocation list, without returning any public keys.
This way we can make sure the server always uses the most recent version of the revocation file.
