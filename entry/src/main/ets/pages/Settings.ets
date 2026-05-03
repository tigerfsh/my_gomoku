import router from '@ohos.router';

@Entry
@Component
struct Settings {
  @State humanFirst: boolean = true;
  @State humanColor: number = 1;

  aboutToAppear(): void {
    let first = AppStorage.get<string>('gomoku_human_first');
    if (first === 'false') {
      this.humanFirst = false;
    } else {
      this.humanFirst = true;
    }
    let color = AppStorage.get<string>('gomoku_human_color');
    if (color === '2') {
      this.humanColor = 2;
    } else {
      this.humanColor = 1;
    }
  }

  build() {
    Column() {
      Row() {
        Text('◁')
          .fontSize(22)
          .fontColor('#333333')
          .width(40)
          .height(40)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })

        Text('游戏设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })

        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      Column() {
        Text('先手方')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 12 })

        Row({ space: 12 }) {
          Button('人类')
            .fontSize(16)
            .fontColor(this.humanFirst ? Color.White : '#333333')
            .backgroundColor(this.humanFirst ? '#4A90D9' : '#E8E8E8')
            .borderRadius(8)
            .padding({ left: 32, right: 32, top: 10, bottom: 10 })
            .onClick(() => {
              this.humanFirst = true;
            })

          Button('机器')
            .fontSize(16)
            .fontColor(!this.humanFirst ? Color.White : '#333333')
            .backgroundColor(!this.humanFirst ? '#4A90D9' : '#E8E8E8')
            .borderRadius(8)
            .padding({ left: 32, right: 32, top: 10, bottom: 10 })
            .onClick(() => {
              this.humanFirst = false;
            })
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 16, bottom: 16 })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 16 })

      Column() {
        Text('执棋颜色')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .margin({ bottom: 12 })

        Row({ space: 12 }) {
          Button('黑棋')
            .fontSize(16)
            .fontColor(this.humanColor === 1 ? Color.White : '#333333')
            .backgroundColor(this.humanColor === 1 ? '#000000' : '#E8E8E8')
            .borderRadius(8)
            .padding({ left: 32, right: 32, top: 10, bottom: 10 })
            .onClick(() => {
              this.humanColor = 1;
            })

          Button('白棋')
            .fontSize(16)
            .fontColor(this.humanColor === 2 ? '#333333' : '#333333')
            .backgroundColor(this.humanColor === 2 ? '#FFFFFF' : '#E8E8E8')
            .borderRadius(8)
            .padding({ left: 32, right: 32, top: 10, bottom: 10 })
            .border({ width: this.humanColor === 2 ? 2 : 1, color: this.humanColor === 2 ? '#4A90D9' : '#CCCCCC' })
            .onClick(() => {
              this.humanColor = 2;
            })
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 16, bottom: 16 })
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ left: 16, right: 16, top: 16 })

      Blank()

      Button('保存配置')
        .fontSize(18)
        .width('90%')
        .height(48)
        .backgroundColor('#4A90D9')
        .fontColor(Color.White)
        .borderRadius(24)
        .margin({ bottom: 32 })
        .onClick(() => {
          AppStorage.setOrCreate('gomoku_human_first', this.humanFirst ? 'true' : 'false');
          AppStorage.setOrCreate('gomoku_human_color', this.humanColor === 1 ? '1' : '2');
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
