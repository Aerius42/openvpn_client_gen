# openvpn_client_gen
Simple bash script to generate the openvpn client access with easy-rsa

## Requisites
Copy Easy-RSA folder in the OpenVPN folder using root mode. Depending on your Linux distribution, it's:
```bash
sudo su
cp /usr/share/doc/openvpn/examples/easy-rsa/2.0/* /etc/openvpn/easy-rsa/
```
or
```bash
sudo su
cp /usr/share/doc/openvpn/examples/easy-rsa/2.0/* /etc/openvpn/easy-rsa/
```

## Usage
```bash
sudo su
chmod 755 openvpn_client_gen.sh
./openvpn_client_gen.sh
```
Then, follow the instructions.
