# 人机对弈与配置页 Spec

## Why
当前五子棋仅支持双人对弈，需要改为人与程序对弈模式，并支持先手和执棋颜色配置，提升游戏可玩性。

## What Changes
- 新增配置页面 `pages/Settings`，提供先手选择和执棋颜色选择
- 在主页面右上角添加配置入口图标，点击跳转配置页
- 将双人对弈改为人类 vs AI 对弈
- 实现 AI 落子逻辑（基于位置评分策略）
- AI 落子后自动切换回合，AI 先手时自动下第一步
- 通过 AppStorage 跨页面共享配置
- 修改 `main_pages.json` 注册新页面

## Impact
- Affected specs: `implement-gomoku-game`
- Affected code:
  - `entry/src/main/ets/pages/Index.ets` — 重构为人机对弈 + 配置入口
  - `entry/src/main/ets/pages/Settings.ets` — **新增**
  - `entry/src/main/resources/base/profile/main_pages.json` — 注册 Settings 页

## ADDED Requirements

### Requirement: 人机对弈
系统 SHALL 支持人类与 AI 对弈，根据配置决定人类执黑还是执白，以及谁先手。

#### Scenario: 人类先手执黑
- **WHEN** 配置为人类先手且人类执黑
- **THEN** 游戏开始后等待人类点击落子，人类落黑子后 AI 自动落白子

#### Scenario: AI 先手执黑
- **WHEN** 配置为 AI 先手且人类执白
- **THEN** 游戏开始后 AI 自动落黑子，然后等待人类落白子

#### Scenario: 人类回合
- **WHEN** 轮到人类落子
- **THEN** 点击棋盘空格落子，棋子颜色为人类配置的颜色

#### Scenario: AI 回合
- **WHEN** 轮到 AI 落子且游戏未结束
- **THEN** AI 在 300ms 延迟后自动落子到评分最高的位置

### Requirement: 配置页面
系统 SHALL 提供配置页面，用户可设置先手方和执棋颜色。

#### Scenario: 打开配置页
- **WHEN** 用户点击主页面右上角设置图标
- **THEN** 导航到 Settings 配置页面

#### Scenario: 选择先手方
- **WHEN** 用户在配置页切换先手方选项（人类/机器）
- **THEN** 选项立即更新

#### Scenario: 选择执棋颜色
- **WHEN** 用户在配置页切换执棋颜色（黑棋/白棋）
- **THEN** 选项立即更新

#### Scenario: 保存配置
- **WHEN** 用户点击保存按钮
- **THEN** 配置写入 AppStorage，返回主页面，游戏自动按新配置重新开始

### Requirement: 配置入口图标
系统 SHALL 在主页面右上角显示设置图标，作为配置页入口。

#### Scenario: 显示设置图标
- **WHEN** 主页面渲染
- **THEN** 右上角显示齿轮图标按钮

## MODIFIED Requirements

### Requirement: 棋盘渲染
~~系统 SHALL 渲染一个 15×15 的五子棋棋盘~~ → 不变

### Requirement: 落子功能
~~系统 SHALL 支持黑白双方轮流在棋盘空格上落子~~ → 改为人类与 AI 轮流落子，人类回合点击落子，AI 回合自动落子

### Requirement: 游戏状态显示
系统 SHALL 在棋盘上方显示当前回合信息（"你的回合" / "AI 思考中..."）或游戏结束信息（"你赢了！" / "AI 赢了！"）。
