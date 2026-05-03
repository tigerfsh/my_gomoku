# Tasks

- [x] Task 1: 创建配置页面 Settings.ets
  - [x] 子任务 1.1: 实现先手方选择（人类/机器），使用两个互斥选中按钮
  - [x] 子任务 1.2: 实现执棋颜色选择（黑棋/白棋）
  - [x] 子任务 1.3: 实现保存按钮，将配置写入 AppStorage，然后 router.back()
  - [x] 子任务 1.4: 页面加载时从 AppStorage 读取当前配置作为默认值

- [x] Task 2: 注册 Settings 页面路由
  - [x] 子任务 2.1: 在 main_pages.json 中添加 "pages/Settings"

- [x] Task 3: 实现 AI 落子逻辑
  - [x] 子任务 3.1: 实现位置评分函数 evaluateDirection/evaluatePosition，对每个空位进行攻击和防守评分
  - [x] 子任务 3.2: 实现 findBestMove 函数，遍历所有空位返回最高分位置
  - [x] 子任务 3.3: 实现 aiMove/triggerAiMove，300ms 延迟自动落子，检查胜负，切换回合

- [x] Task 4: 重构 Index.ets 为人机对弈模式
  - [x] 子任务 4.1: 添加设置齿轮图标到右上角（Stack + Alignment.TopEnd）
  - [x] 子任务 4.2: 从 AppStorage 读取 humanColor 和 aiColor 配置
  - [x] 子任务 4.3: 修改 initGame，根据配置决定当前回合（先手方）
  - [x] 子任务 4.4: 修改 handleClick，仅在人类回合允许落子，落子后触发 AI 回合
  - [x] 子任务 4.5: 人类落子后通过 triggerAiMove 延迟调用 AI 落子（300ms）
  - [x] 子任务 4.6: 更新状态文字（"你的回合"/"AI 思考中..."/"你赢了！"/"AI 赢了！"）

- [x] Task 5: 整体验证与核对 checklist

# Task Dependencies
- Task 2 依赖 Task 1（需要先有页面再注册路由）
- Task 4 依赖 Task 3（AI 逻辑是 Index 重构的前提）
- Task 5 依赖 Task 1-4
