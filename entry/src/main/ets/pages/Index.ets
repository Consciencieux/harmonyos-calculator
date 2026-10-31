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
      Blank()
        .layoutWeight(1)
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
    .width('100%')
  }

  @Builder
  keyButton(wide: boolean, label: Resource, action: string, role: string) {
    if (role === 'operator') {
      this.keyFace(wide, label, action, $r('app.color.key_operator_background'), $r('app.color.key_operator_text'))
    } else if (role === 'equal') {
      this.keyFace(wide, label, action, $r('app.color.key_equal_background'), $r('app.color.key_equal_text'))
    } else if (role === 'function') {
      this.keyFace(wide, label, action, $r('app.color.key_function_background'), $r('app.color.key_function_text'))
    } else {
      this.keyFace(wide, label, action, $r('app.color.key_number_background'), $r('app.color.key_number_text'))
    }
  }

  @Builder
  keyFace(wide: boolean, label: Resource, action: string, background: Resource, foreground: Resource) {
    Column() {
      Button(label, { type: ButtonType.Normal, stateEffect: true })
        .width('100%')
        .height('100%')
        .padding(0)
        .fontSize($r('app.float.key_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor(foreground)
        .backgroundColor(background)
        .borderRadius(wide ? $r('app.float.key_radius') : '50%')
        .onClick(() => {
          this.onKey(action)
        })
    }
    .layoutWeight(wide ? 2 : 1)
    .aspectRatio(wide ? 2 : 1)
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
