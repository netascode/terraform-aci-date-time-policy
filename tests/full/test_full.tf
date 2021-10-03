terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

module "main" {
  source = "../.."

  name                           = "DATE1"
  apic_ntp_server_master_stratum = 10
  ntp_admin_state                = false
  ntp_auth_state                 = true
  apic_ntp_server_master_mode    = true
  apic_ntp_server_state          = true
  ntp_servers = [{
    hostname_ip   = "100.1.1.1"
    preferred     = true
    mgmt_epg_type = "inb"
    mgmt_epg_name = "INB1"
    auth_key_id   = 1
  }]
  ntp_keys = [{
    id        = 1
    key       = "SECRETKEY"
    auth_type = "sha1"
    trusted   = true
  }]
}

data "aci_rest" "datetimePol" {
  dn = "uni/fabric/time-${module.main.name}"

  depends_on = [module.main]
}

resource "test_assertions" "datetimePol" {
  component = "datetimePol"

  equal "name" {
    description = "name"
    got         = data.aci_rest.datetimePol.content.name
    want        = module.main.name
  }

  equal "StratumValue" {
    description = "StratumValue"
    got         = data.aci_rest.datetimePol.content.StratumValue
    want        = "10"
  }

  equal "adminSt" {
    description = "adminSt"
    got         = data.aci_rest.datetimePol.content.adminSt
    want        = "disabled"
  }

  equal "authSt" {
    description = "authSt"
    got         = data.aci_rest.datetimePol.content.authSt
    want        = "enabled"
  }

  equal "masterMode" {
    description = "masterMode"
    got         = data.aci_rest.datetimePol.content.masterMode
    want        = "enabled"
  }

  equal "serverState" {
    description = "serverState"
    got         = data.aci_rest.datetimePol.content.serverState
    want        = "enabled"
  }
}

data "aci_rest" "datetimeNtpProv" {
  dn = "${data.aci_rest.datetimePol.id}/ntpprov-100.1.1.1"

  depends_on = [module.main]
}

resource "test_assertions" "datetimeNtpProv" {
  component = "datetimeNtpProv"

  equal "name" {
    description = "name"
    got         = data.aci_rest.datetimeNtpProv.content.name
    want        = "100.1.1.1"
  }

  equal "preferred" {
    description = "preferred"
    got         = data.aci_rest.datetimeNtpProv.content.preferred
    want        = "yes"
  }
}

data "aci_rest" "datetimeRsNtpProvToEpg" {
  dn = "${data.aci_rest.datetimeNtpProv.id}/rsNtpProvToEpg"

  depends_on = [module.main]
}

resource "test_assertions" "datetimeRsNtpProvToEpg" {
  component = "datetimeRsNtpProvToEpg"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.datetimeRsNtpProvToEpg.content.tDn
    want        = "uni/tn-mgmt/mgmtp-default/inb-INB1"
  }
}

data "aci_rest" "datetimeRsNtpProvToNtpAuthKey" {
  dn = "${data.aci_rest.datetimeNtpProv.id}/rsntpProvToNtpAuthKey-1"

  depends_on = [module.main]
}

resource "test_assertions" "datetimeRsNtpProvToNtpAuthKey" {
  component = "datetimeRsNtpProvToNtpAuthKey"

  equal "tnDatetimeNtpAuthKeyId" {
    description = "tnDatetimeNtpAuthKeyId"
    got         = data.aci_rest.datetimeRsNtpProvToNtpAuthKey.content.tnDatetimeNtpAuthKeyId
    want        = "1"
  }
}

data "aci_rest" "datetimeNtpAuthKey" {
  dn = "${data.aci_rest.datetimePol.id}/ntpauth-1"

  depends_on = [module.main]
}

resource "test_assertions" "datetimeNtpAuthKey" {
  component = "datetimeNtpAuthKey"

  equal "id" {
    description = "id"
    got         = data.aci_rest.datetimeNtpAuthKey.content.id
    want        = "1"
  }

  equal "key" {
    description = "key"
    got         = data.aci_rest.datetimeNtpAuthKey.content.key
    want        = "SECRETKEY"
  }

  equal "keyType" {
    description = "keyType"
    got         = data.aci_rest.datetimeNtpAuthKey.content.keyType
    want        = "sha1"
  }

  equal "trusted" {
    description = "trusted"
    got         = data.aci_rest.datetimeNtpAuthKey.content.trusted
    want        = "yes"
  }
}
