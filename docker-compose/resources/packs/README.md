# 如何导入服务器整合包

## GENERIC_PACK: 通用包导入

> To install all the server content (jars, mods, plugins, configs, etc.) from a zip or tgz file, then set to the container path or URL of the archive file. This can also be used to apply a CurseForge modpack that is missing a server start script and/or Forge installer.
>
> 将 zip 或 tgz 归档内的全部服务器内容（jar、模组、插件、配置等）安装到容器，只需把归档文件的路径或 URL 填入即可；也可借此补全缺少启动脚本和/或 Forge 安装器的 CurseForge 整合包。
>
> —— ***[🔗Docker Minecraft Server (Java Edition) Documentation: Mods and Plugins - Generic Pack](https://docker-minecraft-server.readthedocs.io/en/latest/mods-and-plugins/#generic-pack-files)***

### 准备一个通用整合包:

对于一个通用包来说, 它可能包含这些内容:

- `config`, `plugins`, `world` 等 Minecraft 服务器的相关文件夹.
- `mods`, `kubejs`, `defaultconfigs` 等模组相关文件夹.
- `run.bat`, `run.sh` 等服务器启动脚本.
- `server.properties`, `user_jvm_args.txt`, `whitelist.json` 等服务器配置文件.

当你下载了一个服务器整合包后, 它是一个 `.zip` 或者 `.tgz` 格式的压缩包文件, 并且基本符合上述特征, 那么你可以将它作为通用包导入.

### 如何导入通用整合包:

#### 1. 确认通用包在 `.env` 文件中的配置 —— ***[💾如何配置或修改服务器](../../servers/README.md)***:

- `MC_SERVER_NAME` : 服务器名称(可选)
    

- `MC_VERSION` : Minecraft 版本 (如 `1.20.1` 等)
    

- `FORGE_VERSION` / `NEOFORGE_VERSION` / `...` : 对应的 ModLoader 版本 (如 `FORGE_VERSION=latest`, `NEOFORGE_VERSION=47.4.2` 等)
    

- `GENERIC_PACK` : 通用包文件名

>  在 `docker-compose.yml` 中:
>
> ```yml
> # docker-compose.yml: mc-server
> services:
>   mc-server:
>     environment:
>       GENERIC_PACK: ${GENERIC_PACK:+/packs/${GENERIC_PACK}}
>     volumes:
>       - ./resources/packs:/packs:ro
> ```
  
  同时, 在 `.env` 文件中设置 `GENERIC_PACK` 变量, 如 *some_server.zip*
  ```dotenv
  # ______ Package Import ______
  GENERIC_PACK=some_server.zip
  ```

当你配置了 `GENERIC_PACK` 变量后, 将通用包文件放置到 `docker-compose/resources/packs/` 目录下.

```text
[docker-compose]
 ├── [resources]
 │    ├── [packs]
 │    │    ├── some_server.zip      <-- 将通用包文件放在这里
 │    │    └── ...
 │    └── ...
 └── ...
```

> 启动 Minecraft 服务器容器 —— ***[💾如何启动 Minecraft 服务器](../../../README.md)***
> 
> Docker 会在容器内的 `/packs/` 路径下寻找对应的压缩包文件, 并将其内容导入到服务器文件夹中.