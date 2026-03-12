# Composerized-OpenWebUI - Open Web UI Private Deployment Solution

> **中文版本**: [Chinese](./README.md)

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/openwebui/open-webui)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Qdrant](https://img.shields.io/badge/Qdrant-Latest-blue)](https://qdrant.tech/)
[![vLLM](https://img.shields.io/badge/vLLM-High--Performance-orange)](https://docs.vllm.ai/)

This project provides a Docker Compose-based private deployment solution for Open Web UI, featuring a modular architecture with production-grade components.

## Introduction

Following the naming convention of the original [`OPQ Stack`](https://github.com/danielrosehill/OpenWebUI-Postgres-Qdrant), this project uses **PORT-PUMQTV** (/pɔːrt/ /ˈpʌŋktɪv/) to refer to this container stack:

| Letter | Component | Description |
|--------|-----------|-------------|
| **P** | [PostgreSQL](https://www.postgresql.org/) | Primary database, replacing SQLite |
| **O** | [Open Web UI](https://github.com/open-webui/open-webui) | Main container, providing Web UI |
| **R** | [Valkey](https://github.com/valkey-io/valkey) | Redis community fork, for caching and WebSocket support |
| **T** | [Apache Tika](https://github.com/apache/tika) | Document extractor |
| **P** | [Playwright](https://github.com/microsoft/playwright) | Headless browser, for web access |
| **U** | [Unstructured](https://github.com/Unstructured-IO/unstructured) | Built into OpenWebUI |
| **M** | [MCPO](https://github.com/open-webui/mcpo) | Official MCP bridge, converts MCP servers to OpenAI-compatible APIs |
| **Q** | [Qdrant](https://github.com/qdrant/qdrant) | Vector database, for RAG |
| **T** | [Open Terminal](https://github.com/open-webui/open-terminal) | Official terminal component |
| **V** | [vLLM](https://github.com/vllm-project/vllm) | High-performance LLM backend (optional) |

> **Tip**: vLLM is optional. If not needed, it can be disabled. Other components can also be freely replaced:
>
> - LLM Backend: Use [Ollama](https://ollama.com/) or [SGLang](https://github.com/sgl-project/sglang) or [llama.cpp](https://github.com/ggml-org/llama.cpp) instead of vLLM
> - Document Extraction: Use [MinerU](https://github.com/opendatalab/MinerU) or [docling](https://github.com/docling-project/docling) instead of Tika
> - Browser Tools: Use [playwright-MCP](https://github.com/microsoft/playwright-mcp) or [browserless](https://github.com/browserless/browserless) instead of Playwright

## Prerequisites

- Docker Engine 24.0+
- Docker Compose v2.20+
- NVIDIA GPU + Driver 535+ (only required when using vLLM)

## Optional Services

The following services are **optional** and can be disabled or replaced as needed:

| Service | Purpose | How to Disable |
|---------|---------|----------------|
| vLLM | Local LLM inference | Comment out the vllm service in `docker-compose.yml` |
| MCPO | MCP tool bridge | Comment out the mcpo service |
| Playwright | Web access tool | Comment out the playwright service |
| Open Terminal | Terminal access | Comment out the open-terminal service |
| Tika | Document extraction | Comment out the tika service |

## TL;DR

### 1. Create Docker Network

Set `DOCKER_NETWORK` in `.env` file (default: `example_network`), then create the network:

```bash
docker network create example_network
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and modify according to your setup:

```bash
cp .env.example .env
vim .env
```

### 3. Start Services

```bash
docker-compose up -d
```

### 4. Access Open Web UI

After starting, access `http://<your-server-ip>:8080` (or the port you configured in `.env`).

---

## Detailed Configuration

### Environment Variables

#### Docker Network Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `DOCKER_NETWORK` | Docker network name | `example_network` |

#### OpenWebUI Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENWEBUI_PORT` | External access port | `8080` |
| `OPENWEBUI_SECRET_KEY` | Session key (required) | - |
| `OPENWEBUI_IP` | Server IP | `192.168.8.8` |
| `OPENWEBUI_DATA_PATH` | Data storage path | `/mnt/openwebui` |
| `OPENWEBUI_NLTK_PATH` | NLTK data path | `/mnt/NLTK` |

#### PostgreSQL Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_USER` | Username | `postgres` |
| `POSTGRES_PASSWORD` | Password (required) | - |
| `POSTGRES_DB` | Database name | `postgres` |
| `POSTGRES_DATA_PATH` | Data storage path | `/mnt/postgres` |

#### Qdrant Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `QDRANT_API_KEY` | API key (required) | - |
| `QDRANT_DATA_PATH` | Data storage path | `/mnt/qdrant` |

#### Valkey Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `VALKEY_PASSWORD` | Password (required) | - |
| `VALKEY_DATA_PATH` | Data storage path | `/mnt/valkey` |

#### vLLM Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `VLLM_IMAGE` | Image address | `vllm/vllm-openai:latest` |
| `VLLM_API_KEY` | API key (required) | - |
| `VLLM_MODEL_DIR_NAME` | Model directory name | `Qwen3.5-35B` |
| `VLLM_SERVED_MODEL_NAME` | Service model name | `Qwen3.5` |
| `VLLM_MAX_MODEL_LEN` | Max model length | `256K` |
| `VLLM_GPU_MEMORY_UTILIZATION` | GPU memory utilization | `0.9` |
| `VLLM_GPU_DEVICE_ID` | GPU device ID | `0` |

> **Note**: vLLM has many configuration options. See `.env.example` for detailed parameters.

### MCPO Configuration

The MCPO configuration file is located at `mcpo/config.json`, supporting multiple MCP servers:

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

Configuration changes will hot-reload automatically ( `--hot-reload` is enabled).

### Adding MCP Tools in OpenWebUI

Configure in OpenWebUI admin interface:

1. Go to **Settings** → **External Connections** → **Manage Tool Servers**
2. Click `+` to add a new tool server connection (using `time` as example):
   - Name: `time-MCPO`
   - URL: `http://mcpo:8000/time`
   - API Key: `MCPO_API_KEY you set in .env`

### Configuring Local vLLM in OpenWebUI

Configure in OpenWebUI admin interface:

1. Go to **Settings** → **Extensions** → **Manage OpenAI API Connections**
2. Click `+` to add a vLLM OpenAI-compatible API connection:
   - URL: `http://vllm:5000/v1`
   - API Key: `VLLM_API_KEY you set in .env`

### Getting NLTK Data

OpenWebUI requires NLTK support for text processing tasks (like RAG). If automatic download fails inside the container, you can manually download and mount it.

> **Tip**: For complete NLTK data package list, see [NLTK Official Data](https://www.nltk.org/nltk_data/) and [nltk_data GitHub](https://github.com/nltk/nltk_data).

#### Manual Download Based on Error

If you encounter NLTK data missing errors, the container logs will show something like:

```
[NLTK] failed to download punkt
```

Download the required packages based on the error message:

```bash
# Create NLTK data directory
mkdir -p /mnt/NLTK

# Download specific packages
python3 -c "
import nltk
import os

os.environ['NLTK_DATA'] = '/mnt/NLTK'

# Download packages based on error messages
packages = ['punkt', 'punkt_tab', 'averaged_perceptron_tagger', 'averaged_perceptron_tagger_eng', 'stopwords']
for pkg in packages:
    try:
        nltk.download(pkg, download_dir='/mnt/NLTK')
        print(f'Downloaded: {pkg}')
    except Exception as e:
        print(f'Failed to download {pkg}: {e}')
"
```

Or use NLTK downloader interactively:

```bash
python3 -c "import nltk; nltk.download()"
```

#### Manual Download (Web)

If network environment doesn't allow direct Python download:

1. Visit [NLTK Data Download Page](https://github.com/nltk/nltk_data/tree/gh-pages/packages) or [NLTK Official Download](https://www.nltk.org/nltk_data/)
2. Download the corresponding zip files based on package type:
   - **tokenizers**: Download from `tokenizers/` directory, e.g., `punkt.zip`, `punkt_tab.zip`
   - **taggers**: Download from `taggers/` directory, e.g., `averaged_perceptron_tagger.zip`
   - **corpora**: Download from `corpora/` directory, e.g., `stopwords.zip`
3. Extract and place contents in the correct directory

##### Directory Structure

After downloading, the directory structure should be:

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

> **Note**: After extracting, ensure subdirectory names are correct. For example, `punkt.zip` should extract to `punkt/` folder, not an extra nested directory.

#### Configure Environment Variable

Set in `.env` file:

```bash
OPENWEBUI_NLTK_PATH=/mnt/NLTK
```

Restart OpenWebUI container to take effect.

---

## Service Management

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f openwebui
docker-compose logs -f vllm
```

### Restart Service

```bash
docker-compose restart openwebui
```

### Stop Services

```bash
docker-compose down
```

> **Note**: Using `down` will not delete data volumes. Use `docker-compose down -v` for complete cleanup.

---

## Backup and Recovery

### Automated Backup Script

The following script can be used for automated daily PostgreSQL database backups:

```bash
#!/bin/bash

# Configuration
BACKUP_DIR="/path/to/backups"
DB_NAME="openwebui"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$TIMESTAMP.sql"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup (Dockerized PostgreSQL)
docker exec -t openwebui-postgres pg_dump -U postgres -d $DB_NAME > $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Keep only the 7 most recent backups
ls -t $BACKUP_DIR/${DB_NAME}_backup_*.sql.gz | tail -n +8 | xargs -r rm

echo "Backup completed: $BACKUP_FILE.gz"
```

Set up daily cron job:

```bash
chmod +x backup_postgres.sh
crontab -e
# Add the following line (run at 2 AM daily)
0 2 * * * /path/to/backup_postgres.sh
```

### Restore Data

```bash
# Decompress backup file
gunzip backup_file.sql.gz

# Restore data (Dockerized PostgreSQL)
docker exec -i openwebui-postgres psql -U postgres -d openwebui < backup_file.sql
```

---

## FAQ

### 1. How to migrate from official single-container version?

If currently using the official single-container version (with SQLite), you need to migrate data:

1. Stop existing containers
2. Configure PostgreSQL and Qdrant for this solution
3. Use taylorwilsdon's [migration tool](https://github.com/taylorwilsdon/open-webui-postgres-migration) to migrate data from SQLite to PostgreSQL

### 2. WebSocket connection failed?

Check the following:

- Is Valkey service running properly?
- Is `ENABLE_WEBSOCKET_SUPPORT` set to `true`?
- Is `WEBSOCKET_MANAGER` set to `valkey`?
- Does your reverse proxy support WebSocket?

### 3. vLLM won't start?

- Confirm NVIDIA Driver version >= 535
- Check if GPU memory is sufficient
- Verify model file path is correct

### 4. Playwright tool not working?

- Confirm `PLAYWRIGHT_VERSION` matches the version in OpenWebUI
- Use `scripts/get-playwright-version.sh` to get the correct version

### 5. NLTK data missing?

- See "Getting NLTK Data" section in this document
- Check container logs for specific error messages and download the corresponding packages

### 6. How to disable unwanted services?

If you don't need vLLM, you can comment out the vllm service block in `docker-compose.yml`. OpenWebUI will still work normally, just without local LLM inference. Same applies to other services.

## Related Links

- [Open Web UI Official Docs](https://docs.openwebui.com/)
- [Open Web UI Environment Configuration](https://docs.openwebui.com/getting-started/env-configuration/)
- [vLLM Documentation](https://docs.vllm.ai/)
- [PostgreSQL Backup Documentation](https://www.postgresql.org/docs/current/backup.html)
- [Docker Compose Documentation](https://www.docker.com/compose/)

---

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for detailed changelog.

---

## Acknowledgments

This project is based on the following excellent open-source projects, thanks to all authors and contributors:

- [Open Web UI](https://github.com/open-webui/open-webui) - Open AI Assistant Frontend
- [PostgreSQL](https://www.postgresql.org/) - World's Most Advanced Open Source Relational Database
- [Qdrant](https://github.com/qdrant/qdrant) - High-performance Vector Database
- [vLLM](https://github.com/vllm-project/vllm) - High-performance LLM Inference Engine
- [Valkey](https://github.com/valkey-io/valkey) - Redis Fork, High-performance In-memory Database
- [Apache Tika](https://github.com/apache/tika) - Document Content Extraction
- [Playwright](https://github.com/microsoft/playwright) - Browser Automation
- [MCPO](https://github.com/open-webui/mcpo) - MCP to OpenAI Protocol Bridge
- [Open Terminal](https://github.com/open-webui/open-terminal) - Terminal Access Component

---
