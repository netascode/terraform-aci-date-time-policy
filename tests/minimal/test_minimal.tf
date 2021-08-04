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

  name = "DATE1"
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
}
