# Telegraf

## Focus

Configurazione ed installazione di Telegraf per inviare a InfluxDB le metriche istantanee di sistema ed eventi acquisiti da Event Viewer. Configurare in Kapacitor una query che al verificarsi di uno scenario trigger esegua uno script PowerShell che notifica l'evento

## Script steps

Sure, I can help you visualize that setup! Here's a schematic representation of the system you described:

1. **PowerShell Script**:
   - **Function**: Sends metrics to an InfluxDB host using the Line Protocol.
   - **Method**: Uses `Invoke-RestMethod` to send HTTP requests.

2. **Telegraf**:
   - **Function**: Collects system metrics (CPU, RAM, Network throughput) from a Windows Server 2016.
   - **Output**: Sends these metrics to InfluxDB.

3. **Kapacitor**:
   - **Function**: Monitors the metrics in InfluxDB.
   - **TICKscript**: Defines the logic for triggering alerts.
   - **Alert Action**: Calls a PowerShell script using `.exec()` when a `.crit()` alert is triggered.

Here's a simplified schematic diagram:

```
                                       +-------------------+       +-------------------+
                                       |                   |       |                   |
                                       | PowerShell Script |       |   Windows Server  |
         +------------------------+    |                   |       |                   |
         |                        |    +--------+----------+       +---------+---------+
         |        Kapacitor       |             |                            |          
         |                        |             |                            |          
         |-------------------+    |             v                            v          
         |                   |    |    +-------------------+       +-------------------+
 Notify  |    TICKscript     |    |    |                   |       |      Telegraf     |
<--------|    (Alert Logic)  |    |----|    InfluxDB       |<------|  System Metrics   |
         |                   |    |    |                   |       |  (CPU, RAM, etc.) |
         +-------------------+----+    +-------------------+       +-------------------+
```

### Detailed Steps:

1. **PowerShell Script**:

```powershell
   $uri = "http://<docker_host_ip>:8086/api/v2/write?org=‹Org›&bucket=‹Bucket›&precision=ms"
   $body = "measurement,host=server01,region=us-west value=0.64 "
   Invoke-RestMethod -Uri $uri -Method Post -Body $body
```

2. **Telegraf Configuration**:

```shell
# Generate Telegraf configuration file
& .\telegraf.exe `
--input-filter cpu:http `
--output-filter influxdb_v2:file `
config > telegraf.conf
# Start Telegraf with the generated configuration file
.\telegraf.exe --service install `
--config "‹PathTo›\telegraf.conf"
```

```toml
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false

[[inputs.mem]]

[[outputs.influxdb_v2]]
  urls = ["http://<docker_host_ip>:8086"]
  token = "your-influxdb-token"
  organization = "your-org"
  bucket = "your-bucket"

```

```powershell
& docker run -d --name=influxdb `
  -p 8086:8086 `
  -v /path/to/influxdb/data:/var/lib/influxdb2 `
  influxdb:2.0

# to config influxdb browse http://localhost:8086
```

3. **Kapacitor TICKscript**:

```tick
   stream
       |from()
           .measurement('cpu')
       |alert()
           .crit(lambda: "usage_idle" < 10)
           .exec('/path/to/powershell_script.ps1')
   ```

This setup ensures that your system metrics are continuously monitored and any critical alerts trigger a PowerShell script to handle the situation. If you need further customization or have any questions, feel free to ask!

## Riferimenti

- [GitHub - markwragg/PowerShell-Influx: A PowerShell module for interacting with the time-series database platform Influx: https://www.influxdata.com/](https://github.com/markwragg/PowerShell-Influx)
- [Install Telegraf as Windows Service@Telegraf documentation](https://docs.influxdata.com/telegraf/v1/install/?t=Windows)
- [InfluxData Downloads](https://www.influxdata.com/downloads/?_gl=1*1byulxg*_ga*MjQ0NjM5MDA2LjE3MjcyNjk1MzI.*_ga_CNWQ54SDD8*MTcyNzI3ODIzNy4yLjEuMTcyNzI3OTg2Ny4xMi4wLjE1MDU4NzY1MzM.*_gcl_au*NzkwNDg1NDQ1LjE3MjcyNjk1NTk.)
- [Kapacitor@Influxdata documentation](https://docs.influxdata.com/kapacitor/v1/introduction/)
- 