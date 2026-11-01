import { display, uiMaterial, window } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { CALC_ERROR, Calculator } from '../calculator/Calculator'

const HANDSET_MAX_WIDTH: number = 600
const MAX_CELL_SIZE: number = 112
const MIN_CELL_SIZE: number = 32
const LANDSCAPE_VERTICAL_INSET: number = 24
const DISPLAY_MIN_FONT_SIZE: number = 24
const EXPRESSION_MIN_FONT_SIZE: number = 12

@Entry
@Component
struct Index {
  @State displayText: string = '0'
  @State expressionText: string = ''
  @State hasError: boolean = false
  @State paneWidth: number = 0
  @State paneHeight: number = 0
  private areaMeasured: boolean = false
  private calculator: Calculator = new Calculator()
  private numberMaterial: uiMaterial.ImmersiveMaterial =
    this.createKeyMaterial($r('app.color.key_number_material'))
  private functionMaterial: uiMaterial.ImmersiveMaterial =
    this.createKeyMaterial($r('app.color.key_function_material'))
  private operatorMaterial: uiMaterial.ImmersiveMaterial =
    this.createKeyMaterial($r('app.color.key_operator_material'))
  private equalMaterial: uiMaterial.ImmersiveMaterial =
    this.createKeyMaterial($r('app.color.key_equal_material'))

  aboutToAppear(): void {
    this.readWindowSize()
  }

  build() {
    if (this.isLandscape()) {
      this.landscapePage()
    } else {
      this.portraitPage()
    }
  }

