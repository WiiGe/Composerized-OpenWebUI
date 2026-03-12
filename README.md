# Composerized-OpenWebUI - Open Web UI 私有化通用部署方案

> **English README**: [English README](./README-en.md)

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/openwebui/open-webui)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Qdrant](https://img.shields.io/badge/Qdrant-Latest-blue)](https://qdrant.tech/)
[![vLLM](https://img.shields.io/badge/vLLM-High--Performance-orange)](https://docs.vllm.ai/)

本项目提供基于 Docker Compose 的 Open Web UI 私有部署方案, 采用模块化架构, 包含完整的生产级组件.

## 项目介绍

[原项目](https://github.com/danielrosehill/OpenWebUI-Postgres-Qdrant) 采用了 `OPQ Stack` 的称呼, 因此本项目沿用该规律, 使用 `PORT-PUMQTV` (/pɔːrt/ /ˈpʌŋktɪv/, 读音接近 "port punktive", 为了硬凹这名称抠了很久头) 称呼这套容器栈:

| 字母 | 组件 | 说明 |
|------|------|------|
| **P** | [PostgreSQL](https://www.postgresql.org/) | 主数据库, 替换 SQLite |
| **O** | [Open Web UI](https://github.com/open-webui/open-webui) | 主容器, 提供 Web 界面 |
| **R** | [Valkey](https://github.com/valkey-io/valkey) | Redis 社区实现, 用于缓存和 WebSocket 支持 |
| **T** | [Apache Tika](https://github.com/apache/tika) | 文档提取器 |
| **P** | [Playwright](https://github.com/microsoft/playwright) | 无头浏览器, 用于网页访问 |
| **U** | [Unstructured](https://github.com/Unstructured-IO/unstructured) | OpenWebUI 内置, 标出来是为了给项目名称凑个元音字母 |
| **M** | [MCPO](https://github.com/open-webui/mcpo) | 官方 MCP 桥接器, 将 MCP 服务器转换为 OpenAI 兼容 API |
| **Q** | [Qdrant](https://github.com/qdrant/qdrant) | 向量数据库, 用于 RAG |
| **T** | [Open Terminal](https://github.com/open-webui/open-terminal) | 官方终端组件 |
| **V** | [vLLM](https://github.com/vllm-project/vllm) | 高性能 LLM 后端(可选) |

> **提示**: vLLM 为可选服务, 如不需要可禁用. 如需替换其他组件, 可自由组合:
>
> - LLM本地后端: 可使用 [Ollama](https://ollama.com/) 或 [SGLang](https://github.com/sgl-project/sglang) 或 [llama.cpp](https://github.com/ggml-org/llama.cpp) 来替代 vLLM
> - 文档提取: 可使用 [MinerU](https://github.com/opendatalab/MinerU) 或 [docling](https://github.com/docling-project/docling) 替代 Tika
> - 浏览器工具: 可使用 [playwright-MCP](https://github.com/microsoft/playwright-mcp) 或 [browserless](https://github.com/browserless/browserless) 或 [HeadlessBrowsers 列表](https://github.com/dhamaniasad/HeadlessBrowsers) 中的组件替代 Playwright

## 前置要求

- Docker Engine 24.0+
- Docker Compose v2.20+
- NVIDIA GPU + Driver 535+(仅使用 vLLM 时需要)

## 可选服务

以下服务为**可选**, 可根据需求禁用或替换:

| 服务 | 用途 | 禁用方式 |
|------|------|----------|
| vLLM | 本地 LLM 推理 | 注释 `docker-compose.yml` 中的 vllm 服务 |
| MCPO | MCP 工具桥接 | 注释 `mcpo` 服务 |
| Playwright | 网页访问工具 | 注释 `playwright` 服务 |
| Open Terminal | 终端访问 | 注释 `open-terminal` 服务 |
| Tika | 文档提取 | 注释 `tika` 服务 |

## TL;DR

### 1. 创建 Docker 网络

在 `.env` 文件中设置 `DOCKER_NETWORK`(默认值为 `example_network`), 然后创建网络 (以默认值为例):

```bash
docker network create example_network
```

### 2. 配置环境变量

复制 `.env.example` 为 `.env` 并根据实际情况修改:

```bash
cp .env.example .env
vim .env
```

### 3. 启动服务

```bash
docker-compose up -d
```

### 4. 访问 Open Web UI

服务启动后, 访问 `http://<您的服务器IP>:8080`(或你在 `.env` 中配置的端口).

---

## 详细配置

### 环境变量说明

#### Docker 网络配置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `DOCKER_NETWORK` | Docker 网络名称 | `example_network` |

#### OpenWebUI 配置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `OPENWEBUI_PORT` | 外部访问端口 | `8080` |
| `OPENWEBUI_SECRET_KEY` | 会话密钥(必填) | - |
| `OPENWEBUI_IP` | 服务器 IP | `192.168.8.8` |
| `OPENWEBUI_DATA_PATH` | 数据存储路径 | `/mnt/openwebui` |
| `OPENWEBUI_NLTK_PATH` | NLTK 数据路径 | `/mnt/NLTK` |

#### PostgreSQL 配置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `POSTGRES_USER` | 用户名 | `postgres` |
| `POSTGRES_PASSWORD` | 密码(必填) | - |
| `POSTGRES_DB` | 数据库名 | `postgres` |
| `POSTGRES_DATA_PATH` | 数据存储路径 | `/mnt/postgres` |

#### Qdrant 配置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `QDRANT_API_KEY` | API 密钥(必填) | - |
| `QDRANT_DATA_PATH` | 数据存储路径 | `/mnt/qdrant` |

#### Valkey 配置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `VALKEY_PASSWORD` | 密码(必填) | - |
| `VALKEY_DATA_PATH` | 数据存储路径 | `/mnt/valkey` |

#### vLLM 配置

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `VLLM_IMAGE` | 镜像地址 | `vllm/vllm-openai:latest` |
| `VLLM_API_KEY` | API 密钥(必填) | - |
| `VLLM_MODEL_DIR_NAME` | 模型目录名称 | `Qwen3.5-35B` |
| `VLLM_SERVED_MODEL_NAME` | 对外服务名称 | `Qwen3.5` |
| `VLLM_MAX_MODEL_LEN` | 模型最大长度 | `256K` |
| `VLLM_GPU_MEMORY_UTILIZATION` | GPU 内存利用率 | `0.9` |
| `VLLM_GPU_DEVICE_ID` | GPU 设备 ID | `0` |

> **注意**: vLLM 配置选项非常丰富. 详细参数说明请参阅 `.env.example` 文件.

### MCP 服务桥接器 MCPO 配置

MCPO 配置文件位于 `mcpo/config.json`, 支持配置多个 MCP 服务器:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "time": {
      "command": "uvx",
      "args": ["mcp-server-time", "--local-timezone=Asia/Shanghai"]
    }
  }
}
```

配置修改后会自动热加载(已启用 `--hot-reload`).

### 在 OpenWebUI 添加 MCP 工具

在 OpenWebUI 管理界面中配置:

1. 进入管理员面板 **设置** → **外部连接** → **管理工具服务器**
2. 点击 `+` 添加工具服务器连接(以 `time` 为例):
    - 名称: `time-MCPO`
    - URL: `http://mcpo:8000/time`
    - 密钥: `你在.env中设置的MCPO_API_KEY`

### OpenWebUI 本地 vLLM 推理配置

在 OpenWebUI 管理界面中配置:

1. 进入管理员面板 **设置** → **扩展功能** → **管理 OpenAI 接口连接**
2. 点击 `+` 添加 vLLM OpenAI 兼容 API 连接:
    - URL: `http://vllm:5000/v1`
    - 密钥: `你在.env中设置的VLLM_API_KEY`

### 获取 NLTK 数据

OpenWebUI 在处理文本任务(如 RAG)时需要 NLTK 支持. 如果容器内自动下载失败, 可以手动下载并挂载到容器中.

> **提示**: 完整的 NLTK 数据包列表请参阅 [NLTK 官方数据页面](https://www.nltk.org/nltk_data/) 和 [nltk_data GitHub 仓库](https://github.com/nltk/nltk_data).

#### 根据报错手动下载

如果遇到 NLTK 数据缺失错误, 容器日志会显示类似以下信息:

```
[NLTK] failed to download punkt
```

根据报错提示中的资源名称, 使用以下命令下载:

```bash
# 创建 NLTK 数据目录
mkdir -p /mnt/NLTK

# 下载指定的数据包
python3 -c "
import nltk
import os

os.environ['NLTK_DATA'] = '/mnt/NLTK'

# 根据报错提示下载所需的数据包
packages = ['punkt', 'punkt_tab', 'averaged_perceptron_tagger', 'averaged_perceptron_tagger_eng', 'stopwords']
for pkg in packages:
    try:
        nltk.download(pkg, download_dir='/mnt/NLTK')
        print(f'Downloaded: {pkg}')
    except Exception as e:
        print(f'Failed to download {pkg}: {e}')
"
```

或者使用 NLTK 下载器交互式选择:

```bash
python3 -c "import nltk; nltk.download()"
```

#### 手动下载(网页)

如果网络环境无法直接通过 Python 下载, 可以从网页手动下载数据包:

1. 访问 [NLTK Data 下载页面](https://github.com/nltk/nltk_data/tree/gh-pages/packages) 或 [NLTK 官方下载页面](https://www.nltk.org/nltk_data/)
2. 根据需要的数据包类型, 下载对应的 zip 文件:
   - **tokenizers**: 从 `tokenizers/` 目录下载, 如 `punkt.zip`、`punkt_tab.zip`
   - **taggers**: 从 `taggers/` 目录下载, 如 `averaged_perceptron_tagger.zip`
   - **corpora**: 从 `corpora/` 目录下载, 如 `stopwords.zip`
3. 解压并将内容放入正确目录

##### 目录结构

下载完成后, 目录结构应如下:

```
/mnt/NLTK/
└── nltk_data/
    ├── tokenizers/
    │   ├── punkt/
    │   │   └── ...
    │   └── punkt_tab/
    │       └── ...
    ├── taggers/
    │   ├── averaged_perceptron_tagger/
    │   │   └── ...
    │   └── averaged_perceptron_tagger_eng/
    │       └── ...
    └── corpora/
        └── stopwords/
            └── ...
```

> **注意**: 下载的 zip 文件解压后, 需要确保子目录名称正确. 例如 `punkt.zip` 解压后应该是 `punkt/` 文件夹, 而不是额外的嵌套目录.

#### 配置环境变量

在 `.env` 文件中设置:

```bash
OPENWEBUI_NLTK_PATH=/mnt/NLTK
```

重启 OpenWebUI 容器后生效.

---

## 服务管理

### 查看服务状态

```bash
docker-compose ps
```

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f openwebui-app
docker-compose logs -f openwebui-vllm
```

### 重启服务

```bash
docker-compose restart openwebui
```

### 停止服务

```bash
docker-compose down
```

> **注意**: 使用 `down` 命令不会删除数据卷, 如需完全清理可使用 `docker-compose down -v`

---

## 备份与恢复

### 自动备份脚本

以下脚本可用于自动化 PostgreSQL 数据库的每日备份:

```bash
#!/bin/bash

# 配置
BACKUP_DIR="/path/to/backups"
DB_NAME="openwebui"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$TIMESTAMP.sql"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行备份(Docker 化 PostgreSQL)
docker exec -t openwebui-postgres pg_dump -U postgres -d $DB_NAME > $BACKUP_FILE

# 压缩备份
gzip $BACKUP_FILE

# 仅保留最近 7 个备份
ls -t $BACKUP_DIR/${DB_NAME}_backup_*.sql.gz | tail -n +8 | xargs -r rm

echo "Backup completed: $BACKUP_FILE.gz"
```

设置每日定时任务:

```bash
chmod +x backup_postgres.sh
crontab -e
# 添加以下行(每天凌晨 2 点执行)
0 2 * * * /path/to/backup_postgres.sh
```

### 恢复数据

```bash
# 解压备份文件
gunzip backup_file.sql.gz

# 恢复数据(Docker 化 PostgreSQL)
docker exec -i openwebui-postgres psql -U postgres -d openwebui < backup_file.sql
```

---

## 常见问题

### 1. 如何从官方单容器版本迁移？

如果当前使用官方单容器版本(使用 SQLite), 需要执行数据迁移:

1. 停止现有容器
2. 配置本方案的 PostgreSQL 和 Qdrant
3. 使用 taylorwilsdon 的[迁移工具](https://github.com/taylorwilsdon/open-webui-postgres-migration) 将数据从 SQLite 迁移到 PostgreSQL

### 2. WebSocket 连接失败？

检查以下配置:

- Valkey 服务是否正常运行
- `ENABLE_WEBSOCKET_SUPPORT` 是否设为 `true`
- `WEBSOCKET_MANAGER` 是否设为 `valkey`
- 反向代理是否支持 WebSocket

### 3. vLLM 无法启动？

- 确认 NVIDIA Driver 版本 >= 535
- 检查 GPU 显存是否充足
- 确认模型文件路径正确

### 4. Playwright 工具无法使用？

- 确认 `PLAYWRIGHT_VERSION` 与 OpenWebUI 中的版本一致
- 可使用 `scripts/get-playwright-version.sh` 获取正确版本

### 5. NLTK 数据缺失？

- 参阅本文档「获取 NLTK 数据」章节
- 检查容器日志中的具体报错信息, 根据提示下载对应数据包

### 6. 如何禁用不需要的服务？

如果不需要 vLLM, 可以在 `docker-compose.yml` 中注释掉 vllm 服务块. OpenWebUI 仍可正常工作, 只是无法使用本地 LLM 推理. 其他服务同理.

## 相关链接

- [Open Web UI 官方文档](https://docs.openwebui.com/)
- [Open Web UI 环境变量配置](https://docs.openwebui.com/getting-started/env-configuration/)
- [vLLM 文档](https://docs.vllm.ai/)
- [PostgreSQL 备份文档](https://www.postgresql.org/docs/current/backup.html)
- [Docker Compose 文档](https://docs.docker.com/compose/)

---

## 更新日志

详细更新日志请参阅 [CHANGELOG.md](./CHANGELOG.md).

---

## 致谢

本项目基于以下优秀的开源项目, 感谢所有作者与贡献者的辛勤付出:

- [Open Web UI](https://github.com/open-webui/open-webui) - 开源 AI 助手前端
- [PostgreSQL](https://www.postgresql.org/) - 世界最先进的开源关系型数据库
- [Qdrant](https://github.com/qdrant/qdrant) - 高性能向量数据库
- [vLLM](https://github.com/vllm-project/vllm) - 高性能 LLM 推理引擎
- [Valkey](https://github.com/valkey-io/valkey) - Redis 分支, 高性能内存数据库
- [Apache Tika](https://github.com/apache/tika) - 文档内容提取
- [Playwright](https://github.com/microsoft/playwright) - 浏览器自动化
- [MCPO](https://github.com/open-webui/mcpo) - MCP 到 OpenAI 协议桥接
- [Open Terminal](https://github.com/open-webui/open-terminal) - 终端访问组件

---
