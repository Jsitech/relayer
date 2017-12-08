### Relayer - SMB Relay Script.

Relayer is an SMB relay Script that automates all the necessary steps to scan for
systems with SMB signing disabled and relaying authentication request to these systems
with the objective of gaining a shell. Great when performing Penetration testing.

Relayer makes use of Unicorn from trustedsec to create the payload that is executed
on the target system you select. see https://github.com/trustedsec/unicorn , you can run
the listener on the system you are running relayer on or an alternative system.

I will be adding more payload options later on.

Relayer is based off chuckle from nccgroup. so credits to them.

# USE

Run install_req.sh to validate dependencies and install missing ones.

Once everything is ready, usage is simple, simply run as root:

sudo ./relayer.sh

# How does the Script Work

Script runs the following Steps:

* Scan for SMB Systems and List those with SMB signing Disabled
* User selects system to Relay the authentication attempts to
* User selects where to set the Listener for incoming connections
* Relayer creates payload and sets up Responder and SMBRelayX
* Wait for connection attempts to your attacking machine and check Listener

# NOTE

Only run this tool where you have permission to do so.
