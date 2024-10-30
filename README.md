#  helm-charts-interactive-services

Helm charts interactive services

This collection of Helm Charts is tailored for datascientists ! It is primarily designed to work with Onyxia but they can also be used as regular helm charts.

helm repo add inseefrlab-datascience https://inseefrlab.github.io/helm-charts-interactive-services

The repo is also browsable directly https://inseefrlab.github.io/helm-charts-interactive-services/index.yaml

Contributions are much welcome! Feel free to open issues or submit pull requests :)

## Create your own schemas for [Onyxia](https://github.com/inseefrlab/onyxia)

Our charts allow to customize the user experience on your platform by defining json schemas.
For more information on this mecanism, [refer to the dedicated page](https://docs.onyxia.sh/admin-doc/catalog-of-services#x-onyxia-overwriteschemawith).

Following, you will find a list of all the schemas used in this repository. You can also [consult the default schemas](https://github.com/InseeFrLab/onyxia-api/tree/main/onyxia-api/src/main/resources/schemas).


|Schema|Description|
|---------|---------------------------------|
|[ide/customImage.json](#idecustomimagejson)|Choose whether a user is allowed to use a custom image|
|ide/git.json|Add git configuration inside your environment|
|[ide/ingress.json](#ideingressjson)|Configure ingress parameters|
|ide/init.json|Initialization parameters|
|[ide/message.json](#idemessagejson)|✉️  Add a message in different languages in the NOTES.txt |
|ide/openshiftSCC.json|Configuration for Openshift compatibility|
|ide/password.json|Password|
|ide/persistence.json|Configuration for persistence|
|ide/resources-gpu.json|Resources|
|[ide/resources.json](#ideresourcesjson)|Resources|
|[ide/role.json](#iderolejson)|Defines the default kubernetes role for interactive services pods|
|ide/route.json|Configure route parameters|
|ide/s3.json|Configuration of temporary identity for AWS S3|
|ide/startupProbe.json|Startup probe|
|ide/vault.json|Configuration of vault client|
|[ide/extraenv.json](#extraenvjson)|User-defined extra environment variables|
|[certificates.json](#certificatesjson)|Certificates|
|[network-policy.json](#networkpolicyjson)|Network Policy|
|[nodeSelector-gpu.json](#nodeselector-gpujson)|Node Selector|
|nodeSelector.json|Node Selector|
|[proxy.json](#proxyjson)|Proxy|
|role-spark.json|Role|
|[spark.json](#sparkjson)|Spark specific configuration|
|tolerations.json|Kubernetes Tolerations|

## Schema & Configuration Examples

### ide/customImage.json

This schema allows you to permit or forbid users from installing custom images when launching their service.
This is allowed by default.

#### Forbid users to install a custom image

 The following code disables the option to install a custom image and also hides the field from the user.
 Moreover, if a user attempts to override this by forcing a custom image using constants, it will fail.
 This is due to the `const` keyword defining a fixed value, which cannot be changed.

```json
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


```json
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
            "title": "Hostname",
            "pattern": "^([a-zA-Z0-9-]+\.)*mydomain\.com$",
            "x-onyxia": {
                "hidden": true,
                "overwriteDefaultWith": "{{project.id}}-{{k8s.randomSubdomain}}-0.mydomain.com"
            }
        },
        "userHostname": {
            "type": "string",
            "title": "Hostname",
            "pattern": "^([a-zA-Z0-9-]+\.)*mydomain\.com$",
            "x-onyxia": {
                "hidden": true,
                "overwriteDefaultWith": "{{project.id}}-{{k8s.randomSubdomain}}-user.mydomain.com"
            }
        },
        "ingressClassName": {
            "type": "string",
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

```json
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

```json
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

This schema defines the default kubernetes role for interactive services pods.
As it is very permissive, you may want to restrict it to view-only access, using a constant.

#### Permissive schema
```json
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
#### Restrictive schema

You can also enforce a fixed role (e.g. `view`) by setting its `const` attribute.
```json
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
            "const": "view"
        }
    }
}
```


### ide/extraenv.json

This schema allows the user to define their own custom environment variables that will be available within their service.
This mechanism allows to further pre-configure the environment which saves time and prevents errors during the setup of dependencies that rely on environment variables.
It also simplifies and encourages the use of environment variables to provide execution specific parameters rather than hardcoding them in scripts.

This feature is hidden by default and can be enabled using the following schema:
```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "description": "Environment variables available within your service",
    "type": "array",
    "default": [],
    "items": {
        "type": "object",
        "properties": {
            "name": {
                "type": "string"
            },
            "value": {
                "type": "string"
            }
        }
    }
}
```
A `default` list of variables can be provided as an example for the user.

### certificates.json

This schema is used to inject certificate authority into your services.

In the following example, we enforce the use of a specific CA certificate, encoded in base64, and define the file path where the CA bundle will be injected.

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
        "cacerts": {
            "type": "string",
            "description": "String of crts concatenated in base64, can be a url",
            "const": "bXljYWNlcnRzZXhhbXBsZQo=",
            "x-onyxia": {
                 "hidden": true
            }
        },
        "pathToCaBundle": {
            "type": "string",
            "const": "/usr/local/share/ca-certificates/",
            "x-onyxia": {
                "hidden": true
            }
        }
    }
}
```

### network-policy.json

This schema defines the network access policy for a service, specifying which sources are allowed to communicate with it.

In the following example, network access is granted only to pods from a specific namespace by matching the namespace's label with `mynamespace`.

```json
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
            "const": [
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

```json
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

Because "NVIDIA-A2" is the default option, "Tesla-T4" may seldom be selected. In this scenario, it would be advisable to create a specific label with just two options: basic GPU or high GPU.

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
            "const": "http://myHttpProxy",
            "x-onyxia": {
                "hidden": true
            }
        },
        "httpsProxy": {
            "type": "string",
            "description": "Proxy URL for HTTPS requests",
            "const": "http://myHttpProxy",
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

This schema enables the Spark UI and let the user change the default spark config like disabling certificate checkings for spark metastore configuration (if used with the discovery mecanism) and specifying spark session configuration that will be stored inside of a spark-config.conf file.

By [default](https://github.com/InseeFrLab/onyxia-api/blob/main/onyxia-api/src/main/resources/schemas/spark.json), spark is configured with kubernetes as the ressource manager (master) with a dynamic configuration.

You can use a configuration with a master local for example.

```json
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
