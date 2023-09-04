# jupyter-pyspark

![Version: 1.28.2](https://img.shields.io/badge/Version-1.28.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

The JupyterLab IDE with PySpark, an interface to use Apache Spark from Python.

**Homepage:** <https://jupyter.org/>

## Source Code

* <https://github.com/InseeFrLab/images-datascience>
* <https://github.com/InseeFrLab/helm-charts-interactive-services>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://inseefrlab.github.io/helm-charts-interactive-services | library-chart | 1.4.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| coresite.configMapName | string | `""` |  |
| discovery.hive | bool | `true` |  |
| discovery.metaflow | bool | `true` |  |
| discovery.mlflow | bool | `true` |  |
| environment.group | string | `"users"` |  |
| environment.user | string | `"onyxia"` |  |
| fullnameOverride | string | `""` |  |
| git.branch | string | `""` |  |
| git.cache | string | `""` |  |
| git.configMapName | string | `""` |  |
| git.email | string | `""` |  |
| git.enabled | bool | `false` |  |
| git.name | string | `""` |  |
| git.repository | string | `""` |  |
| git.token | string | `""` |  |
| hive.configMapName | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | list | `[]` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hostname | string | `"chart-example.local"` |  |
| ingress.ingressClassName | string | `""` |  |
| ingress.tls | bool | `true` |  |
| ingress.userHostname | string | `"chart-example-user.local"` |  |
| init.personalInit | string | `""` |  |
| init.personalInitArgs | string | `""` |  |
| init.regionInit | string | `""` |  |
| init.standardInitPath | string | `"/opt/onyxia-init.sh"` |  |
| kubernetes.enabled | bool | `false` |  |
| kubernetes.role | string | `"view"` |  |
| metaflow.configMapName | string | `""` |  |
| mlflow.configMapName | string | `""` |  |
| nameOverride | string | `""` |  |
| networking.clusterIP | string | `"None"` |  |
| networking.service.port | int | `8888` |  |
| networking.sparkui.port | int | `4040` |  |
| networking.type | string | `"ClusterIP"` |  |
| networking.user.enabled | bool | `false` |  |
| networking.user.port | int | `5000` |  |
| nodeSelector | object | `{}` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.size | string | `"10Gi"` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext.fsGroup | int | `100` |  |
| replicaCount | int | `1` |  |
| repository.condaRepository | string | `""` |  |
| repository.configMapName | string | `""` |  |
| repository.mavenRepository | string | `""` |  |
| repository.pipRepository | string | `""` |  |
| resources | object | `{}` |  |
| route.annotations | list | `[]` |  |
| route.enabled | bool | `false` |  |
| route.hostname | string | `"chart-example.local"` |  |
| route.tls.termination | string | `"edge"` |  |
| route.userHostname | string | `"chart-example-user.local"` |  |
| route.wildcardPolicy | string | `"None"` |  |
| s3.accessKeyId | string | `""` |  |
| s3.configMapName | string | `""` |  |
| s3.defaultRegion | string | `""` |  |
| s3.enabled | bool | `false` |  |
| s3.endpoint | string | `""` |  |
| s3.secretAccessKey | string | `""` |  |
| s3.sessionToken | string | `""` |  |
| security.allowlist.enabled | bool | `false` |  |
| security.allowlist.ip | string | `"0.0.0.0/0"` |  |
| security.networkPolicy.enabled | bool | `false` |  |
| security.networkPolicy.from | list | `[]` |  |
| security.password | string | `"changeme"` |  |
| securityContext | object | `{}` |  |
| service.image.custom.enabled | bool | `false` |  |
| service.image.custom.version | string | `""` |  |
| service.image.pullPolicy | string | `"IfNotPresent"` |  |
| service.image.version | string | `""` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| spark.config."spark.driver.extraJavaOptions" | string | `"-Dcom.amazonaws.sdk.disableCertChecking={{ .Values.spark.disabledCertChecking }}"` |  |
| spark.config."spark.executor.extraJavaOptions" | string | `"-Dcom.amazonaws.sdk.disableCertChecking={{ .Values.spark.disabledCertChecking }}"` |  |
| spark.config."spark.kubernetes.authenticate.driver.serviceAccountName" | string | `"{{ include \"library-chart.fullname\" . }}"` |  |
| spark.config."spark.kubernetes.container.image" | string | `"{{ ternary .Values.service.image.custom.version .Values.service.image.version .Values.service.image.custom.enabled }}"` |  |
| spark.config."spark.kubernetes.driver.pod.name" | string | `"{{ include \"library-chart.fullname\" . }}-0"` |  |
| spark.config."spark.kubernetes.namespace" | string | `"{{ .Release.Namespace }}"` |  |
| spark.config."spark.master" | string | `"k8s://https://kubernetes.default.svc:443"` |  |
| spark.configMapName | string | `""` |  |
| spark.default | bool | `true` |  |
| spark.disabledCertChecking | bool | `false` |  |
| spark.sparkui | bool | `false` |  |
| spark.userConfig."spark.driver.memory" | string | `"2g"` |  |
| spark.userConfig."spark.dynamicAllocation.enabled" | string | `"true"` |  |
| spark.userConfig."spark.dynamicAllocation.executorAllocationRatio" | string | `"1"` |  |
| spark.userConfig."spark.dynamicAllocation.initialExecutors" | string | `"1"` |  |
| spark.userConfig."spark.dynamicAllocation.maxExecutors" | string | `"10"` |  |
| spark.userConfig."spark.dynamicAllocation.minExecutors" | string | `"1"` |  |
| spark.userConfig."spark.dynamicAllocation.shuffleTracking.enabled" | string | `"true"` |  |
| spark.userConfig."spark.executor.memory" | string | `"2g"` |  |
| spark.userConfig."spark.hadoop.fs.s3a.bucket.all.committer.magic.enabled" | string | `"true"` |  |
| startupProbe.failureThreshold | int | `60` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.successThreshold | int | `1` |  |
| startupProbe.timeoutSeconds | int | `5` |  |
| tolerations | list | `[]` |  |
| vault.configMapName | string | `""` |  |
| vault.directory | string | `""` |  |
| vault.enabled | bool | `false` |  |
| vault.mount | string | `""` |  |
| vault.secret | string | `""` |  |
| vault.token | string | `""` |  |
| vault.url | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
