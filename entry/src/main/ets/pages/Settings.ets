import router from '@ohos.router';

@Entry
@Component
struct Settings {
  @State humanFirst: boolean = true;
  @State humanColor: number = 1;
  @State enableTimeout: boolean = false;
  @State timeoutSeconds: number = 60;

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
    let to = AppStorage.get<string>('gomoku_enable_timeout');
    if (to === 'true') {
      this.enableTimeout = true;
    } else {
      this.enableTimeout = false;
    }
    let sec = AppStorage.get<string>('gomoku_timeout_seconds');
    if (sec !== undefined && sec !== null && sec !== '') {
      let val = parseInt(sec);
      if (val >= 10 && val <= 180) {
        this.timeoutSeconds = val;
      }
    }
  }

  build() {
    Column() {
      Row() {
        Button('← 返回')
          .fontSize(16)
          .fontColor('#4A90D9')
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 12, top: 8, bottom: 8 })
          .onClick(() => {
            router.back();
          })

        Text('游戏设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)

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

      Column() {
        Row() {
          Text('单回合超时')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.enableTimeout })
            .onChange((isOn: boolean) => {
              this.enableTimeout = isOn;
            })
        }
        .width('100%')
        .margin({ bottom: this.enableTimeout ? 16 : 0 })

        if (this.enableTimeout) {
          Row() {
            Text('超时时间')
              .fontSize(16)
              .fontColor('#666666')

            Text(`${this.timeoutSeconds} 秒`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#4A90D9')
              .margin({ left: 12 })
          }
          .width('100%')
          .margin({ bottom: 8 })

          Slider({
            value: this.timeoutSeconds,
            min: 10,
            max: 180,
            step: 5
          })
            .width('100%')
            .trackColor('#4A90D9')
            .selectedColor('#4A90D9')
            .showSteps(true)
            .onChange((value: number) => {
              this.timeoutSeconds = value;
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
          AppStorage.setOrCreate('gomoku_enable_timeout', this.enableTimeout ? 'true' : 'false');
          AppStorage.setOrCreate('gomoku_timeout_seconds', this.timeoutSeconds.toString());
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
