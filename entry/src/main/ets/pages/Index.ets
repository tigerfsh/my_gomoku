import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State statusText: string = '你的回合';
  @State gameOver: boolean = false;
  @State remainingSeconds: number = 0;
  @State showTimer: boolean = false;

  private board: number[][] = [];
  private currentPlayer: number = 1;
  private humanColor: number = 1;
  private aiColor: number = 2;
  private readonly BOARD_SIZE: number = 15;
  private readonly CELL_SIZE: number = 22;
  private readonly PADDING: number = 16;
  private timeoutEnabled: boolean = false;
  private timeoutSeconds: number = 60;
  private timerId: number = -1;
  private animFrameId: number = -1;
  private boardReady: boolean = false;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.loadConfig();
    this.initGame();
  }

  onPageShow(): void {
    this.stopTimer();
    this.loadConfig();
    this.initGame();
  }

  loadConfig(): void {
    let color = AppStorage.get<string>('gomoku_human_color');
    if (color === '2') {
      this.humanColor = 2;
      this.aiColor = 1;
    } else {
      this.humanColor = 1;
      this.aiColor = 2;
    }
    let to = AppStorage.get<string>('gomoku_enable_timeout');
    this.timeoutEnabled = to === 'true';
    let sec = AppStorage.get<string>('gomoku_timeout_seconds');
    if (sec !== undefined && sec !== null && sec !== '') {
      let val = parseInt(sec);
      if (val >= 10 && val <= 180) {
        this.timeoutSeconds = val;
      }
    }
  }

  initGame(): void {
    this.stopTimer();
    this.stopAnimation();
    this.board = [];
    for (let i = 0; i < this.BOARD_SIZE; i++) {
      this.board[i] = [];
      for (let j = 0; j < this.BOARD_SIZE; j++) {
        this.board[i][j] = 0;
      }
    }
    this.gameOver = false;

    let first = AppStorage.get<string>('gomoku_human_first');
    let humanFirst = first === undefined ? true : first !== 'false';
    this.currentPlayer = humanFirst ? this.humanColor : this.aiColor;
    this.updateStatusText();
    this.refreshBoard();

    if (this.currentPlayer === this.aiColor) {
      this.triggerAiMove();
    } else {
      this.startTimer();
    }
  }

  updateStatusText(): void {
    if (this.gameOver) {
      return;
    }
    if (this.currentPlayer === this.humanColor) {
      this.statusText = '你的回合';
    } else {
      this.statusText = 'AI 思考中...';
    }
  }

  refreshBoard(): void {
    if (this.boardReady) {
      this.drawBoard();
    }
  }

  drawBoard(): void {
    let ctx = this.context;
    let boardWidth = this.CELL_SIZE * (this.BOARD_SIZE - 1) + this.PADDING * 2;
    let boardHeight = boardWidth;

    ctx.fillStyle = '#DEB887';
    ctx.fillRect(0, 0, boardWidth, boardHeight);

    ctx.strokeStyle = '#333333';
    ctx.lineWidth = 1;
    for (let i = 0; i < this.BOARD_SIZE; i++) {
      ctx.beginPath();
      ctx.moveTo(this.PADDING, this.PADDING + i * this.CELL_SIZE);
      ctx.lineTo(this.PADDING + (this.BOARD_SIZE - 1) * this.CELL_SIZE, this.PADDING + i * this.CELL_SIZE);
      ctx.stroke();

      ctx.beginPath();
      ctx.moveTo(this.PADDING + i * this.CELL_SIZE, this.PADDING);
      ctx.lineTo(this.PADDING + i * this.CELL_SIZE, this.PADDING + (this.BOARD_SIZE - 1) * this.CELL_SIZE);
      ctx.stroke();
    }

    for (let i = 0; i < this.BOARD_SIZE; i++) {
      for (let j = 0; j < this.BOARD_SIZE; j++) {
        if (this.board[i][j] !== 0) {
          let cx = this.PADDING + i * this.CELL_SIZE;
          let cy = this.PADDING + j * this.CELL_SIZE;
          let r = this.CELL_SIZE / 2 - 1;

          ctx.beginPath();
          ctx.arc(cx, cy, r, 0, Math.PI * 2);
          if (this.board[i][j] === 1) {
            ctx.fillStyle = '#000000';
          } else {
            ctx.fillStyle = '#FFFFFF';
          }
          ctx.fill();

          if (this.board[i][j] === 2) {
            ctx.strokeStyle = '#333333';
            ctx.lineWidth = 1;
            ctx.stroke();
          }
        }
      }
    }
  }

  handleClick(x: number, y: number): void {
    if (this.gameOver) {
      return;
    }
    if (this.currentPlayer !== this.humanColor) {
      return;
    }

    let colFloat = (x - this.PADDING) / this.CELL_SIZE;
    let rowFloat = (y - this.PADDING) / this.CELL_SIZE;
    let col = Math.round(colFloat);
    let row = Math.round(rowFloat);

    if (col < 0 || col >= this.BOARD_SIZE || row < 0 || row >= this.BOARD_SIZE) {
      return;
    }
    if (this.board[col][row] !== 0) {
      return;
    }

    this.stopTimer();
    this.board[col][row] = this.humanColor;
    this.drawBoard();

    if (this.checkWin(col, row)) {
      this.gameOver = true;
      this.statusText = '你赢了！';
    } else {
      this.currentPlayer = this.aiColor;
      this.statusText = 'AI 思考中...';
      this.triggerAiMove();
    }
  }

  checkWin(col: number, row: number): boolean {
    let player = this.board[col][row];
    let directions: number[][] = [[1, 0], [0, 1], [1, 1], [1, -1]];

    for (let d = 0; d < directions.length; d++) {
      let dx = directions[d][0];
      let dy = directions[d][1];
      let count = 1;

      for (let step = 1; step < 5; step++) {
        let nc = col + dx * step;
        let nr = row + dy * step;
        if (nc >= 0 && nc < this.BOARD_SIZE && nr >= 0 && nr < this.BOARD_SIZE &&
          this.board[nc][nr] === player) {
          count++;
        } else {
          break;
        }
      }

      for (let step = 1; step < 5; step++) {
        let nc = col - dx * step;
        let nr = row - dy * step;
        if (nc >= 0 && nc < this.BOARD_SIZE && nr >= 0 && nr < this.BOARD_SIZE &&
          this.board[nc][nr] === player) {
          count++;
        } else {
          break;
        }
      }

      if (count >= 5) {
        return true;
      }
    }
    return false;
  }

  evaluateDirection(col: number, row: number, dx: number, dy: number, player: number): number {
    let count = 0;
    let openEnds = 0;

    for (let step = 1; step <= 5; step++) {
      let nc = col + dx * step;
      let nr = row + dy * step;
      if (nc >= 0 && nc < this.BOARD_SIZE && nr >= 0 && nr < this.BOARD_SIZE &&
        this.board[nc][nr] === player) {
        count++;
      } else {
        if (nc >= 0 && nc < this.BOARD_SIZE && nr >= 0 && nr < this.BOARD_SIZE &&
          this.board[nc][nr] === 0) {
          openEnds++;
        }
        break;
      }
    }

    for (let step = 1; step <= 5; step++) {
      let nc = col - dx * step;
      let nr = row - dy * step;
      if (nc >= 0 && nc < this.BOARD_SIZE && nr >= 0 && nr < this.BOARD_SIZE &&
        this.board[nc][nr] === player) {
        count++;
      } else {
        if (nc >= 0 && nc < this.BOARD_SIZE && nr >= 0 && nr < this.BOARD_SIZE &&
          this.board[nc][nr] === 0) {
          openEnds++;
        }
        break;
      }
    }

    if (count >= 4) {
      return 100000;
    }
    if (count === 3) {
      if (openEnds === 2) {
        return 10000;
      }
      if (openEnds === 1) {
        return 5000;
      }
    }
    if (count === 2) {
      if (openEnds === 2) {
        return 1000;
      }
      if (openEnds === 1) {
        return 500;
      }
    }
    if (count === 1) {
      if (openEnds === 2) {
        return 100;
      }
      if (openEnds === 1) {
        return 50;
      }
    }
    if (count === 0 && openEnds === 2) {
      return 10;
    }
    return 0;
  }

  evaluatePosition(col: number, row: number): number {
    let attackScore = 0;
    let defenseScore = 0;
    let directions: number[][] = [[1, 0], [0, 1], [1, 1], [1, -1]];

    for (let d = 0; d < directions.length; d++) {
      let dx = directions[d][0];
      let dy = directions[d][1];
      attackScore += this.evaluateDirection(col, row, dx, dy, this.aiColor);
      defenseScore += this.evaluateDirection(col, row, dx, dy, this.humanColor);
    }

    return attackScore * 1.1 + defenseScore;
  }

  findBestMove(): [number, number] {
    let bestScore = -1;
    let bestCol = 7;
    let bestRow = 7;

    let hasPiece = false;
    for (let i = 0; i < this.BOARD_SIZE; i++) {
      for (let j = 0; j < this.BOARD_SIZE; j++) {
        if (this.board[i][j] !== 0) {
          hasPiece = true;
          break;
        }
      }
      if (hasPiece) {
        break;
      }
    }

    if (!hasPiece) {
      return [7, 7];
    }

    for (let i = 0; i < this.BOARD_SIZE; i++) {
      for (let j = 0; j < this.BOARD_SIZE; j++) {
        if (this.board[i][j] !== 0) {
          continue;
        }

        let nearPiece = false;
        for (let di = -2; di <= 2; di++) {
          for (let dj = -2; dj <= 2; dj++) {
            let ni = i + di;
            let nj = j + dj;
            if (ni >= 0 && ni < this.BOARD_SIZE && nj >= 0 && nj < this.BOARD_SIZE &&
              this.board[ni][nj] !== 0) {
              nearPiece = true;
              break;
            }
          }
          if (nearPiece) {
            break;
          }
        }

        if (!nearPiece) {
          continue;
        }

        let score = this.evaluatePosition(i, j);
        if (score > bestScore) {
          bestScore = score;
          bestCol = i;
          bestRow = j;
        }
      }
    }

    return [bestCol, bestRow];
  }

  aiMove(): void {
    if (this.gameOver) {
      return;
    }
    if (this.currentPlayer !== this.aiColor) {
      return;
    }

    let result = this.findBestMove();
    let col = result[0];
    let row = result[1];

    if (col < 0 || col >= this.BOARD_SIZE || row < 0 || row >= this.BOARD_SIZE) {
      return;
    }
    if (this.board[col][row] !== 0) {
      return;
    }

    this.animateAiPiece(col, row);
  }

  stopAnimation(): void {
    if (this.animFrameId !== -1) {
      clearInterval(this.animFrameId);
      this.animFrameId = -1;
    }
  }

  animateAiPiece(col: number, row: number): void {
    this.stopAnimation();
    let cx = this.PADDING + col * this.CELL_SIZE;
    let cy = this.PADDING + row * this.CELL_SIZE;
    let maxR = this.CELL_SIZE / 2 - 1;
    let totalFrames = 12;
    let frameIndex = 0;

    this.animFrameId = setInterval(() => {
      this.drawBoard();
      let ctx = this.context;
      let progress = frameIndex / totalFrames;
      let scale = Math.sin(progress * Math.PI * 0.5);

      ctx.globalAlpha = 0.3 + 0.7 * progress;
      ctx.beginPath();
      ctx.arc(cx, cy, maxR, 0, Math.PI * 2);
      ctx.fillStyle = '#4A90D9';
      ctx.fill();

      let r = maxR * scale;
      ctx.globalAlpha = 1;
      ctx.beginPath();
      ctx.arc(cx, cy, r, 0, Math.PI * 2);
      if (this.aiColor === 1) {
        ctx.fillStyle = '#000000';
      } else {
        ctx.fillStyle = '#FFFFFF';
      }
      ctx.fill();
      if (this.aiColor === 2) {
        ctx.strokeStyle = '#333333';
        ctx.lineWidth = 1;
        ctx.stroke();
      }

      ctx.globalAlpha = 1;
      frameIndex++;

      if (frameIndex > totalFrames) {
        this.stopAnimation();
        this.board[col][row] = this.aiColor;
        this.drawBoard();

        if (this.checkWin(col, row)) {
          this.gameOver = true;
          this.statusText = 'AI 赢了！';
        } else {
          this.currentPlayer = this.humanColor;
          this.statusText = '你的回合';
          this.startTimer();
        }
      }
    }, 40);
  }

  triggerAiMove(): void {
    setTimeout(() => {
      this.aiMove();
    }, 300);
  }

  startTimer(): void {
    if (!this.timeoutEnabled || this.gameOver) {
      this.showTimer = false;
      return;
    }
    this.stopTimer();
    this.remainingSeconds = this.timeoutSeconds;
    this.showTimer = true;
    this.timerId = setInterval(() => {
      this.remainingSeconds--;
      if (this.remainingSeconds <= 0) {
        this.stopTimer();
        this.handleTimeout();
      }
    }, 1000);
  }

  stopTimer(): void {
    this.showTimer = false;
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  handleTimeout(): void {
    if (this.gameOver) {
      return;
    }
    this.stopAnimation();
    this.gameOver = true;
    this.statusText = '超时，你输了！';
  }

  build() {
    Stack() {
      Column() {
        Text(this.statusText)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.gameOver ? (this.statusText.includes('AI') || this.statusText.includes('超时') ? '#CC6600' : '#339933') : '#333333')
          .height(32)
          .textAlign(TextAlign.Center)

        Text(this.showTimer ? `剩余 ${this.remainingSeconds}s` : '')
          .fontSize(14)
          .fontColor(this.remainingSeconds <= 10 ? '#CC0000' : '#999999')
          .height(20)
          .textAlign(TextAlign.Center)

        Canvas(this.context)
          .width(this.CELL_SIZE * (this.BOARD_SIZE - 1) + this.PADDING * 2)
          .height(this.CELL_SIZE * (this.BOARD_SIZE - 1) + this.PADDING * 2)
          .onReady(() => {
            this.boardReady = true;
            this.drawBoard();
          })
          .onClick((event: ClickEvent) => {
            this.handleClick(event.x, event.y);
          })

        Button('重新开始')
          .margin({ top: 16 })
          .fontSize(18)
          .backgroundColor('#4A90D9')
          .fontColor(Color.White)
          .borderRadius(8)
          .padding({ left: 24, right: 24, top: 10, bottom: 10 })
          .onClick(() => {
            this.initGame();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 12, bottom: 12 })

      Button() {
        Text('⚙')
          .fontSize(28)
      }
      .type(ButtonType.Normal)
      .backgroundColor(Color.Transparent)
      .width(48)
      .height(48)
      .margin({ top: 12, right: 8 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/Settings' });
      })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.TopEnd)
    .backgroundColor('#F5F0E8')
  }
}
