import subprocess
import logging

from prometheus_api_client import PrometheusConnect

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')

prom = PrometheusConnect(url="http://prometheus-server.prometheus",
                         disable_ssl=True)

# Get list of pods that have been reserving a GPU for at least 24h
query_up_24h = 'count_over_time(DCGM_FI_DEV_GPU_UTIL{namespace=~".*", job!="opencost", pod=~".*"}[24h]) > 1400'
res_up_24h = prom.custom_query(query_up_24h)
pods_res_up_24h = [(svc["metric"]["pod"], svc["metric"]["namespace"])
                   for svc in res_up_24h if "pod" in svc["metric"]]

# Get list of pods for which there is no sign of GPU activity in the last 24h
query_no_usage_24h = 'sum_over_time(DCGM_FI_DEV_GPU_UTIL{namespace=~".*", job!="opencost", pod=~".*"}[24h]) == 0'
no_usage_24h = prom.custom_query(query_no_usage_24h)
pods_no_usage_24h = [(svc["metric"]["pod"], svc["metric"]["namespace"])
                     for svc in no_usage_24h if "pod" in svc["metric"]]

# Kill helm releases that match the two criterions
pods_to_kill = list(set(pods_res_up_24h) & set(pods_no_usage_24h))
releases_to_kill = [(rel[0].split("-0")[0], rel[1]) for rel in pods_to_kill if "-gpu" in rel[0]]
cmds = [f"helm delete {rel[0]} --namespace={rel[1]}"
        for rel in releases_to_kill]
for cmd in cmds:
    logging.info(f"Launching command : {cmd}")
    subprocess.run(cmd.split(" "))