  @Builder
  portraitPage() {
    Tabs() {
      TabContent() {
        Column() {
          Blank()
            .layoutWeight(1)
          this.resultPanel()
        }
        .width('100%')
        .height('100%')
        .alignItems(this.isHandsetPortrait() ? HorizontalAlign.End : HorizontalAlign.Center)
        .padding({
          left: $r('app.float.page_padding'),
          right: $r('app.float.page_padding'),
          top: $r('app.float.page_padding')
        })
      }
      .tabBar(this.portraitKeypad())
    }
    .barPosition(BarPosition.End)
    .barMode(BarMode.Fixed)
    .barHeight('auto')
    .scrollable(false)
    .barBackgroundColor(Color.Transparent)
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      this.updatePane(newArea)
    })
  }

  @Builder
  landscapePage() {
    Row() {
      Column() {
        Blank()
          .layoutWeight(1)
        this.resultPanel()
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({ right: $r('app.float.page_padding') })

      this.keypad()
    }
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.End)
    .backgroundColor($r('app.color.page_background'))
    .padding($r('app.float.page_padding'))
    .onAreaChange((_oldArea: Area, newArea: Area) => {
      this.updatePane(newArea)
    })
  }

  @Builder
  portraitKeypad() {
    Column() {
      this.keypad()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  resultPanel() {
    Column() {
      if (this.isHandsetPortrait()) {
        this.expressionLine($r('app.float.expression_font_size'), $r('app.float.expression_line_height'))
        if (this.hasError) {
          this.errorLine($r('app.float.display_font_size'), $r('app.float.display_line_height'))
        } else {
          this.displayLine($r('app.float.display_font_size'), $r('app.float.display_line_height'))
        }
      } else {
        this.expressionLine(this.expressionFontSize(), this.expressionLineHeight())
        if (this.hasError) {
          this.errorLine(this.displayFontSize(), this.displayLineHeight())
        } else {
          this.displayLine(this.displayFontSize(), this.displayLineHeight())
        }
      }
    }
    .width(this.isHandsetPortrait() || this.isLandscape() ? '100%' : this.cellSize() * 4)
    .alignItems(HorizontalAlign.End)
    .padding({
      left: $r('app.float.key_gap'),
      right: $r('app.float.key_gap'),
      bottom: $r('app.float.display_bottom_gap')
    })
  }

  @Builder
  expressionLine(fontSize: number | Resource, lineHeight: number | Resource) {
    Text(this.expressionText)
      .width('100%')
      .height(lineHeight)
      .maxFontSize(fontSize)
      .minFontSize(EXPRESSION_MIN_FONT_SIZE)
      .fontColor($r('app.color.expression_text'))
      .textAlign(TextAlign.End)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  @Builder
  displayLine(fontSize: number | Resource, lineHeight: number | Resource) {
    Text(this.displayText)
      .width('100%')
      .height(lineHeight)
      .maxFontSize(fontSize)
      .minFontSize(DISPLAY_MIN_FONT_SIZE)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.display_text'))
      .textAlign(TextAlign.End)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  @Builder
  errorLine(fontSize: number | Resource, lineHeight: number | Resource) {
    Text($r('app.string.calc_error'))
      .width('100%')
      .height(lineHeight)
      .fontSize(fontSize)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.calc_error'))
      .textAlign(TextAlign.End)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  @Builder
  keypad() {
    Column() {
      Row() {
        this.keyButton(true, $r('app.string.key_clear'), 'clear', 'function')
        this.keyButton(false, $r('app.string.key_backspace'), 'backspace', 'function')
        this.keyButton(false, $r('app.string.key_divide'), 'divide', 'operator')
      }
      .width('100%')

      Row() {
        this.keyButton(false, $r('app.string.key_7'), '7', 'number')
        this.keyButton(false, $r('app.string.key_8'), '8', 'number')
        this.keyButton(false, $r('app.string.key_9'), '9', 'number')
        this.keyButton(false, $r('app.string.key_multiply'), 'multiply', 'operator')
      }
      .width('100%')

      Row() {
        this.keyButton(false, $r('app.string.key_4'), '4', 'number')
        this.keyButton(false, $r('app.string.key_5'), '5', 'number')
        this.keyButton(false, $r('app.string.key_6'), '6', 'number')
        this.keyButton(false, $r('app.string.key_subtract'), 'subtract', 'operator')
      }
      .width('100%')

      Row() {
        this.keyButton(false, $r('app.string.key_1'), '1', 'number')
        this.keyButton(false, $r('app.string.key_2'), '2', 'number')
        this.keyButton(false, $r('app.string.key_3'), '3', 'number')
        this.keyButton(false, $r('app.string.key_add'), 'add', 'operator')
      }
      .width('100%')

      Row() {
        this.keyButton(true, $r('app.string.key_0'), '0', 'number')
        this.keyButton(false, $r('app.string.key_dot'), 'dot', 'number')
        this.keyButton(false, $r('app.string.key_equal'), 'equal', 'equal')
      }
      .width('100%')
    }
    .width(this.isHandsetPortrait() ? '100%' : this.cellSize() * 4)
    .padding({
      left: this.isHandsetPortrait() ? $r('app.float.page_padding') : 0,
      right: this.isHandsetPortrait() ? $r('app.float.page_padding') : 0,
      bottom: this.isLandscape() ? 0 : $r('app.float.page_padding')
    })
  }

  @Builder
  keyButton(wide: boolean, label: Resource, action: string, role: string) {
    if (role === 'operator') {
      this.keyFace(wide, label, action, $r('app.color.key_operator_background'), $r('app.color.key_operator_text'),
        this.operatorMaterial)
    } else if (role === 'equal') {
      this.keyFace(wide, label, action, $r('app.color.key_equal_background'), $r('app.color.key_equal_text'),
        this.equalMaterial)
    } else if (role === 'function') {
      this.keyFace(wide, label, action, $r('app.color.key_function_background'), $r('app.color.key_function_text'),
        this.functionMaterial)
    } else {
      this.keyFace(wide, label, action, $r('app.color.key_number_background'), $r('app.color.key_number_text'),
        this.numberMaterial)
    }
  }

  @Builder
  keyFace(wide: boolean, label: Resource, action: string, background: Resource, foreground: Resource,
    material: uiMaterial.ImmersiveMaterial) {
    Column() {
      Button(label, { type: ButtonType.Normal, stateEffect: true })
        .width('100%')
        .height('100%')
        .padding(0)
        .fontSize(this.isHandsetPortrait() ? $r('app.float.key_font_size') : this.keyFontSize())
        .fontWeight(FontWeight.Medium)
        .fontColor(foreground)
        .backgroundColor(background)
        .borderRadius(this.keyRadius(wide))
        .systemMaterial(material)
        .onClick(() => {
          this.onKey(action)
        })
    }
    .layoutWeight(wide ? 2 : 1)
    .aspectRatio(wide ? 2 : 1)
    .padding($r('app.float.key_gap'))
  }

  private createKeyMaterial(tint: Resource): uiMaterial.ImmersiveMaterial {
    const light: uiMaterial.LightEffectOptions = { color: Color.White }
    const options: uiMaterial.ImmersiveOptions = {
      style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
      materialColor: tint,
      colorInvert: false,
      applyShadow: true,
      interactive: true,
      lightEffect: light
    }
    return new uiMaterial.ImmersiveMaterial(options)
  }

  private readWindowSize(): void {
    try {
      window.getLastWindow(getContext(this)).then((win: window.Window) => {
        const rect = win.getWindowProperties().windowRect
        const uiContext = this.getUIContext()
        this.applyInitialSize(uiContext.px2vp(rect.width), uiContext.px2vp(rect.height))
      }).catch((_error: BusinessError) => {
        this.readScreenSize()
      })
    } catch (_error) {
      this.readScreenSize()
    }
  }

  private readScreenSize(): void {
    try {
      const screen = display.getDefaultDisplaySync()
      const density = screen.densityPixels > 0 ? screen.densityPixels : 1
      this.applyInitialSize(screen.width / density, screen.height / density)
    } catch (_error) {
      this.applyInitialSize(0, 0)
    }
  }

  private applyInitialSize(width: number, height: number): void {
    // 窗口尺寸只是首帧的估值，区域测量一到就以实测为准，避免异步回调把实测结果盖回去
    if (this.areaMeasured || width <= 0 || height <= 0) {
      return
    }
    this.paneWidth = width
    this.paneHeight = height
  }

  private updatePane(area: Area): void {
    const width = this.lengthToVp(area.width)
    const height = this.lengthToVp(area.height)
    if (width <= 0 || height <= 0) {
      return
    }
    this.areaMeasured = true
    if (width !== this.paneWidth || height !== this.paneHeight) {
      this.paneWidth = width
      this.paneHeight = height
    }
  }

  private lengthToVp(value: Length): number {
    if (typeof value === 'number') {
      return value
    }
    if (typeof value === 'string') {
      const parsed = parseFloat(value)
      return Number.isFinite(parsed) ? parsed : 0
    }
    return 0
  }

  private isLandscape(): boolean {
    return this.paneWidth > this.paneHeight && this.paneHeight > 0
  }

  private isHandsetPortrait(): boolean {
    return !this.isLandscape() && (this.paneWidth <= 0 || this.paneWidth < HANDSET_MAX_WIDTH)
  }

  private cellSize(): number {
    if (this.isLandscape()) {
      const byHeight = (this.paneHeight - LANDSCAPE_VERTICAL_INSET) / 5
      const byWidth = (this.paneWidth * 0.46) / 4
      return Math.max(Math.min(byHeight, byWidth), MIN_CELL_SIZE)
    }
    return Math.max(Math.min(this.paneWidth / 4, MAX_CELL_SIZE), MIN_CELL_SIZE)
  }

  private keyFontSize(): number {
    return this.clamp(this.cellSize() * 0.32, 20, 40)
  }

  private expressionFontSize(): number {
    return this.clamp(this.displayFontSize() * 0.4, 18, 32)
  }

  private expressionLineHeight(): number {
    return this.expressionFontSize() * 1.4
  }

  private displayFontSize(): number {
    if (this.isLandscape()) {
      return this.clamp(this.paneHeight * 0.16, 40, 84)
    }
    return this.clamp(this.cellSize() * 0.62, 48, 72)
  }

  private displayLineHeight(): number {
    return this.displayFontSize() * 1.28
  }

  private keyRadius(wide: boolean): number | string | Resource {
    if (!wide) {
      return '50%'
    }
    if (this.isHandsetPortrait()) {
      return $r('app.float.key_radius')
    }
    return this.clamp(this.cellSize() * 0.2, 16, 36)
  }

  private clamp(value: number, min: number, max: number): number {
    if (value < min) {
      return min
    }
    if (value > max) {
      return max
    }
    return value
  }

  private onKey(action: string): void {
    if (action === 'clear') {
      this.calculator.clear()
    } else if (action === 'backspace') {
      this.calculator.backspace()
    } else if (action === 'dot') {
      this.calculator.inputDot()
    } else if (action === 'equal') {
      this.calculator.equals()
    } else if (action === 'add') {
      this.calculator.inputOperator('+')
    } else if (action === 'subtract') {
      this.calculator.inputOperator('-')
    } else if (action === 'multiply') {
      this.calculator.inputOperator('×')
    } else if (action === 'divide') {
      this.calculator.inputOperator('÷')
    } else {
      this.calculator.inputDigit(action)
    }
    this.syncView()
  }

  private syncView(): void {
    this.expressionText = this.calculator.getExpression()
    this.hasError = this.calculator.getStatus() === CALC_ERROR
    if (!this.hasError) {
      this.displayText = this.calculator.getDisplay()
    }
  }
}
