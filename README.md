#  helm-charts-interactive-services

Helm charts interactive services 

This collection of Helm Charts is tailored for datascientists ! It is primarily designed to work with Onyxia but you can use them like  helm charts.

helm repo add inseefrlab-datascience https://inseefrlab.github.io/helm-charts-interactive-services

The repo is also browsable directly https://inseefrlab.github.io/helm-charts-interactive-services/index.yaml

Contributions are welcome, feel free to open issues or submit pull requests :)

## Create your own schemas for [Onyxia](https://github.com/inseefrlab/onyxia)

Our charts allow you to personify the user experience on your platform by defining json schemas.  
For more information on this mecanism, [refer to the dedicated page](https://docs.onyxia.sh/admin-doc/catalog-of-services#x-onyxia-overwriteschemawith).

Following, you will find a list of all the schemas used in this repository. You can also [consult the default schemas](https://github.com/InseeFrLab/onyxia-api/tree/main/onyxia-api/src/main/resources/schemas).


|Schema|Description|
|---------|---------------------------------|
|[ide/customImage.json](#ide/cutomImage.json)|Choose whether a user is allowed to use a custom image|
|ide/git.json|Add git configuration inside your environment|
|[ide/ingress.json](#ide/ingress.json)|Configure ingress parameters|
|ide/init.json|Initialization parameters|
|[ide/message.json](#ide/message.json)|✉️  Add a message in different languages in the NOTES.txt |
|ide/openshiftSCC.json|Configuration for Openshift compatibility|
|ide/password.json|Password|
|ide/persistence.json|Configuration for persistence|
|ide/resources-gpu.json|Resources|
|[ide/resources.json](#ide/resources.json)|Resources|
|[ide/role.json](#ide/role.json)|Defines the default kubernetes role for interactive services pods|
|ide/route.json|Configure route parameters|
|ide/s3.json|Configuration of temporary identity for AWS S3|
|ide/startupProbe.json|Startup probe|
|ide/vault.json|Configuration of vault client|
|[certificates.json]()|Certificates|
|[network-policy.json]()|Network Policy|
|[nodeSelector-gpu.json]()|Node Selector|
|nodeSelector.json|Node Selector|
|[proxy.json]()|Proxy|
|role-spark.json|Role|
|[spark.json](#spark.json)|Spark specific configuration|
|tolerations.json|Kubernetes Tolerations|

## Schema & Configuration Examples

### ide/customImage.json 

This schema allows you to permit or forbid users from installing custom images when launching their service. 

#### Allow users to install a custom image. 
By default, the custom property is set to false. If set to true, a default version image is automatically assigned to the corresponding field.

```yaml
- relativePath: ide/customImage.json
    content: |
        {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "title": "custom image",
            "type": "boolean",
            "description": "use a custom jupyter docker image",
            "default": false
        }
```

#### Forbide users to install a custom image.

 The following code disables the option to install a custom image and also hides the field from the user. Moreover, if a user attempts to override this by forcing a custom image using constants, it will fail. This is due to the `const` keyword defining a fixed value, which cannot be changed.

```yaml
- relativePath: ide/custom-image.json
    content: |
        {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "type": "boolean",
            "const": false,
            "x-onyxia": {
                "hidden": true
            }
        }
```

### ide/ingress.json

This schema is used to configure ingress settings.

It defines parameters such as whether ingress is enabled, hostname configurations, ingress class name, and certificate management using CertManager. 

The following schema hides all the fields from the user by default. It dynamically fills in values ensuring automated and consistent configuration during service deployment by using [onyxia injections](https://docs.onyxia.sh/admin-doc/catalog-of-services#x-onyxia-overwritedefaultwith). 

To ensure that your user deploys an ingress to a specific domain name (e.g. mydomain.com), you can enforce this by specifying a pattern using a regular expression.

Additionally, you can automate SSL certificate generation by integrating certManager, which can issue and manage certificates for your ingress resource.


```yaml

{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Ingress",
    "description": "Ingress parameters",
    "type": "object",
    "properties": {
        "enabled": {
            "description": "Enable Ingress",
            "type": "boolean",
            "const": true,
            "x-onyxia": {
                "hidden": true,
            }
        },
        "hostname": {
            "type": "string",
            "form": true,
            "title": "Hostname",
            "pattern": "^([a-zA-Z0-9-]+\.)*mydomain\.com$",
            "x-onyxia": {
                "hidden": true,
                "overwriteDefaultWith": "{{project.id}}-{{k8s.randomSubdomain}}-0.{{k8s.domain}}"
            }
        },
        "userHostname": {
            "type": "string",
            "form": true,
            "title": "Hostname",
            "pattern": "^([a-zA-Z0-9-]+\.)*mydomain\.com$",
            "x-onyxia": {
                "hidden": true,
                "overwriteDefaultWith": "{{project.id}}-{{k8s.randomSubdomain}}-user.{{k8s.domain}}"
            }
        },
        "ingressClassName": {
            "type": "string",
            "form": true,
            "const": "myIngressClassName",
            "x-onyxia": {
                "hidden": true,
            }
        },
        "useCertManager": {
            "type": "boolean",
            "const": true,
            "x-onyxia": {
                "hidden": true,
            }
},
        "certManagerClusterIssuer":{
            "type": "string",
            "const": "myCertManagerClusterIssuer",
            "x-onyxia": {
                "hidden": true,
            }
        }
    }
}

```

### ide/message.json 

This schema adds a message in different languages in the NOTES.txt.

In the following example, a message is added to warn users about the risk of their service being deleted as per management policies. The message is displayed in a different language depending on the user's UI settings.

Currently, our charts support two languages (French and English).

```yaml
- relativePath: ide/message.json
    content: |
    {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": "Message",
        "description": "Add message in notes",

        "type": "object",
        "properties": {
        "fr": {
            "type": "string",
            "x-onyxia": {
                "hidden": true
            },
            "description":"message à ajouter dans les notes",
            "default": "**NB:** ce service pourrait être supprimé après 7 jours d'utilisation en raison de nos règles de gestion"
        },
        "en": {
            "type": "string",
            "x-onyxia": {
                "hidden": true
            },
            "description": "message to add in notes",
            "default": "**Warning:** this service may be deleted after 7 days due to our management policies"
            }
        }
    }
```

### ide/resources.json

This schema defines the resource management configuration for a service. 

Specifically, it is used to set guaranteed resources (requests) and maximum resource limits (limits) for CPU and memory. It allows for the specification of both minimum (guaranteed) and maximum (capped) resources, using sliders to adjust values within set ranges. Hence the users will have a precise control over resources allocation within the allowed range.

```yaml
- relativePath: ide/resources.json
    content: |
    {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": "Resources",
        "description": "Your service will have at least the requested resources and never more than its limits. No limit for a resource and you can consume everything left on the host machine.",
        "type": "object",
        "properties": {
            "requests": {
                "description": "Guaranteed resources",
                "type": "object",
                "properties": {
                    "cpu": {
                        "description": "The amount of cpu guaranteed",
                        "title": "CPU",
                        "type": "string",
                        "default": "100m",
                        "render": "slider",
                        "sliderMin": 100,
                        "sliderMax": 40000,
                        "sliderStep": 100,
                        "sliderUnit": "m",
                        "sliderExtremity": "down",
                        "sliderExtremitySemantic": "guaranteed",
                        "sliderRangeId": "cpu"
                    },
                    "memory": {
                        "description": "The amount of memory guaranteed",
                        "title": "memory",
                        "type": "string",
                        "default": "2Gi",
                        "render": "slider",
                        "sliderMin": 1,
                        "sliderMax": 200,
                        "sliderStep": 1,
                        "sliderUnit": "Gi",
                        "sliderExtremity": "down",
                        "sliderExtremitySemantic": "guaranteed",
                        "sliderRangeId": "memory"
                    }
                }
            },
            "limits": {
                "description": "max resources",
                "type": "object",
                "properties": {
                    "cpu": {
                        "description": "The maximum amount of cpu",
                        "title": "CPU",
                        "type": "string",
                        "default": "30000m",
                        "render": "slider",
                        "sliderMin": 100,
                        "sliderMax": 40000,
                        "sliderStep": 100,
                        "sliderUnit": "m",
                        "sliderExtremity": "up",
                        "sliderExtremitySemantic": "Maximum",
                        "sliderRangeId": "cpu"
                    },
                    "memory": {
                        "description": "The maximum amount of memory",
                        "title": "Memory",
                        "type": "string",
                        "default": "50Gi",
                        "render": "slider",
                        "sliderMin": 1,
                        "sliderMax": 200,
                        "sliderStep": 1,
                        "sliderUnit": "Gi",
                        "sliderExtremity": "up",
                        "sliderExtremitySemantic": "Maximum",
                        "sliderRangeId": "memory"
                    }
                }
            }
        }
    }
```

### ide/role.json

This schema defines the default kubernetes role for interactive services pods. As it is very permissive, you may want to restrict it to view-only access, using a constant.  

#### Permissive schema
```yaml
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Role",
    "type": "object",
    "properties": {
        "enabled": {
            "type": "boolean",
            "description": "allow your service to access your namespace ressources",
            "default": true
        },
        "role": {
            "type": "string",
            "description": "bind your service account to this kubernetes default role",
            "default": "view",
            "hidden": {
                "value": false,
                "path": "kubernetes/enabled"
            },
            "enum": [
                "view",
                "edit",
                "admin"
            ]
        }
    }
}
```
#### Restricted schema

You can enforce the role using the 'view' constant.

```yaml
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Role",
  "type": "object",
  "properties": {
    "enabled": {
      "type": "boolean",
      "const": true,
      "x-onyxia":{
        "hidden": true
      }
    },
    "role": {
      "type": "string",
      "const": "view",
    }
  }
}
```
### certificates.json

TO DO

### network-policy.json

WIP

Utiliser les namespaces (metadatas annotation)

```yaml
- relativePath: network-policy.json
    content: |
    {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "title": "Network Policy",
        "description": "Define access policy to the service",
        "properties": {
            "enabled": {
                "type": "boolean",
                "title": "Enable network policy",
                "description": "Only pod from the same namespace will be allowed",
                "default": true
            },
            "from": {
                "type": "array",
                "description": "Array of source allowed to have network access to your service",
                "default": [
                    { "namespaceSelector": { "matchLabels": { "kubernetes.io/metadata.name" : mynamespace } } }
                ],
                "x-onyxia": {
                    "hidden": true
                }
            }
        }
    }
```

### nodeSelector-gpu.json

This schema allows you to specify which gpu resource will be used by your service. 

In the following example, we use the `nvidia.com/gpu.product` annotation and force the user to select a specific type of gpu from the following options: NVIDIA-A2, Tesla-T4 or NVIDIA-H100-PCIe.

```yaml
        - relativePath: nodeSelector-gpu.json
          content: |
            {
              "$schema": "http://json-schema.org/draft-07/schema#",
              "title": "Node Selector",
              "type": "object",
              "properties": {
                "nvidia.com/gpu.product": {
                  "description": "The type of GPU",
                  "type": "string",
                  "default": "NVIDIA-A2",
                  "enum": ["NVIDIA-A2", "Tesla-T4", "NVIDIA-H100-PCIe"]
                }
              },
              "additionalProperties": false
            }
```

### proxy.json

This schema is used to automatically inject proxy environment variables into the interactive service. 

In the following example, the configuration is hidden from users and enforces the use of predefined values for these variables.

```yaml
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Proxy",
    "type": "object",
    "properties": {
        "enabled": {
            "type": "boolean",
            "description": "Inject proxy settings",
            "const": false,
            "x-onyxia": {
                "hidden": true
                }
            },
        "httpProxy": {
            "type": "string",
            "description": "Proxy URL for HTTP requests",
            "const": "myHttpProxy",
            "x-onyxia": {
                "hidden": true
            }
        },
        "httpsProxy": {
            "type": "string",
            "description": "Proxy URL for HTTPS requests",
            "const": "myHttpsProxy",
            "x-onyxia": {
                "hidden": true
            }
        },
        "noProxy": {
            "type": "string",
            "description": "Comma separated list of hosts for which proxy is bypassed",
            "const": "myNoProxy",
            "x-onyxia": {
                "hidden": true
            }
        }
    }
}
```

### spark.json

This schema enables the Spark UI and let the user change the default spark config like disabling certificate checkings for spark metastore configuration (if used with the discovery mecanism) and specifying spark session configuration that will be stored inside of a spark-config.conf fille.

If you want to use spark in cluster mode, you have to give spark an admin kubernetes role. If you [do not want to do so](#spark-with-kubernetes-view-role), you have the ability to configure spark in local mode and force the use of a view kubernetes role.

#### Spark with Kubernetes admin role

The following schema enables spark ui, and create a default spark configuration as set in the userConfig object. Users will have the ability to modify the field to adapt it to his needs.  
Note the spark default config is shown when the `default` property is set to true thanks to the `path` key inside of the `hidden` object.

```yaml
- relativePath: spark.json
    content: |
    {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": "Spark",
        "type": "object",
        "description": "spark specific configuration",
        "properties": {
            "sparkui": {
                "type": "boolean",
                "title": "SparkUI",
                "description": "Enable Spark monitoring interface",
                "const": true,
                "x-onyxia": {
                    "hidden": true
                }
            },
            "disabledCertChecking": {
                "title": "Disable certificate checking ",
                "type": "boolean",
                "description": "Disable certificate checking for your S3 storage, do not use it in production",
                "default": false
            },
            "default": {
                "type": "boolean",
                "title": "Create a spark config",
                "description": "Create a default spark config in spark-default.conf",
                "const": true,
                "x-onyxia": {
                    "hidden": true
                }
            },
            "userConfig": {
                "type": "object",
                "title": "Create a spark config",
                "description": "Create a default spark config in spark-default.conf",
                "default": {
                    "spark.dynamicAllocation.enabled": "true",
                    "spark.dynamicAllocation.initialExecutors": "1",
                    "spark.dynamicAllocation.minExecutors": "1",
                    "spark.dynamicAllocation.maxExecutors": "10",
                    "spark.executor.memory": "2g",
                    "spark.driver.memory": "2g",
                    "spark.dynamicAllocation.executorAllocationRatio": "1",
                    "spark.dynamicAllocation.shuffleTracking.enabled": "true",
                    "spark.hadoop.fs.s3a.bucket.all.committer.magic.enabled": "true"
                },
                "hidden": {
                    "value": false,
                    "path": "default",
                    "isPathRelative": true
                }
            }
        }
    }

```

#### Spark with Kubernetes view role

If you do not wish to allow the admin kubernetes role, you have to use role-spark.json schema with the [restrictive configuration exposed](#restricted-schema) and preconfigure spark in local mode, thanks `userConfig` object in the spark.json schema. With such settings, the user won't need to specify the master in the session builder.


```yaml
- relativePath: spark.json
    content: |
    {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": "Spark",
        "type": "object",
        "description": "spark specific configuration",
        "properties": {
            "sparkui": {
                "type": "boolean",
                "title": "SparkUI",
                "description": "Enable Spark monitoring interface",
                "const": true,
                "x-onyxia": {
                    "hidden": true
                }
            },
            "disabledCertChecking": {
                "title": "Disable certificate checking ",
                "type": "boolean",
                "description": "Disable certificate checking for your S3 storage, do not use it in production",
                "const": false,
                "x-onyxia": {
                    "hidden": true
                }
            },
            "default": {
                "type": "boolean",
                "title": "Create a spark config",
                "description": "Create a default spark config in spark-default.conf",
                "const": true,
                "x-onyxia": {
                    "hidden": true
                }
            },
            "userConfig": {
                "type": "object",
                "title": "Create a spark config",
                "description": "Create a default spark config in spark-default.conf",
                "default": {
                    "spark.master": "local[10]"
                },
                "hidden": {
                    "value": false,
                    "path": "default",
                    "isPathRelative": true
                }
            }
        }
    }
```

## Governance references

- [GOVERNANCE.md](https://github.com/InseeFrLab/onyxia/blob/main/GOVERNANCE.md)
- [CODE_OF_CONDUCT.md](https://github.com/InseeFrLab/onyxia/blob/main/CODE_OF_CONDUCT.md)
- [ROADMAP.md](https://github.com/InseeFrLab/onyxia/blob/main/ROADMAP.md)
- [SECURITY.md](https://github.com/InseeFrLab/onyxia/blob/main/SECURITY.md)
