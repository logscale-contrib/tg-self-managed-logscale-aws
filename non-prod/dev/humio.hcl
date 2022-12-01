

# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  humio_rootUser           = "ryan.faircloth@logsr.life"
  humio_license            = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzUxMiJ9.eyJpc09lbSI6ZmFsc2UsImF1ZCI6Ikh1bWlvLWxpY2Vuc2UtY2hlY2siLCJzdWIiOiJDcm93ZFN0cmlrZVBTLVJ5YW5GYWlyY2xvdGgiLCJ1aWQiOiJSZjkxbXdlUDJ2aTE4R1VTIiwibWF4VXNlcnMiOjk5OTk5OSwiYWxsb3dTQUFTIjpmYWxzZSwibWF4Q29yZXMiOjk5OTk5OSwidmFsaWRVbnRpbCI6MTcwMTQzNTYwMCwiZXhwIjoxNzY0NTIzMTk4LCJpc1RyaWFsIjpmYWxzZSwiaWF0IjoxNjY5OTE1MTk4LCJtYXhJbmdlc3RHYlBlckRheSI6OTk5OTk5fQ.AC_tHQpA9uBceX54JhiGPkDbqTx9GNlaBS9vs_HjIE1MKoQ1RzhCW-X7s9psNIWhftD3mrZjABWyNBw5yRqJn4MdALdzNgCaVnx__NGYXG3xdEiuwBPklaZARev3pTJwluRxYrhO4--h1o6lHSjy1g33StQSxF1KY_7hXZg9MfWgOkcF"
  humio_sso_idpCertificate = <<-EOT
-----BEGIN CERTIFICATE-----
MIIC8DCCAdigAwIBAgIQdToowApcL5xFnfZ/9hOS/DANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQD
EylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yMjExMjkxMzA4
MjhaFw0yNTExMjkxMzA4MjhaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQg
U1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvYCM+5G4dRFu
Tc6Ct9hDPhqp+RXjh5cli/QTh5qREfGTA2sKB1hjOpU58mI4pfVU6CE1JhvyJ4jIP5S7J0mYd34G
jWkpY4u5NGkr+y0bN3u3eb0DDOEbsy/bYOaJvzOauiF0F4y7VefswyhMa7brYzGZsfeFjAQPvAes
MlMuC2M1Is60hGUlRUuj9sXoiIhRTRsWF1WME3ve6V6HzTDsJ9OeE64G9Q2lcqrV2IbfX5Zi9NN1
MfL3rINajrZGYt7XeXMdF5/IJntso5CRLKB0Bt3HQKoLD3oVBiLzgRjwsaScNetdOmAnHEjZ/+8n
EECEb34kdS6W5SaBTlFdV/P/iQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAkUY5omLXzywc+KxGW
5jW6B8Jj9qs9mr/dlmcKwDlCfqKttDJKp/V7KC6teZvWjko4az2vFdAzd26nrubjG2F7Vs/i29Nn
G8xiSvsG9yizoZ4dmC6xBdazG2rEW7BMK/TE9cLZCswexXn2eN+yWJ7wSpjOTw8EP0JGaJaTXIxZ
GXMMvJVyk2Qh0agqhc0R84I/duO5gnUXYbri0sK3I5IVXzfd/SXD5+1tFAERUVBfZEaj8MgvcQB8
PwiJAJnBXVEKc6vd4uhhNGWru8Lra8Nk0gqI8EgVcaNSxGyrv8u+qRuImdfoLza8gg57+JaPgmsJ
xCrwUp80ypIUorNCONuy
-----END CERTIFICATE-----
EOT

  humio_sso_signOnUrl = "https://login.microsoftonline.com/4d40b7e0-fca8-48d9-8fea-3d117a06b2a7/saml2"
  humio_sso_entityID  = "https://sts.windows.net/4d40b7e0-fca8-48d9-8fea-3d117a06b2a7/"
}