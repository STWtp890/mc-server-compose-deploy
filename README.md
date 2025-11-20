# Minecraft 服务器单地图方案

本项目用于快速部署部分玩家共同游玩的 Minecraft Server - Java Edition, 并提供服务器的自动重启与备份,
以及服务器状态的监控与可视化功能.

> 注意: 在服务器网络环境没有固定IP的情况下, 仍需要自行使用如反向代理等网络服务提供与服务器的连接功能

## 1. 计划完成情况

- [x] ~~基于 `itzg/mc-server` 的 Minecraft 服务器最小启动~~
- [x] ~~基于 `itzg/mc-backup` 的备份与恢复~~
- [x] ~~基于 `itzg/mc-monitor` 的服务器状态监控: `collect-otel`~~
- [x] ~~基于 `otel/opentelemetry-collector-contrib` 的服务器状态数据接收~~
- [x] ~~基于 `gcr.io/cadvisor/cadvisor` 的 Docker 运行状态监控~~
- [x] ~~基于 `prom/prometheus` 的内部监控管道~~
- [x] ~~基于 `grafana/grafana` 的监控数据可视化~~
- [x] ~~预置 grafana dashboards 可视化模板~~
- [ ] 容器操作脚本(启动, 停止)

## 2. 使用方式

### 2.1. 环境

确保你已经安装并配置好 ***Docker*** 与 ***Docker Compose*** 环境.

- 适用于 Windows 与 macOS 用户: [Docker Desktop](https://www.docker.com/products/docker-desktop/)

- 适用于 Linux 用户:

    ```shell
    # 基本安装:
    curl -fsSL https://get.docker.com -o install-docker.sh
    sudo sh install-docker.sh
    ```
    ```shell
    # 国内镜像加速安装 (以阿里云为例):
    curl -fsSL https://get.docker.com -o install-docker.sh
    sudo sh install-docker.sh --mirror Aliyun # 或 AzureChinaCloud
    ```

### 2.2. 关于配置

如果你需要自定义服务器参数, 参考链接 *🔗[docker-minecraft-server:variables](https://docker-minecraft-server.readthedocs.io/en/latest/variables/)* 中关于 Server 部分的 ***参数详情***,
并尝试修改 `./docker-compose/` 文件夹下 `docker-compose.properties.yml` 配置文件内关于 `environment: &PROPERTIES_ENV` 的参数.

在启动前, 你需要确认你要启动的 MC-Server 版本, 并修改 `.env` 文件内的 `MC_VERSION` 变量.

如果你需要使用模组服务器, 或者加载现有的服务器, 请参阅 *🔗[如何启动现有服务器](./docker-compose/servers/README.md)* 中的说明进行相关操作.

### 2.3. 关于启动

在启动脚本没实现的情况下, 可先使用相关 `docker compose` 命令实现.

如果你拥有 ***Docker*** 的使用经验或者 ***Shell*** 的相关命令行使用经验, 你可以在 *Linux* 或 *Windows* 中使用 ***Shell*** 或 ***Docker Desktop*** 的命令行启动.

你需要: 
 - 将终端的路径切换到本项目的 `./docker-compose/` 文件夹下. 尝试使用终端打开该文件夹, 或终端输入 `cd {/your/path/to/project/docker-compose/}` 进行路径切换.
 - 执行以下命令:

#### 2.3.1. *启动模组 Java 服务器 (forge/neoforge/fabric):*

```shell
docker compose -f docker-compose.yml -f docker-compose.{mod_loader_type}.yml -f docker-compose.properties.yml up -d
```
其中:
- `{mod_loader_type}` 应替换为你想使用的 ***ModLoader*** 类型 (`forge`/`neoForge`/`fabric`)

#### 2.3.2. *启动原版 Java 服务器 (vanilla):*

```shell
docker compose -f docker-compose.yml -f docker-compose.properties.yml up -d
```

### 2.4. 关于端口

默认情况下, 服务器在本地网络中会暴露以下端口:

| 端口号   | 服务内容            | 说明                    |
|-------|-----------------|-----------------------|
| 25565 | Minecraft 游戏端口  | Minecraft 客户端连接服务器端口  |
| 25575 | RCON 远程控制端口     | 远程控制 Minecraft 服务器的端口 |
| 13000 | Grafana 可视化界面端口 | 访问 Grafana 监控数据的端口    |

## 3. 容器间关系

### 3.1. 容器网络

`docker-compose.yml` 文件定义了两个桥接器: `mc-network`, `mc-internal-network`.

从含义可以理解: 

- `mc-network`: 向外部暴露端口, 用于网络服务. 包括 `mc-server`, `mc-grafana` (`mc-backup`, `mc-restore-backup` 为特例).

- `mc-internal-network`: 隐藏内部的网络数据流动. 包括 `mc-server`, `mc-monitor`, `mc-cadvisor`, `mc-prometheus`, `mc-grafana`

### 3.2. 容器功能

服务功能按 `docker-compose.yml` 文件中的服务顺序介绍:

- `mc-restore-backup`: Minecraft 服务器数据恢复程序, 在首次启动时运行一次, 用于从备份数据中恢复 `mc-server` 的数据.
- `mc-server`: Minecraft 服务器主程序, 提供 Minecraft 游戏服务, 多人游戏联机端点, 与RCON服务.
- `mc-backup`: Minecraft 服务器数据备份与恢复程序, 定时对 `mc-server` 的数据进行备份, 并在需要时进行恢复.
- `mc-monitor`: Minecraft 服务器状态监控程序, 采集 `mc-server` 的运行状态数据, 并发送至 `mc-prometheus` 进行存储.
- `mc-cadvisor`: Docker 容器运行状态监控程序, 采集所有容器的运行状态数据, 并发送至 `mc-prometheus` 进行存储.
- `mc-prometheus`: 内部监控数据存储程序, 接收 `mc-monitor` 与 `mc-cadvisor` 发送的监控数据, 并存储以供 `mc-grafana` 查询.
- `mc-grafana`: 监控数据可视化程序, 提供图形化界面以展示 `mc-prometheus` 存储的监控数据.