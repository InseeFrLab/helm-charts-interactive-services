# eostat-rstudio

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

RStudio environment for Earth Observation Statistics with R and geospatial libraries

**Homepage:** <https://fao-eostat.github.io/UN-Handbook/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| UN Global Platform | <lovells@un.org> |  |

## Source Code

* <https://github.com/UNGlobalPlatform/images-datascience>
* <https://github.com/UNGlobalPlatform/helm-charts-interactive-services>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://inseefrlab.github.io/helm-charts-interactive-services | library-chart | 1.7.14 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| certificates | object | `{}` |  |
| chapter.name | string | `"ct_chile"` |  |
| chapter.repository | string | `"https://github.com/FAO-EOSTAT/UN-Handbook.git"` |  |
| chapter.storageSize | string | `"20Gi"` |  |
| chapter.version | string | `"main"` |  |
| chromadb.secretName | string | `""` |  |
| coresite.secretName | string | `""` |  |
| discovery.chromadb | bool | `true` |  |
| discovery.hive | bool | `true` |  |
| discovery.metaflow | bool | `true` |  |
| discovery.milvus | bool | `true` |  |
| discovery.mlflow | bool | `true` |  |
| discovery.postgresql | bool | `true` |  |
| environment.group | string | `"users"` |  |
| environment.user | string | `"onyxia"` |  |
| extraEnvVars | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| git.branch | string | `"main"` |  |
| git.cache | string | `""` |  |
| git.email | string | `"handbook@un.org"` |  |
| git.enabled | bool | `true` |  |
| git.name | string | `"UN Handbook User"` |  |
| git.repository | string | `"https://github.com/FAO-EOSTAT/UN-Handbook.git"` |  |
| git.secretName | string | `""` |  |
| git.token | string | `""` |  |
| global.suspend | bool | `false` |  |
| hive.secretName | string | `""` |  |
| imageFlavor | string | `"base"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | list | `[]` |  |
| ingress.certManagerClusterIssuer | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hostname | string | `"chart-example.local"` |  |
| ingress.ingressClassName | string | `""` |  |
| ingress.path | string | `"/"` |  |
| ingress.tls | bool | `true` |  |
| ingress.tlsSecretName | string | `""` |  |
| ingress.useCertManager | bool | `false` |  |
| ingress.useTlsSecret | bool | `false` |  |
| ingress.userHostname | string | `"chart-example-user.local"` |  |
| ingress.userPath | string | `"/"` |  |
| init.personalInit | string | `""` |  |
| init.personalInitArgs | string | `""` |  |
| init.regionInit | string | `""` |  |
| init.standardInitPath | string | `"/opt/onyxia-init.sh"` |  |
| kubernetes.enabled | bool | `false` |  |
| kubernetes.role | string | `"view"` |  |
| message.en | string | `""` |  |
| message.fr | string | `""` |  |
| metaflow.secretName | string | `""` |  |
| milvus.secretName | string | `""` |  |
| mlflow.secretName | string | `""` |  |
| nameOverride | string | `""` |  |
| networking.clusterIP | string | `"None"` |  |
| networking.service.port | int | `8787` |  |
| networking.sparkui.port | int | `4040` |  |
| networking.type | string | `"ClusterIP"` |  |
| networking.user.enabled | bool | `false` |  |
| networking.user.port | int | `5000` |  |
| networking.user.ports | list | `[]` |  |
| nodeSelector | object | `{}` |  |
| openshiftSCC.enabled | bool | `false` |  |
| openshiftSCC.scc | string | `""` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.size | string | `"20Gi"` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `100` |  |
| postgresql.secretName | string | `""` |  |
| proxy.enabled | bool | `false` |  |
| proxy.httpProxy | string | `""` |  |
| proxy.httpsProxy | string | `""` |  |
| proxy.noProxy | string | `""` |  |
| replicaCount | int | `1` |  |
| repository.configMapName | string | `""` |  |
| repository.rRepository | string | `""` |  |
| resources | object | `{}` |  |
| route.annotations | list | `[]` |  |
| route.enabled | bool | `false` |  |
| route.hostname | string | `"chart-example.local"` |  |
| route.tls.termination | string | `"edge"` |  |
| route.userHostname | string | `"chart-example-user.local"` |  |
| route.wildcardPolicy | string | `"None"` |  |
| s3.accessKeyId | string | `""` |  |
| s3.defaultRegion | string | `""` |  |
| s3.enabled | bool | `false` |  |
| s3.endpoint | string | `""` |  |
| s3.pathStyleAccess | bool | `false` |  |
| s3.secretAccessKey | string | `""` |  |
| s3.secretName | string | `""` |  |
| s3.sessionToken | string | `""` |  |
| s3.workingDirectoryPath | string | `""` |  |
| security.allowlist.enabled | bool | `false` |  |
| security.allowlist.ip | string | `"0.0.0.0/0"` |  |
| security.networkPolicy.enabled | bool | `false` |  |
| security.networkPolicy.from | list | `[]` |  |
| security.password | string | `"changeme"` |  |
| securityContext | object | `{}` |  |
| service.image.custom.enabled | bool | `false` |  |
| service.image.custom.version | string | `"142496269814.dkr.ecr.us-west-2.amazonaws.com/eostat-rstudio:0.1.0"` |  |
| service.image.pullPolicy | string | `"IfNotPresent"` |  |
| service.image.version | string | `"142496269814.dkr.ecr.us-west-2.amazonaws.com/eostat-rstudio:0.1.0"` |  |
| service.initContainer.image | string | `"inseefrlab/onyxia-base:latest"` |  |
| service.initContainer.pullPolicy | string | `"IfNotPresent"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `60` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.successThreshold | int | `1` |  |
| startupProbe.timeoutSeconds | int | `2` |  |
| tier | string | `"medium"` |  |
| tolerations | list | `[]` |  |
| userPreferences.darkMode | bool | `false` |  |
| userPreferences.language | string | `"en"` |  |
| vault.directory | string | `""` |  |
| vault.enabled | bool | `false` |  |
| vault.mount | string | `""` |  |
| vault.secret | string | `""` |  |
| vault.secretName | string | `""` |  |
| vault.token | string | `""` |  |
| vault.url | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
