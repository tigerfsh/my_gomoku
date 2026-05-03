# 五子棋游戏 Spec

## Why
当前项目仅有 Hello World 页面，需要实现一个完整的五子棋双人对弈游戏，让用户在 HarmonyOS 设备上体验五子棋的乐趣。

## What Changes
- 在 `entry/src/main/ets/pages/` 下实现五子棋主页面（`Index.ets`）
- 不修改已有的 `build-profile.json5`、`module.json5` 等配置文件
- 不修改 `EntryAbility.ets`、资源文件等已有代码
- 纯前端实现，无网络请求、无持久化存储

## Impact
- Affected specs: 无（新增功能）
- Affected code: `entry/src/main/ets/pages/Index.ets`（仅修改此文件）

## ADDED Requirements

### Requirement: 棋盘渲染
系统 SHALL 渲染一个 15×15 的五子棋棋盘，线条和交叉点清晰可见，棋子放置在交叉点上。

#### Scenario: 棋盘显示
- **WHEN** 用户打开应用
- **THEN** 显示 15×15 的棋盘网格，并且棋盘居中显示

### Requirement: 落子功能
系统 SHALL 支持黑白双方轮流在棋盘空格上落子。

#### Scenario: 黑方落子
- **WHEN** 轮到黑方且用户点击棋盘上的空格交叉点
- **THEN** 该位置显示黑色棋子，回合切换到白方

#### Scenario: 白方落子
- **WHEN** 轮到白方且用户点击棋盘上的空格交叉点
- **THEN** 该位置显示白色棋子，回合切换到黑方

#### Scenario: 已有棋子位置不可落子
- **WHEN** 用户点击已有棋子的位置
- **THEN** 不产生任何效果，回合不变

### Requirement: 胜负判定
系统 SHALL 在每次落子后检查是否有五子连珠（横、竖、斜四个方向），若有则判定对应方获胜。

#### Scenario: 水平五连
- **WHEN** 某方落子后在水平方向上形成连续五子
- **THEN** 该方获胜，游戏结束

#### Scenario: 垂直五连
- **WHEN** 某方落子后在垂直方向上形成连续五子
- **THEN** 该方获胜，游戏结束

#### Scenario: 斜向五连
- **WHEN** 某方落子后在正斜线或反斜线方向上形成连续五子
- **THEN** 该方获胜，游戏结束

### Requirement: 游戏状态显示
系统 SHALL 在棋盘上方显示当前回合信息（"黑棋回合" / "白棋回合"）或游戏结束信息（"黑棋获胜！" / "白棋获胜！"）。

#### Scenario: 显示当前回合
- **WHEN** 游戏进行中且轮到黑方
- **THEN** 显示"黑棋回合"

#### Scenario: 显示获胜信息
- **WHEN** 某方获胜
- **THEN** 显示"X棋获胜！"，并不再允许落子

### Requirement: 重新开始
系统 SHALL 提供重新开始按钮，点击后清空棋盘并重置游戏状态。

#### Scenario: 重新开始游戏
- **WHEN** 用户点击"重新开始"按钮
- **THEN** 棋盘清空，回合重置为黑方先手，游戏状态恢复为进行中
