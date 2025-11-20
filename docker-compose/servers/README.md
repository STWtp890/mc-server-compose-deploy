# 如何启动现有服务器

## 1. mc-server的路径解析

在 docker-compose.yml 配置中, mc-server 服务的卷映射如下:

```yml
# docker-compose.yml
# mc-server 服务
volumes:
  - ./servers/${SERVER_NAME}/server:/data
```

其中 `${SERVER_NAME}` 是在 `.env` 文件中设置的环境变量, 用于指定不同的服务器名称, 同时也决定了服务器数据存储的路径.

同时, 相对路径是参考于 `docker-compose.yml` 文件所在的目录解释的.

这意味着, 服务器的文件路径应在 `docker-compose.yml` 相同目录下, 并处于 `servers/${SERVER_NAME}/server` 目录中.

## 2. 修改服务器名称

如果你想要启动一个不同名称的服务器, 只需在 `.env` 文件中修改 `SERVER_NAME` 变量即可:

```dotenv
# .env 文件
SERVER_NAME="mc-docker"
```

当你修改了 `SERVER_NAME` 后, Docker 会映射到对应路径的新服务器.

例如, 如果你将 `SERVER_NAME` 设置为 `example_server_name` 或者 `another_server_name`, 那么服务器数据会储存在这样的文件结构:

```plaintext
# 目录结构示例
/docker-compose
├── /compose
├── /servers
│   ├── /example_server_name    <-- 这里是新的服务器名称
│   │   ├── /prometheus
│   │   ├── /grafana
│   │   ├── /server     <-- 这里存放服务器文件
│   │   └── /server-backups
│   └── /another_server_name    <-- 这里是新的服务器名称
│       ├── /prometheus
│       ├── /grafana
│       ├── /server     <-- 这里存放服务器文件
│       └── /server-backups
├── /.env
├── /docker-compose.yml
└── /docker-compose.properties.yml
```

> 如果你不想或懒得修改服务器名称, 确认好 `.env` 文件中的版本配置正确后, 直接覆盖至服务器根目录下的 `server` 文件夹也可以.

## 3. 使用现有服务器

如果你已经有一个现有的 Minecraft 服务器, 并且想要使用这个 Docker 配置来启动它, 参考以下步骤操作:

1. 准备好你的现有服务器文件夹, 确保它包含所有必要的 Minecraft 服务器文件.

2. 确认现有服务器的版本, 并修改 `.env` 文件中的 `MC_VERSION` 变量以匹配你的服务器版本.

3. 将现有服务器文件夹复制或移动到 `docker-compose/servers/${SERVER_NAME}/server` 目录下. 其中 `${SERVER_NAME}` 是你在 `.env` 文件中设置的服务器名称.

4. 启动 Docker 容器