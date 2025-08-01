# rstudio

![Version: 2.3.12](https://img.shields.io/badge/Version-2.3.12-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

The RStudio IDE with a collection of standard data science packages.

**Homepage:** <https://www.rstudio.com/>

## Source Code

* <https://github.com/InseeFrLab/images-datascience>
* <https://github.com/InseeFrLab/helm-charts-interactive-services>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://inseefrlab.github.io/helm-charts-interactive-services | library-chart | 1.7.12 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| discovery.postgresql | bool | `true` |  |
| environment.group | string | `"users"` |  |
| environment.user | string | `"onyxia"` |  |
| extraEnvVars | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| git.branch | string | `""` |  |
| git.cache | string | `""` |  |
| git.email | string | `""` |  |
| git.enabled | bool | `false` |  |
| git.name | string | `""` |  |
| git.repository | string | `""` |  |
| git.secretName | string | `""` |  |
| git.token | string | `""` |  |
| global.suspend | bool | `false` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | list | `[]` |  |
| ingress.certManagerClusterIssuer | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hostname | string | `"chart-example.local"` |  |
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
| kubernetes.enabled | bool | `true` |  |
| kubernetes.role | string | `"view"` |  |
| message.en | string | `""` |  |
| message.fr | string | `""` |  |
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
| persistence.enabled | bool | `true` |  |
| persistence.size | string | `"10Gi"` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `100` |  |
| postgresql.secretName | string | `""` |  |
| proxy.enabled | bool | `false` |  |
| proxy.httpProxy | string | `""` |  |
| proxy.httpsProxy | string | `""` |  |
| proxy.noProxy | string | `""` |  |
| replicaCount | int | `1` |  |
| repository.configMapName | string | `""` |  |
| repository.packageManagerUrl | string | `""` |  |
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
| service.image.custom.version | string | `"inseefrlab/onyxia-rstudio:r4.5.0"` |  |
| service.image.pullPolicy | string | `"IfNotPresent"` |  |
| service.image.version | string | `"inseefrlab/onyxia-rstudio:r4.5.0"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `60` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.successThreshold | int | `1` |  |
| startupProbe.timeoutSeconds | int | `2` |  |
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
