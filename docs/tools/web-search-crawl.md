# Web Search & Crawl 社区工具集成指南

> **工具名称**: Web Search and Crawl (fork)  
> **作者**: lexiismadd / Zeioth  
> **版本**: v3.2.0+  
> **安装页**: <https://openwebui.com/tools/web_search_and_crawl>  
> **源码**: <https://github.com/Zeioth/openwebui-extensibles>  

## 概述

这是一个 OpenWebUI **社区工具** (Community Tool)，而非内建环境变量配置。它工作在 OpenWebUI 内部，将我们已有的 SearXNG 和 Crawl4AI 基础设施串联成完整的"搜索→爬取→LLM 提取→交付"管道。

```
用户提问 → LLM 调用 tool
                ↓
         SearXNG 搜索 ──→ 获取 URL 列表
         Native Search ──→ 补充 URL
                ↓
         Crawl4AI 爬取  → 提取 Markdown 正文
                ↓
         LLM 结构化提取  → 摘要/引用/媒体
                ↓
         返回聊天界面
```

## 与现有服务的关系

| 工具配置项 | 对应 Docker 服务 | 容器内地址 |
|---|---|---|
| `SEARXNG_BASE_URL` | `searxng` | `http://searxng:8080/search?format=json&q=<query>` |
| `CRAWL4AI_BASE_URL` | `crawl4ai` | `http://crawl4ai:11235` |
| `LLM_BASE_URL` | `vllm` (或外部 API) | `http://vllm:5000/v1` |
| `LLM_PROVIDER` | 你选用的模型 | 见下方推荐 |

所有服务已在 `docker-compose.yml` 中就绪，工具安装后只需配置 Valves 即可使用。

---

## 安装步骤

### 1. 在 OpenWebUI 中安装工具

1. 登录 OpenWebUI，进入 **工作空间** → **工具**
2. 点击 **"从社区导入工具"** (Import Tool from Community)
3. 搜索 **"Web Search and Crawl"**
4. 选择作者为 `lexiismadd` / 维护者为 `Zeioth` 的 fork 版本
5. 点击 **导入**

或者直接访问 <https://openwebui.com/tools/web_search_and_crawl> 一键导入。

### 2. 配置 Valves

导入后，点击工具的齿轮图标 ⚙️ 进入阀门 (Valves) 设置。

#### 核心必填项

| Valve | 值 | 说明 |
|---|---|---|
| `SEARXNG_BASE_URL` | `http://searxng:8080/search?format=json&q=<query>` | ⚠️ 必须包含 `http://`，`<query>` 保持字面 |
| `CRAWL4AI_BASE_URL` | `http://crawl4ai:11235` | Crawl4AI API 地址 |
| `LLM_BASE_URL` | `http://vllm:5000/v1` | LLM API 地址 (用你实际的 LLM 服务) |
| `LLM_PROVIDER` | `openai/Qwen3.5` | 格式: `<provider>/<model>` |
| `LLM_API_TOKEN` | 你的 API Key | 如果是 vLLM 则为 `VLLM_API_KEY` 的值 |
| `SEARCH_WITH_SEARXNG` | `true` | 启用 SearXNG 搜索 |
| `USE_NATIVE_SEARCH` | `true` | 同时启用 OpenWebUI 原生搜索 |

#### 抓取控制

| Valve | 推荐值 | 说明 |
|---|---|---|
| `CRAWL4AI_BATCH` | `5` | 每批爬取的 URL 数 |
| `CRAWL4AI_MAX_URLS` | `10` | 最大爬取 URL 数 |
| `CRAWL4AI_TIMEOUT` | `30` | 爬取超时 (秒) |
| `CRAWL4AI_TEXT_ONLY` | `false` | 保留图片/媒体 |
| `CRAWL4AI_DISPLAY_MEDIA` | `true` | 在聊天中显示媒体 |
| `CRAWL4AI_MAX_TOKENS` | `8000` | 返回内容的最大 token 数 |

