import { CALC_ERROR, Calculator } from '../calculator/Calculator'

@Entry
@Component
struct Index {
  @State displayText: string = '0'
  @State expressionText: string = ''
  @State hasError: boolean = false
  private calculator: Calculator = new Calculator()

  build() {
    Column() {
      this.resultPanel()
      this.keypad()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .padding($r('app.float.page_padding'))
  }

  @Builder
  resultPanel() {
    Column() {
      Text(this.expressionText)
        .width('100%')
        .height($r('app.float.expression_line_height'))
        .fontSize($r('app.float.expression_font_size'))
        .fontColor($r('app.color.expression_text'))
        .textAlign(TextAlign.End)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (this.hasError) {
        Text($r('app.string.calc_error'))
          .width('100%')
          .height($r('app.float.display_line_height'))
          .fontSize($r('app.float.display_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.calc_error'))
          .textAlign(TextAlign.End)
          .maxLines(1)
      } else {
        Text(this.displayText)
          .width('100%')
          .height($r('app.float.display_line_height'))
          .fontSize($r('app.float.display_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.display_text'))
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .layoutWeight(2)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.End)
    .padding({
      left: $r('app.float.key_gap'),
      right: $r('app.float.key_gap'),
      bottom: $r('app.float.display_bottom_gap')
    })
  }

  @Builder
  keypad() {
    Column() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
        this.keyButton($r('app.string.key_clear'), 'clear', 2, 'function')
        this.keyButton($r('app.string.key_backspace'), 'backspace', 1, 'function')
        this.keyButton($r('app.string.key_divide'), 'divide', 1, 'operator')
      }
      .layoutWeight(1)
      .width('100%')

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
        this.keyButton($r('app.string.key_7'), '7', 1, 'number')
        this.keyButton($r('app.string.key_8'), '8', 1, 'number')
        this.keyButton($r('app.string.key_9'), '9', 1, 'number')
        this.keyButton($r('app.string.key_multiply'), 'multiply', 1, 'operator')
      }
      .layoutWeight(1)
      .width('100%')

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
        this.keyButton($r('app.string.key_4'), '4', 1, 'number')
        this.keyButton($r('app.string.key_5'), '5', 1, 'number')
        this.keyButton($r('app.string.key_6'), '6', 1, 'number')
        this.keyButton($r('app.string.key_subtract'), 'subtract', 1, 'operator')
      }
      .layoutWeight(1)
      .width('100%')

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
        this.keyButton($r('app.string.key_1'), '1', 1, 'number')
        this.keyButton($r('app.string.key_2'), '2', 1, 'number')
        this.keyButton($r('app.string.key_3'), '3', 1, 'number')
        this.keyButton($r('app.string.key_add'), 'add', 1, 'operator')
      }
      .layoutWeight(1)
      .width('100%')

      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Stretch }) {
        this.keyButton($r('app.string.key_0'), '0', 2, 'number')
        this.keyButton($r('app.string.key_dot'), 'dot', 1, 'number')
        this.keyButton($r('app.string.key_equal'), 'equal', 1, 'equal')
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .layoutWeight(5)
  }

  @Builder
  keyButton(label: Resource, action: string, weight: number, role: string) {
    if (role === 'operator') {
      this.keyFace(label, action, weight, $r('app.color.key_operator_background'), $r('app.color.key_operator_text'))
    } else if (role === 'equal') {
      this.keyFace(label, action, weight, $r('app.color.key_equal_background'), $r('app.color.key_equal_text'))
    } else if (role === 'function') {
      this.keyFace(label, action, weight, $r('app.color.key_function_background'), $r('app.color.key_function_text'))
    } else {
      this.keyFace(label, action, weight, $r('app.color.key_number_background'), $r('app.color.key_number_text'))
    }
  }

  @Builder
  keyFace(label: Resource, action: string, weight: number, background: Resource, foreground: Resource) {
    Column() {
      Button(label, { type: ButtonType.Normal, stateEffect: true })
        .width('100%')
        .height('100%')
        .padding(0)
        .fontSize($r('app.float.key_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor(foreground)
        .backgroundColor(background)
        .borderRadius($r('app.float.key_radius'))
        .onClick(() => {
          this.onKey(action)
        })
    }
    .layoutWeight(weight)
    .height('100%')
    .padding($r('app.float.key_gap'))
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
