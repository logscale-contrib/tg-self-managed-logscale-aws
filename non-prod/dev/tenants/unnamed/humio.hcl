

# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  humio_rootUser           = "ryan.faircloth@logsr.life"
  humio_license            = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzUxMiJ9.eyJpc09lbSI6ZmFsc2UsImF1ZCI6Ikh1bWlvLWxpY2Vuc2UtY2hlY2siLCJzdWIiOiJDcm93ZFN0cmlrZVBTLVJ5YW5GYWlyY2xvdGgiLCJ1aWQiOiJSZjkxbXdlUDJ2aTE4R1VTIiwibWF4VXNlcnMiOjk5OTk5OSwiYWxsb3dTQUFTIjpmYWxzZSwibWF4Q29yZXMiOjk5OTk5OSwidmFsaWRVbnRpbCI6MTcwMTQzNTYwMCwiZXhwIjoxNzY0NTIzMTk4LCJpc1RyaWFsIjpmYWxzZSwiaWF0IjoxNjY5OTE1MTk4LCJtYXhJbmdlc3RHYlBlckRheSI6OTk5OTk5fQ.AC_tHQpA9uBceX54JhiGPkDbqTx9GNlaBS9vs_HjIE1MKoQ1RzhCW-X7s9psNIWhftD3mrZjABWyNBw5yRqJn4MdALdzNgCaVnx__NGYXG3xdEiuwBPklaZARev3pTJwluRxYrhO4--h1o6lHSjy1g33StQSxF1KY_7hXZg9MfWgOkcF"
  humio_sso_idpCertificate = <<-EOT
-----BEGIN CERTIFICATE-----
MIIC8DCCAdigAwIBAgIQdZFfeoJBmolFhihbPxK4hjANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQD
EylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMjEyMDExNzU0
MzJaFw0yNTEyMDExNzU0MzJaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQg
U1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1Sd2xfQeAHIW
ewL0R1q+cXMke1Yhk9IWOwPKXjy8+eodrE5O7aSC/VDmXRdhISu/OdWfjNT54nFkuOVNPdy/Kprx
gdvh/4iqaUKs7aM8QZpgMYe3hwoRLaz609bWpJipCvVgcWa7WHCsVj4VA4y1VHwrsA4EPmLQvLr4
vp2t8zH/kUf6IOJaObTH+aaJqchaAtNeS0mAcFh2lnw2fGiaxmbLLRKEnFLsUexPZh61mueDcaN8
FRfuvk9pDrRbOu1iQsKN8dRA7niwx6H9sSC2P6ZPSuir8EWC7V8kY21Pn3pTeMjlWRCP5Ox1XogF
GHoOwxl+D6jTarJs0kz72LlW6QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQA/41rYx+m+/Z+xjs5n
oKe1H0QHqE0bjtz88vLHgTTiFwEd4yvtUUsuH+YfuTWIhdu4m5PvZdvSxr6bkoAED2weNKXNzkrC
msqCeStDfcj8yuUc5VOkQ28eXNkyzgzbgd2wg0XQFdaFq0l88HCC93cdo4CID82anQ6JTj2+tJUz
z0NQ/zxgt/Xok3+qT370bIkC0HyiqGcg96PMNbpp1Sr0jlvDSWVH17fSvi7NAFeY3USt6nH96pa7
eWjjSQb5LSMgMGsjLhxU87gM1g6Qv5lfjvKVsKRRdLhrs9vNyGLjDCdZ0/9fSod51zjehokP5BW3
fWzjElARMjQ32wKcBpRA
-----END CERTIFICATE-----
EOT

  humio_sso_signOnUrl = "https://login.microsoftonline.com/4d40b7e0-fca8-48d9-8fea-3d117a06b2a7/saml2"
  humio_sso_entityID  = "https://sts.windows.net/4d40b7e0-fca8-48d9-8fea-3d117a06b2a7/"
}