#### LLM 提取控制

| Valve | 推荐值 | 说明 |
|---|---|---|
| `LLM_TEMPERATURE` | `0` | 提取建议用 0，保证一致性 |
| `LLM_MAX_TOKENS` | `1200` | LLM 提取输出的最大 token |
| `LLM_INSTRUCTION` | 见下方模板 | 告诉 LLM 如何结构化提取 |

<details>
<summary>LLM_INSTRUCTION 推荐模板 (点击展开)</summary>

```
Extract the key information from the following web page content. 
Summarize the main points in a clear, structured format. 
Include:
- Title and source
- Key facts and data points
- A concise summary (2-3 paragraphs)
- Important quotes if relevant
Keep the total output under the token limit.
```

</details>

#### 研究模式 (Research Mode)

研究模式启用后，Crawl4AI 会递归跟踪页面中的链接，进行更深度的信息收集。

| Valve | 推荐值 | 说明 |
|---|---|---|
| `RESEARCH_MODE` (UserValves) | `false` | 用户可按需开启 |
| `RESEARCH_CRAWL_MODE` | `pseudo_adaptive` | 推荐策略，基于关键词打分 |
| `RESEARCH_MAX_DEPTH` | `3` | 最大链接深度 |
| `RESEARCH_MAX_PAGES` | `10` | 最大爬取页数 |

四种研究策略:

- **pseudo_adaptive** (推荐): 基于关键词打分、迭代爬取
- **llm_guided**: LLM 辅助选择链接 (需要更好的 LLM)
- **bfs_deep**: 广度优先深度爬取
- **research_filter**: 相关性过滤

---

## LLM 模型选择建议

### 用于爬取内容提取的 LLM

Crawl4AI 将网页转成 Markdown 后，需要一个 LLM 做结构化提取。推荐使用轻量、快速的专用模型：

| 模型 | 说明 |
|---|---|
| `hf.co/aman2024/NuExtract-2-2B-GGUF:Q3_K_M` | 2B 参数，支持图片，速度快 |
| `Inference/Schematron:3B` | 3B 参数，仅文本，提取能力更强 |
| `openai/Qwen3.5` | 如果本地 vLLM 已部署，直接用主模型 |

> **提示**: 如果 vLLM 承载的是大模型 (30B+)，建议同时部署一个小模型专门给 Crawl4AI 用，避免大模型推理延迟影响爬取体验。

### 在 vLLM 中部署专门的提取模型

如果你希望为 Crawl4AI 单独运行一个小模型实例:

```bash
# 例如用 Ollama 挂一个小模型
docker run -d --name ollama-extract \
  --network example_network \
  ollama/ollama:latest
docker exec ollama-extract ollama pull hf.co/aman2024/NuExtract-2-2B-GGUF:Q3_K_M
```

然后将工具的 `LLM_BASE_URL` 设为 `http://ollama-extract:11434`，`LLM_PROVIDER` 设为 `ollama/hf.co/aman2024/NuExtract-2-2B-GGUF:Q3_K_M`。

---

## 验证与调试

### 检查各服务是否正常

```bash
# SearXNG
docker logs -f openwebui-searxng

# Crawl4AI
docker logs -f openwebui-crawl4ai

# OpenWebUI (查看工具调用日志)
docker logs -f openwebui-app
```

### 开启调试模式

在工具的 Valves 中将 `DEBUG` 设为 `true`，然后观察 OpenWebUI 日志:

```bash
docker logs -f openwebui-app 2>&1 | grep -i "search_and_crawl"
```

### 常见问题

