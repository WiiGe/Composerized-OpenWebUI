# 更新日志

本文档记录了 POST-CRUMQPTV 容器栈的所有重要更新和变更。

> **注意**：鉴于这些文档很可能迅速过时并被淘汰，请务必关注该 CHANGELOG 以获取最准确的信息

---

## 2026-06-23 - SearXNG + Crawl4AI 集成

### 新增服务

- **SearXNG**: 聚合搜索引擎，为 Web Search 功能提供后端
  - 配置文件: `searxng/settings.yml`
  - 环境变量: `SEARXNG_SECRET_KEY`, `SEARXNG_DATA_PATH`
- **Crawl4AI-Proxy**: 翻译 OpenWebUI external loader 请求到 Crawl4AI 格式
  - 依赖 `crawl4ai` 服务
- **openai-edge-tts**: 文字转语音服务 (默认注释，按需启用)

### 基础设施改进

- **Playwright**: 添加 `ipc: host`, `shm_size: 4gb`, `restart: unless-stopped`
- **Tika**: 添加 `JAVA_OPTS=-Xmx4g`, 挂载 `tika-config.xml`, 内存限制 12G
- **Crawl4AI**: `shm_size` 4g→8g, 修复网络为变量引用, 添加 healthcheck, `ENV_FILE` 路径修正
- **Valkey**: healthcheck 添加密码认证 (`-a password`)
- **Qdrant**: `QDRANT_URI` 支持 `QDRANT_PORT` 变量
- **OpenWebUI**:
  - Web Loader 切换为 `external` 模式 (crawl4ai-proxy)
  - 新增 Web Search 变量组 (searxng)
  - 新增 Playwright 重试配置
  - CORS 分隔符改为分号 (OpenWebUI 标准)
  - 日志级别 `DEBUG`→`INFO`

### 新增文档

- **`docs/tools/web-search-crawl.md`**: Web Search & Crawl 社区工具完整集成指南
  - Valves 配置表 (适配本项目容器地址)
  - LLM 模型选择建议
  - Research Mode 配置
  - 调试方法和常见问题排查

### 目录结构优化

- `crawl4ai/.llm.env`: Crawl4AI LLM 配置 (从根目录移入)
- `tika/tika-config.xml`: Tika 解析器配置
- `searxng/settings.yml`: SearXNG 引擎配置
- 每个组件配置归入各自目录

### 文档更新

- README 新增 SearXNG/Crawl4AI 徽章和环境变量表
- README 新增"社区工具"章节
- README 可选服务表扩展
- `.env.example` 新增 SearXNG/Crawl4AI/QDRANT_PORT 变量

---

### 新增功能

- **多容器部署方案**：基于 Docker Compose 的完整部署方案
- **组件列表**：
  - **O**pen Web UI：主容器，提供 Web 界面
  - **P**ostgreSQL (16)：主数据库，替换 SQLite
  - **Q**drant：向量数据库，用于 RAG
  - **M**CP**O**：MCP 桥接器，将 MCP 服务器转换为 OpenAI 兼容 API
  - **T**ika：Apache Tika，文档提取器
  - **T**erminal：Open Terminal，官方终端组件
  - **P**laywright：用于网页访问的无头浏览器
  - **V**alkey：即 Redis，用于提升访问响应性和 WebSocket 支持
  - **v**LLM：高性能本地 LLM 后端

### 配置特性

- 使用环境变量配置所有服务
- 支持数据持久化到指定路径
- 健康检查配置
- 外部网络支持
- vLLM 完整配置选项

### 文档

- 完整的 README 部署指南
- `.env.example` 配置文件模板

---

## 文档版本历史

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-06-23 | 1.1.0 | SearXNG + Crawl4AI 集成, Web Search & Crawl 社区工具指南 |
| 2026-03-12 | 1.0.0 | 初始版本发布 |

---

*如需查看完整的部署文档，请参阅 [README.md](./README.md)*
