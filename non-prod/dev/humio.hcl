

# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  humio_rootUser           = "ryan@dss-i.com"
  humio_license            = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzUxMiJ9.eyJpc09lbSI6ZmFsc2UsImF1ZCI6Ikh1bWlvLWxpY2Vuc2UtY2hlY2siLCJzdWIiOiJyeWFuZmFpcmNsb3RoY3Jvd2RzdHJpa2Vjb20iLCJ1aWQiOiJoQkI4aDlSYXBFSkcwQmRxIiwibWF4VXNlcnMiOjk5OTk5OSwiYWxsb3dTQUFTIjpmYWxzZSwibWF4Q29yZXMiOjEwMCwidmFsaWRVbnRpbCI6MTY3MjQ5MTYwMCwiZXhwIjoxNzQ2ODAxNDQzLCJpc1RyaWFsIjpmYWxzZSwiaWF0IjoxNjUyMTkzNDQzLCJtYXhJbmdlc3RHYlBlckRheSI6MTAwfQ.AHQtJPoogNL2YqMsV7BuWQZAoWINW6-Y1hBus5-XSkvnHJqFxgOzrecYq46uy_4PvNrfU2vgXzxaJo6JiMqbmlJNAd94tmsFTakN4wpUmDR5_u3-6PcjngSuVhY2QMopIoYMcnstUZ1ovs4wbUfQ809HwNTiJyyR2AyLzao18_pvaBXO"
  humio_sso_idpCertificate = <<-EOT
            -----BEGIN CERTIFICATE-----
            MIIDdDCCAlygAwIBAgIGAYDb5DpjMA0GCSqGSIb3DQEBCwUAMHsxFDASBgNVBAoTC0dvb2dsZSBJ
            bmMuMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MQ8wDQYDVQQDEwZHb29nbGUxGDAWBgNVBAsTD0dv
            b2dsZSBGb3IgV29yazELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWEwHhcNMjIwNTE5
            MTAzNjQ4WhcNMjcwNTE4MTAzNjQ4WjB7MRQwEgYDVQQKEwtHb29nbGUgSW5jLjEWMBQGA1UEBxMN
            TW91bnRhaW4gVmlldzEPMA0GA1UEAxMGR29vZ2xlMRgwFgYDVQQLEw9Hb29nbGUgRm9yIFdvcmsx
            CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
            MIIBCgKCAQEAoQEsZwNm5F8v9wP5tHhD9udu95HhVwOjepcXP5oZWtaAn3pSj/eXFJ/XXwLKMzFJ
            erg9zTu8uqfmWlSqBKjmXDch1jcX5BZI2tYpObQerjSeEjhbJXGRV0Tj/8i7KWk7b5PMasDEmQpW
            BdEMgqe35hWaatoS5MtSW3rkdMWdqrjdIsOP4n7PQNm86nFY28VmkzN9+luWYxA7AwK09D9JxThE
            aw5p5VCw1HK0AHoaOyfC1BWt2xL3PtRIWzwLlBUbaFoIIhjahDfex40q0YDw49mzBpIjUENr5Vcv
            AURNwYZqw+mgG4ViR/GWPPftzyJyEoOOXFwt/gVkx/OxgzssZwIDAQABMA0GCSqGSIb3DQEBCwUA
            A4IBAQAMZXfKqDT3W5cdlFsC7fRMfN1NSW03j7kK4SsKUXHi/X7COBN2nIP3evx8bkEemT1OT9Rr
            ZWL+f0NMUBVrKTbrDdhH2tQ0mxYehVeyzXj6jT8avMYhB0c0N5WTXSSW+8Ida+qwZozXFxqda/t/
            NpKOzwJYXLmH1calsoGnLGtr1su8Z6DrG9cQTbPk5NPxZKAqgT2LW1h4B/mFrf0loTXqTrpKMGaD
            NeMDalHWBxq77PtxUfUg8K5SP//FgLfiAK56n0uzt/J2MZ6ZbJOnN/HoqGvQ4PvGR998/fH6MrW6
            +lRTBBUDC0saTEYlp6TWkFib7Ub6LcWbncZJY1O3L2ZZ
            -----END CERTIFICATE-----
EOT

  humio_sso_signOnUrl = "https://accounts.google.com/o/saml2/idp?idpid=C011isbhl"
  humio_sso_entityID  = "https://accounts.google.com/o/saml2?idpid=C011isbhl"
}