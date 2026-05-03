@Entry
@Component
struct Index {
  @State statusText: string = '黑棋回合';
  @State gameOver: boolean = false;

  private board: number[][] = [];
  private currentPlayer: number = 1;
  private readonly BOARD_SIZE: number = 15;
  private readonly CELL_SIZE: number = 22;
  private readonly PADDING: number = 16;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    this.initGame();
  }

  initGame(): void {
    this.board = [];
    for (let i = 0; i < this.BOARD_SIZE; i++) {
      this.board[i] = [];
      for (let j = 0; j < this.BOARD_SIZE; j++) {
        this.board[i][j] = 0;
      }
    }
    this.currentPlayer = 1;
    this.gameOver = false;
    this.statusText = '黑棋回合';
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

    this.board[col][row] = this.currentPlayer;

    if (this.checkWin(col, row)) {
      this.gameOver = true;
      this.statusText = this.currentPlayer === 1 ? '黑棋获胜！' : '白棋获胜！';
    } else {
      this.currentPlayer = this.currentPlayer === 1 ? 2 : 1;
      this.statusText = this.currentPlayer === 1 ? '黑棋回合' : '白棋回合';
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

  build() {
    Column() {
      Text(this.statusText)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
        .fontColor(this.gameOver ? '#CC0000' : '#333333')

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
    .backgroundColor('#F5F0E8')
  }
}