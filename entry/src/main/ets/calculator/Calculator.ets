export const CALC_OK: number = 0
export const CALC_ERROR: number = 1

const MAX_DIGITS: number = 12
const MAX_PARTS: number = 40
const ROUND_SCALE: number = 10000000000
const ROUND_LIMIT: number = 1000000000000000

class Term {
  value: number = 0
  op: string = ''
}

function formatNumber(value: number): string {
  if (!Number.isFinite(value)) {
    return '0'
  }
  const rounded = Math.abs(value) < ROUND_LIMIT ? Math.round(value * ROUND_SCALE) / ROUND_SCALE : value
  if (!Number.isFinite(rounded) || rounded === 0) {
    return '0'
  }
  return rounded.toString()
}

export class Calculator {
  private expressionParts: string[] = []
  private current: string = '0'
  private currentReady: boolean = false
  private evaluated: boolean = false
  private status: number = CALC_OK

  getDisplay(): string {
    return this.current
  }

  getExpression(): string {
    let text = ''
    for (let i = 0; i < this.expressionParts.length; i++) {
      if (text.length > 0) {
        text = text + ' '
      }
      text = text + this.expressionParts[i]
    }
    if (this.evaluated && text.length > 0) {
      text = text + ' ='
    }
    return text
  }

  getStatus(): number {
    return this.status
  }

  inputDigit(digit: string): void {
    if (!this.isDigit(digit)) {
      return
    }
    this.resetIfNeeded()
    if (!this.currentReady || this.current === '0') {
      this.current = digit
      this.currentReady = true
      return
    }
    if (!this.canAppendDigit()) {
      return
    }
    this.current = this.current + digit
  }

  inputDot(): void {
    this.resetIfNeeded()
    if (!this.currentReady || this.current === '0') {
      this.current = '0.'
      this.currentReady = true
      return
    }
    if (this.current.indexOf('.') >= 0) {
      return
    }
    this.current = this.current + '.'
  }

  inputOperator(operator: string): void {
    if (!this.isOperator(operator) || this.status !== CALC_OK) {
      return
    }
    if (this.evaluated) {
      const resultText = this.current
      this.expressionParts = []
      this.expressionParts.push(resultText)
      this.expressionParts.push(operator)
      this.evaluated = false
      this.currentReady = false
      return
    }
    if (this.expressionParts.length >= MAX_PARTS) {
      return
    }
    if (this.currentReady) {
      this.expressionParts.push(this.commitText())
      this.currentReady = false
    } else if (this.expressionParts.length === 0) {
      this.expressionParts.push(this.commitText())
    } else if (this.isOperator(this.partAt(this.expressionParts.length - 1))) {
      this.expressionParts[this.expressionParts.length - 1] = operator
      return
    }
    this.expressionParts.push(operator)
  }

  equals(): void {
    if (this.status !== CALC_OK || this.evaluated) {
      return
    }
    if (this.currentReady || this.expressionParts.length === 0) {
      this.expressionParts.push(this.commitText())
      this.currentReady = false
    } else if (this.isOperator(this.partAt(this.expressionParts.length - 1))) {
      this.expressionParts.push(this.commitText())
    }
    const result = this.evaluate(this.expressionParts)
    if (result === null) {
      this.status = CALC_ERROR
      return
    }
    this.current = formatNumber(result)
    this.currentReady = false
    this.evaluated = true
  }

  clear(): void {
    this.expressionParts = []
    this.current = '0'
    this.currentReady = false
    this.evaluated = false
    this.status = CALC_OK
  }

  backspace(): void {
    if (this.status !== CALC_OK) {
      this.clear()
      return
    }
    if (this.evaluated) {
      this.expressionParts = []
      this.evaluated = false
      this.currentReady = true
      this.deleteDigit()
      return
    }
    if (this.currentReady) {
      this.deleteDigit()
      return
    }
    if (this.expressionParts.length === 0) {
      return
    }
    this.expressionParts.pop()
    if (this.expressionParts.length === 0) {
      return
    }
    const previous = this.partAt(this.expressionParts.length - 1)
    if (previous.length === 0 || this.isOperator(previous)) {
      return
    }
    this.expressionParts.pop()
    this.current = previous
    this.currentReady = true
  }

  private resetIfNeeded(): void {
    if (this.status !== CALC_OK || this.evaluated) {
      this.clear()
    }
  }

  private deleteDigit(): void {
    if (this.current.length <= 1) {
      this.current = '0'
      this.currentReady = false
      return
    }
    this.current = this.current.substring(0, this.current.length - 1)
    // 负数结果退格到只剩负号时回到 0，避免显示一个孤立负号
    if (this.current === '-') {
      this.current = '0'
      this.currentReady = false
    }
  }

  private commitText(): string {
    if (this.current.endsWith('.')) {
      return this.current.substring(0, this.current.length - 1)
    }
    return this.current
  }

  private canAppendDigit(): boolean {
    let count = 0
    for (let i = 0; i < this.current.length; i++) {
      const ch = this.current.substring(i, i + 1)
      if (this.isDigit(ch)) {
        count = count + 1
      }
    }
    return count < MAX_DIGITS
  }

  private evaluate(parts: string[]): number | null {
    const terms: Term[] = []
    let pendingOp = ''
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i]
      if (this.isOperator(part)) {
        pendingOp = part
        continue
      }
      const numeric = Number(part)
      if (!Number.isFinite(numeric)) {
        return null
      }
      const term = new Term()
      term.value = numeric
      term.op = pendingOp
      terms.push(term)
      pendingOp = ''
    }
    if (terms.length === 0) {
      return 0
    }
    return this.collapse(terms)
  }

  private collapse(terms: Term[]): number | null {
    const reduced: Term[] = []
    for (let i = 0; i < terms.length; i++) {
      const term = terms[i]
      if ((term.op === '×' || term.op === '÷') && reduced.length > 0) {
        const left = reduced[reduced.length - 1]
        if (term.op === '÷' && term.value === 0) {
          return null
        }
        if (term.op === '×') {
          left.value = left.value * term.value
        } else {
          left.value = left.value / term.value
        }
      } else {
        const next = new Term()
        next.value = term.value
        next.op = term.op
        reduced.push(next)
      }
    }
    let result = reduced[0].value
    for (let i = 1; i < reduced.length; i++) {
      const term = reduced[i]
      if (term.op === '-') {
        result = result - term.value
      } else {
        result = result + term.value
      }
    }
    if (!Number.isFinite(result)) {
      return null
    }
    return result
  }

  private partAt(index: number): string {
    if (index < 0 || index >= this.expressionParts.length) {
      return ''
    }
    return this.expressionParts[index]
  }

  private isDigit(digit: string): boolean {
    return digit.length === 1 && digit >= '0' && digit <= '9'
  }

  private isOperator(symbol: string): boolean {
    return symbol === '+' || symbol === '-' || symbol === '×' || symbol === '÷'
  }
}
