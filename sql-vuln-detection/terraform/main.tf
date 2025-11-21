module "namespace" {
  source    = "./modules/namespace"
  namespace = var.namespace
}

module "postgres" {
  source     = "./modules/postgres"
  namespace  = module.namespace.name
  depends_on = [module.namespace]
}

module "app" {
  source     = "./modules/app"
  namespace  = module.namespace.name
  depends_on = [module.namespace, module.postgres]
}

module "sqli_detector" {
  source     = "./modules/sqli_detector"
  namespace  = module.namespace.name
  depends_on = [module.namespace, module.app]
}
