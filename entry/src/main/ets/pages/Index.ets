import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State statusText: string = '你的回合';
  @State gameOver: boolean = false;

  private board: number[][] = [];
  private currentPlayer: number = 1;
  private humanColor: number = 1;
  private aiColor: number = 2;
  private readonly BOARD_SIZE: number = 15;
  private readonly CELL_SIZE: number = 22;
  private readonly PADDING: number = 16;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.loadConfig();
    this.initGame();
  }

  onPageShow(): void {
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
  }

  initGame(): void {
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
    this.drawBoard();
  }

  drawBoard(): void {
    let ctx = this.context;
    let boardWidth = this.CELL_SIZE * (this.BOARD_SIZE - 1) + this.PADDING * 2;
    let boardHeight = boardWidth;

    ctx.clearRect(0, 0, boardWidth, boardHeight);

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

    ctx.fillStyle = '#333333';
    let starSpots = [3, 7, 11];
    for (let si = 0; si < starSpots.length; si++) {
      for (let sj = 0; sj < starSpots.length; sj++) {
        ctx.beginPath();
        ctx.arc(this.PADDING + starSpots[si] * this.CELL_SIZE,
          this.PADDING + starSpots[sj] * this.CELL_SIZE, 3, 0, Math.PI * 2);
        ctx.fill();
      }
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

    this.board[col][row] = this.aiColor;
    this.drawBoard();

    if (this.checkWin(col, row)) {
      this.gameOver = true;
      this.statusText = 'AI 赢了！';
    } else {
      this.currentPlayer = this.humanColor;
      this.statusText = '你的回合';
    }
  }

  triggerAiMove(): void {
    setTimeout(() => {
      this.aiMove();
    }, 300);
  }

  build() {
    Stack() {
      Column() {
        Text(this.statusText)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 10 })
          .fontColor(this.gameOver ? (this.statusText.includes('AI') ? '#CC6600' : '#339933') : '#333333')

        Canvas(this.context)
          .width(this.CELL_SIZE * (this.BOARD_SIZE - 1) + this.PADDING * 2)
          .height(this.CELL_SIZE * (this.BOARD_SIZE - 1) + this.PADDING * 2)
          .onReady(() => {
            this.drawBoard();
          })
          .onClick((event: ClickEvent) => {
            this.handleClick(event.x, event.y);
          })

        Button('重新开始')
          .margin({ top: 20 })
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
