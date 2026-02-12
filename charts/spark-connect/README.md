# spark-connect

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Spark Connect server on EMR on EKS with dynamic K8s executor scaling

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://inseefrlab.github.io/helm-charts-interactive-services | library-chart | 1.7.14 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` |  |
| global.suspend | bool | `false` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.certManagerClusterIssuer | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hostname | string | `""` |  |
| ingress.ingressClassName | string | `""` |  |
| ingress.sparkHostname | string | `""` |  |
| ingress.tls | bool | `true` |  |
| ingress.tlsSecretName | string | `""` |  |
| ingress.useCertManager | bool | `false` |  |
| ingress.useTlsSecret | bool | `false` |  |
| kubernetes.enabled | bool | `true` |  |
| kubernetes.role | string | `"edit"` |  |
| networking.service.port | int | `15002` |  |
| networking.sparkui.port | int | `4040` |  |
| networking.type | string | `"ClusterIP"` |  |
| nodeSelector.workload-type | string | `"spark"` |  |
| resources.limits.cpu | string | `"2"` |  |
| resources.limits.memory | string | `"12Gi"` |  |
| resources.requests.cpu | string | `"2"` |  |
| resources.requests.memory | string | `"10Gi"` |  |
| route.enabled | bool | `false` |  |
| route.hostname | string | `""` |  |
| route.sparkHostname | string | `""` |  |
| security.networkPolicy.enabled | bool | `false` |  |
| security.networkPolicy.from | list | `[]` |  |
| service.image.custom.enabled | bool | `false` |  |
| service.image.custom.version | string | `"142496269814.dkr.ecr.us-west-2.amazonaws.com/emr-on-eks/spark:emr-7.1.0"` |  |
| service.image.pullPolicy | string | `"IfNotPresent"` |  |
| service.image.version | string | `"142496269814.dkr.ecr.us-west-2.amazonaws.com/emr-on-eks/spark:emr-7.1.0"` |  |
| serviceAccount.annotations."eks.amazonaws.com/role-arn" | string | `"arn:aws:iam::142496269814:role/emr-job-execution-role"` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| spark.config."spark.connect.grpc.binding.port" | string | `"15002"` |  |
| spark.config."spark.connect.grpc.maxInboundMessageSize" | string | `"134217728"` |  |
| spark.config."spark.driver.maxResultSize" | string | `"5g"` |  |
| spark.config."spark.hadoop.fs.s3a.aws.credentials.provider" | string | `"com.amazonaws.auth.WebIdentityTokenCredentialsProvider"` |  |
| spark.config."spark.hadoop.fs.s3a.block.size" | string | `"256m"` |  |
| spark.config."spark.hadoop.fs.s3a.committer.magic.enabled" | string | `"true"` |  |
| spark.config."spark.hadoop.fs.s3a.committer.name" | string | `"magic"` |  |
| spark.config."spark.hadoop.fs.s3a.endpoint" | string | `"s3.us-west-2.amazonaws.com"` |  |
| spark.config."spark.hadoop.fs.s3a.endpoint.region" | string | `"us-west-2"` |  |
| spark.config."spark.hadoop.fs.s3a.fast.upload" | string | `"true"` |  |
| spark.config."spark.hadoop.fs.s3a.fast.upload.active.blocks" | string | `"32"` |  |
| spark.config."spark.hadoop.fs.s3a.fast.upload.default" | string | `"true"` |  |
| spark.config."spark.hadoop.fs.s3a.impl" | string | `"org.apache.hadoop.fs.s3a.S3AFileSystem"` |  |
| spark.config."spark.hadoop.fs.s3a.multipart.size" | string | `"268435456"` |  |
| spark.config."spark.hadoop.fs.s3a.multipart.threshold" | string | `"104857600"` |  |
| spark.config."spark.hadoop.mapreduce.outputcommitter.factory.scheme.s3a" | string | `"org.apache.hadoop.fs.s3a.commit.S3ACommitterFactory"` |  |
| spark.config."spark.hadoop.parquet.enable.summary-metadata" | string | `"false"` |  |
| spark.config."spark.kubernetes.authenticate.driver.serviceAccountName" | string | `"{{ include \"library-chart.fullname\" . }}"` |  |
| spark.config."spark.kubernetes.container.image" | string | `"{{ ternary .Values.service.image.custom.version .Values.service.image.version .Values.service.image.custom.enabled }}"` |  |
| spark.config."spark.kubernetes.executor.node.selector.workload-type" | string | `"spark"` |  |
| spark.config."spark.kubernetes.namespace" | string | `"{{ .Release.Namespace }}"` |  |
| spark.config."spark.master" | string | `"k8s://https://kubernetes.default.svc"` |  |
| spark.config."spark.network.timeout" | string | `"1000s"` |  |
| spark.config."spark.scheduler.mode" | string | `"FAIR"` |  |
| spark.config."spark.serializer" | string | `"org.apache.spark.serializer.KryoSerializer"` |  |
| spark.config."spark.sql.adaptive.coalescePartitions.enabled" | string | `"true"` |  |
| spark.config."spark.sql.adaptive.enabled" | string | `"true"` |  |
| spark.config."spark.sql.execution.arrow.pyspark.enabled" | string | `"false"` |  |
| spark.config."spark.sql.hive.metastorePartitionPruning" | string | `"true"` |  |
| spark.config."spark.sql.parquet.enableVectorizedReader" | string | `"false"` |  |
| spark.config."spark.sql.parquet.filterPushdown" | string | `"true"` |  |
| spark.config."spark.sql.parquet.mergeSchema" | string | `"false"` |  |
| spark.config."spark.sql.parquet.output.committer.class" | string | `"org.apache.spark.internal.io.cloud.BindingParquetOutputCommitter"` |  |
| spark.config."spark.sql.sources.commitProtocolClass" | string | `"org.apache.spark.internal.io.cloud.PathOutputCommitProtocol"` |  |
| spark.default | bool | `true` |  |
| spark.hostname | string | `""` |  |
| spark.secretName | string | `""` |  |
| spark.sparkui | bool | `true` |  |
| spark.userConfig."spark.driver.memory" | string | `"10g"` |  |
| spark.userConfig."spark.dynamicAllocation.enabled" | string | `"true"` |  |
| spark.userConfig."spark.dynamicAllocation.executorIdleTimeout" | string | `"120s"` |  |
| spark.userConfig."spark.dynamicAllocation.initialExecutors" | string | `"1"` |  |
| spark.userConfig."spark.dynamicAllocation.maxExecutors" | string | `"10"` |  |
| spark.userConfig."spark.dynamicAllocation.minExecutors" | string | `"0"` |  |
| spark.userConfig."spark.dynamicAllocation.shuffleTracking.enabled" | string | `"true"` |  |
| spark.userConfig."spark.executor.memory" | string | `"4g"` |  |
| spark.userConfig."spark.executor.memoryOverhead" | string | `"1g"` |  |
| spark.userConfig."spark.kubernetes.executor.limit.cores" | string | `"2"` |  |
| spark.userConfig."spark.kubernetes.executor.request.cores" | string | `"2"` |  |
| sparkConnect.emrInternalId | string | `"spark-connect-server"` |  |
| sparkConnect.env[0].name | string | `"AIS_S3PATH"` |  |
| sparkConnect.env[0].value | string | `"s3a://ais-data-142496269814/exact-earth-data/transformed/prod/"` |  |
| sparkConnect.env[1].name | string | `"USER_TEMP_S3PATH"` |  |
| sparkConnect.env[1].value | string | `"s3a://ais-data-142496269814/user_temp/"` |  |
| sparkConnect.env[2].name | string | `"SHIP_REGISTER_LATEST_S3PATH"` |  |
| sparkConnect.env[2].value | string | `"s3a://ais-data-142496269814/register/"` |  |
| sparkConnect.packages | string | `"org.apache.spark:spark-connect_2.12:3.5.0"` |  |
| startupProbe.failureThreshold | int | `30` |  |
| startupProbe.initialDelaySeconds | int | `10` |  |
| startupProbe.periodSeconds | int | `10` |  |
| startupProbe.successThreshold | int | `1` |  |
| startupProbe.timeoutSeconds | int | `5` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
