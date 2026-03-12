# 更新日志

本文档记录了 PORT-PUMQTV 容器栈的所有重要更新和变更。

> **注意**：鉴于这些文档很可能迅速过时并被淘汰，请务必关注该 CHANGELOG 以获取最准确的信息

---

## 2026-03-12 - 初始版本

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
| 2026-03-12 | 1.0.0 | 初始版本发布 |

---

*如需查看完整的部署文档，请参阅 [README.md](./README.md)*