| 问题 | 可能原因 | 解决 |
|---|---|---|
| 工具没有出现在可用工具列表 | 未正确导入或未启用 | 工作空间→工具→点击工具→确保开关打开 |
| `'str' object has no attribute 'get'` | LLM 返回格式不匹配 | 检查 LLM_PROVIDER 格式是否正确 (`provider/model`) |
| 搜索结果为空 | SearXNG 连通性问题 | `docker exec openwebui-searxng curl "http://localhost:8080/search?format=json&q=test"` |
| 爬取超时 | Crawl4AI shm_size 不足 | 已在 `docker-compose.yml` 中设为 `8g` |
| 内容被截断 | token 限制 | 调大 `CRAWL4AI_MAX_TOKENS` |
| LLM 提取失败 | 提取模型太弱/不可用 | 先切到主模型测试，确认链路通后再换专用模型 |

---

## 完整 Valves 参考表

### Global Settings (管理员配置)

| 类别 | Valve | 默认值 | 说明 |
|---|---|---|---|
| **General** | `INITIAL_RESPONSE` | 空 | 工具启动时显示的提示消息 |
| **Search** | `USE_NATIVE_SEARCH` | `true` | 启用 OpenWebUI 内置搜索 |
| | `SEARCH_WITH_SEARXNG` | `true` | 启用 SearXNG |
| | `SEARXNG_BASE_URL` | 空 | SearXNG API URL，用 `<query>` 占位 |
| | `SEARXNG_API_TOKEN` | 空 | SearXNG API Token |
| | `SEARXNG_METHOD` | `GET` | HTTP 方法 (GET/POST) |
| | `SEARXNG_TIMEOUT` | `10` | 搜索超时 (秒) |
| | `SEARXNG_MAX_RESULTS` | `10` | 最大搜索结果数 |
| **Crawl4AI** | `CRAWL4AI_BASE_URL` | `http://crawl4ai:11235` | Crawl4AI 地址 |
| | `CRAWL4AI_USER_AGENT` | 空 | 自定义 User-Agent |
| | `CRAWL4AI_TIMEOUT` | `30` | 爬取超时 (秒) |
| | `CRAWL4AI_BATCH` | `5` | 每批 URL 数 |
| | `CRAWL4AI_MAX_URLS` | `10` | 最大爬取 URL 数 |
| | `CRAWL4AI_TEXT_ONLY` | `false` | 纯文本模式 |
| | `CRAWL4AI_DISPLAY_MEDIA` | `true` | 显示图片/视频 |
| | `CRAWL4AI_MAX_TOKENS` | `8000` | 返回内容 token 上限 |
| **LLM** | `LLM_BASE_URL` | 空 | OpenAI 兼容 API 地址 |
| | `LLM_API_TOKEN` | 空 | API Token |
| | `LLM_PROVIDER` | 空 | 格式: `provider/model` |
| | `LLM_TEMPERATURE` | `0` | 温度参数 |
| | `LLM_MAX_TOKENS` | `1200` | LLM 输出 token 上限 |
| **Other** | `DEBUG` | `false` | 开启调试日志 |

### UserValves (用户可覆盖)

| Valve | 说明 |
|---|---|
| `SEARXNG_MAX_RESULTS` | 覆盖全局搜索结果数 |
| `CRAWL4AI_MAX_URLS` | 覆盖全局爬取 URL 数 |
| `CRAWL4AI_DISPLAY_MEDIA` | 覆盖媒体显示 |
| `RESEARCH_MODE` | 用户开启研究模式 |
| `RESEARCH_CRAWL_MODE` | 研究模式策略 |
| `RESEARCH_MAX_DEPTH` | 研究模式链接深度 |
| `RESEARCH_MAX_PAGES` | 研究模式最大页数 |

---

## 相关资源

- 工具安装页: <https://openwebui.com/tools/web_search_and_crawl>
- GitHub 源码: <https://github.com/Zeioth/openwebui-extensibles>
- 作者介绍帖: <https://openwebui.com/posts/web_search_and_crawl_d33f7960>
- SearXNG 文档: <https://docs.searxng.org/>
- Crawl4AI 文档: <https://crawl4ai.com/>
