# 如何配置并启动服务器

## 一. `mc-server` 配置

### 1. `.env`

该文件配置了 `docker-compose.yml` 所需的模板变量.

当 `.env` 文件处于 `docker-compose.yml` 相同目录(或使用 `--env-file` 指定)下通过 `docker compose -f docker-compose.yml up` 命令部署 `docker-compose.yml` 的服务组时,  
形如 `${SOME_NAME}` 的变量会被替换为 `.env` 文件中定义的 `SOME_NAME` 变量内容

例如: 

```dotenv
EULA: true
VERSION: "1.20.1"
```

```yml
# docker-compose.yml
services:
  mc-server:
    environment:
      EULA: ${EULA}
      VERSION: ${MC_VERSION}
```

### 2. `docker-compose.yml` 配置 ***Minecraft server.properties***: 

该文件中提供了 ***server.properties*** 配置块:

```yml
# server.properties 配置块
x-PROPERTIES: 
  environment: &PROPERTIES_ENV
```

当你自行组建 ***Minecraft*** 服务器, 希望修改一些服务器配置时, 可以通过增加或删减此处变量配置实现.

例如你想设置 Minecraft 难度, 在线模式, 出生区块保护, 允许飞行等规则(`DIFFICULTY`, `ONLINE_MODE`, `SPAWN_PROTECTION`, `ALLOW_FLIGHT`)

```yml
x-PROPERTIES: 
  environment: &PROPERTIES_ENV
    DIFFICULTY: "hard"
    ONLINE_MODE: false
    SPAWN_PROTECTION: 0
    ALLOW_FLIGHT: true
```

这样添加后, 通过 `docker compose -f docker-compose.yml up` 启动原版服务器, 对应的服务器规则就会根据其中设置修改 `server.properties` 内容.

> 详细 `server.properties` 配置参阅:
> - ***[🔗Minecraft Server on Docker (Java Edition): Variables](https://docker-minecraft-server.readthedocs.io/en/latest/variables/)***
> - ***[🔗Minecraft Server Properties](https://minecraft.wiki/w/Server.properties)***

---

## 二. `mc-server` 的服务器路径解析

一个最简服务器文件夹结构如下:

> `[example]`: `[]` 扩起部分表示当前位置为应为文件夹.
>
> `(...)`: 表示当前文件夹还可能有其它文件或文件夹等内容.

```dotenv
# .env 文件
MC_SERVER_NAME="mc-docker"
```

```plaintext
[docker-compose]
├── [compose]
│   └── (...)
├── [servers]
│   ├── [mc-docker]         <-- 默认服务器根目录 (MC_SERVER_NAME="mc-docker")
│   │   ├── [prometheus]
│   │   ├── [grafana]
│   │   ├── [server-backups]     
│   │   └── [server]        <-- 服务器文件夹
│   │       ├── some-icon.png
│   │       └── (...)
│   └── README.md           <-- 当前在读
├── .env
├── docker-compose.forge.yml
├── docker-compose.yml
└── (...)
```
### 1. 服务器名称与路径

在 docker-compose.yml 配置中, mc-server 服务的卷映射如下:

```yml
# docker-compose.yml: mc-server
# 相对路径对于 `docker-compose.yml` 的文件目录解释.
volumes:
  - ./servers/${MC_SERVER_NAME}/server:/data
```
挂载表示将 `docker-compose` 中 `servers/${MC_SERVER_NAME}/server` 挂载至 mc-server 容器 `/data`. 这意味着, 服务器文件路径应在 `docker-compose.yml` 所在位置下的 `servers/${MC_SERVER_NAME}/server` 目录中.

如果你想要启动一个不同名称的服务器, 只需在 `.env` 文件中修改 `MC_SERVER_NAME` 变量即可, 当你修改了 `MC_SERVER_NAME` 后, Docker 会映射到对应路径的新服务器.

例如, 如果你先后部署两个服务器将 `MC_SERVER_NAME` 设置分别为 `example_name` 或者 `another_name`, 那么会储存在这样的文件结构:

```dotenv
MC_SERVER_NAME="example_name"
```

```dotenv
MC_SERVER_NAME="another_name"
```

```plaintext
[docker-compose]
├── [compose]
│   └── (...)
├── [servers]
│   ├── [example_name]      <-- 服务器根目录 (MC_SERVER_NAME="example_name")
│   │   ├── [prometheus]
│   │   ├── [grafana]
│   │   ├── [server]        <-- `example_name` 服务器文件
│   │   │   ├── some-icon.png
│   │   │   └── (...)
│   │   └── [server-backups]
│   ├── [another_name]      <-- 服务器根目录 (MC_SERVER_NAME="another_name")
│   │   ├── [prometheus]
│   │   ├── [grafana]
│   │   ├── [server]        <-- `another_name` 服务器文件
│   │   │   ├── some-icon.png
│   │   │   └── (...)
│   │   └── [server-backups]
│   └── README.md           <-- 当前在读
│
└── (...)
```

---

## 三. 导入服务器整合包

> 具体操作参阅: [🔗如何导入服务器整合包](../resources/packs/README.md)
>
> 相关概念参阅: [🔗Minecraft Server on Docker (Java Edition): Mods and Plugins](https://docker-minecraft-server.readthedocs.io/en/latest/mods-and-plugins/#zip-file-modpack)