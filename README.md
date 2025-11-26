# Minecraft 服务器单地图方案

本项目通过 docker 的容器化技术快速部署玩家共同游玩的 Minecraft Server (Java Edition).

通过此项目部署 Minecraft 服务器能得到:

- `自动重启`:
服务器进程意外中断的自动重启.


- `自动备份与恢复`:
可配置的 CRON 表达式自定义备份频率.


- `监控与可视化`:
导出 MC 服务器状态指标, 并提供web监控.


- `可配置反向代理`:
允许自定义反向代理服务器.


---

## 1. 计划完成情况

- ✅ ~~基于 `itzg/mc-server` 的 Minecraft 服务器最小启动~~

- ✅ ~~基于 `itzg/mc-backup` 的备份与恢复~~

- ✅ ~~基于 `itzg/mc-monitor` 的服务器状态监控: `collect-otel`~~

- ✅ ~~基于 `otel/opentelemetry-collector-contrib` 的服务器状态数据接收~~

- ✅ ~~基于 `gcr.io/cadvisor/cadvisor` 的 Docker 运行状态监控~~

- ✅ ~~基于 `prom/prometheus` 的内部监控管道~~

- ✅ ~~基于 `grafana/grafana` 的监控数据可视化~~

- ✅ ~~预置 grafana dashboards 可视化模板~~

- ✅ ~~基于 `snowdreamtech/frpc` 的自定义反向代理客户端(FRP Client)~~

- ⬜ 实现通过 GenericPack 与 ModPack 导入整合包或模组包

---

## 2. 使用方式

### 2.1. 环境

确保你已经安装并配置好 ***Docker*** 与 ***Docker Compose*** 环境.

- 适用于 Windows 与 macOS 用户: ***[🔗Docker Desktop](https://www.docker.com/products/docker-desktop/)***

- Linux 用户参考:

  ```shell
  curl -fsSL https://get.docker.com -o install-docker.sh
  sudo sh install-docker.sh
  ```
  ```shell
  sudo systemctl start docker
  sudo systemctl enable docker
  ```

### 2.2. 关于配置文件

1. ENV 文件: `.env` 文件内包含了本项目 ***必要的变量配置***. 
  
    - `MC_VERSION`: 在启动前, 你至少需要确认你要启动的 mc-server 版本, 并修改 `.env` 文件内的 `MC_VERSION` 变量.

2. Server Properties: 在`docker-compose.yml` 的 `environment: &PROPERTIES_ENV` 部分中, 可以配置 `server.properties` 的服务器参数 

    - `server.properties`: 如果你需要自定义服务器参数, 参考链接 ***[🔗docker-minecraft-server.readthedocs.io](https://docker-minecraft-server.readthedocs.io/en/latest/variables/)*** 中关于 Server 部分的 ***参数详情(Variables)***, 并尝试修改  `docker-compose.yml` 的参数.  

    - `Mod Loader`: 如果你需要使用模组服务器, 或者加载现有的服务器, 请参阅 ***[🔗如何启动现有服务器](./docker-compose/servers/README.md)*** 中的说明进行相关操作.

### 2.3. 关于启动

使用相关 `docker compose` 命令实现.

`docker-compose.yml` 等文件位于 `./docker-compose` 下, 这意味着你需要将终端的路径切换到本项目的 `./docker-compose` 文件夹. 例如使用 `cd` 命令, 或通过终端直接打开该路径.

1. *启动原版 Java 服务器 (vanilla):*
    在 `./docker-compose` 文件夹下执行以下命令:
    ```shell
    docker compose -f docker-compose.yml -f docker-compose.properties.yml up -d
    ```

2. *启动模组 Java 服务器 (forge/neoforge/fabric):*
    在 `./docker-compose` 文件夹下执行以下命令:
    ```shell
    docker compose -f docker-compose.yml -f docker-compose.{mod_loader_type}.yml -f docker-compose.properties.yml up -d
    ```
    其中:
    - `{mod_loader_type}` 应替换为你想使用的 ***ModLoader*** 类型 (`forge`/`neoForge`/`fabric`)

3. *启动带有 FRP Client 的服务器:*
    在 `./docker-compose` 文件夹下执行以下命令:
    ```shell
    docker compose -f docker-compose.yml -f docker-compose.properties.yml -f docker-compose.frpc.yml up -d
    ```

参数总览:
- `-f docker-compose.yml`: 启动必选
- `-f docker-compose.properties.yml`: 启动必选
- `-f docker-compose.{mod_loader_type}.yml`: 模组服务器配置可选
- `-f docker-compose.frpc.yml`: 自行内网穿透可选

---

## 3. 容器间关系

### 3.1. 关于端口

在使用如 ***SakuraFRP***, ***花生壳***, ***Astral*** , 自建云服务器或者其它提供联机的类似网络服务时, 可以使用的端口如下.

默认情况下, 服务器在本地网络中会暴露以下端口:

| 端口号   | 服务内容            | 说明                        |
|-------|-----------------|---------------------------|
| 25565 | Minecraft 游戏端口  | Minecraft 客户端连接服务器端口      |
| 25575 | RCON 远程控制端口     | 远程控制 Minecraft 服务器的端口     |
| 13000 | Grafana 可视化界面端口 | 访问 Grafana 监控数据的端口        |
| 16000 | FRP Client 远程端口 | FRP Server 监听端口(如果启动FRPC) |


### 3.2. 容器网络

`docker-compose.yml` 文件定义了两个桥接器: `mc-network`, `mc-internal-network`.

- `mc-network`: 向外部暴露端口, 用于网络服务. 包括 `mc-server`, `mc-grafana`. `mc-frpc`.

- `mc-internal-network`: 隐藏内部的网络数据流动. 包括 `mc-server`, `mc-monitor`, `mc-cadvisor`, `mc-prometheus`, `mc-grafana`

### 3.3. 容器功能

服务功能按 `docker-compose.yml` 文件中的服务顺序介绍:

- `mc-restore-backup`: Minecraft 服务器数据恢复程序, 在首次启动时运行一次, 用于从备份数据中恢复 `mc-server` 的数据.
- `mc-server`: Minecraft 服务器主程序, 提供 Minecraft 游戏服务, 多人游戏联机端点, 与RCON服务.
- `mc-backup`: Minecraft 服务器数据备份与恢复程序, 定时对 `mc-server` 的数据进行备份, 并在需要时进行恢复.
- `mc-monitor`: Minecraft 服务器状态监控程序, 采集 `mc-server` 的运行状态数据, 并发送至 `mc-prometheus` 进行存储.
- `mc-cadvisor`: Docker 容器运行状态监控程序, 采集所有容器的运行状态数据, 并发送至 `mc-prometheus` 进行存储.
- `mc-prometheus`: 内部监控数据存储程序, 接收 `mc-monitor` 与 `mc-cadvisor` 发送的监控数据, 并存储以供 `mc-grafana` 查询.
- `mc-grafana`: 监控数据可视化程序, 提供图形化界面以展示 `mc-prometheus` 存储的监控数据.

额外功能: 
- `mc-frpc`: FRP Client 程序, 用于将 Minecraft 服务器的端口映射至公网, 以便外部玩家连接. 需在有公网设备配置好 FRP Server 服务端程序.