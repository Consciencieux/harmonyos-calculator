import { describe, it, expect } from '@ohos/hypium'
import { CALC_ERROR, CALC_OK, Calculator } from '../main/ets/calculator/Calculator'

function press(calc: Calculator, sequence: string): void {
  for (let i = 0; i < sequence.length; i++) {
    const key = sequence.substring(i, i + 1)
    if (key >= '0' && key <= '9') {
      calc.inputDigit(key)
    } else if (key === '.') {
      calc.inputDot()
    } else if (key === '+') {
      calc.inputOperator('+')
    } else if (key === '-') {
      calc.inputOperator('-')
    } else if (key === '*') {
      calc.inputOperator('×')
    } else if (key === '/') {
      calc.inputOperator('÷')
    } else if (key === '=') {
      calc.equals()
    } else if (key === 'C') {
      calc.clear()
    } else if (key === '<') {
      calc.backspace()
    }
  }
}

export default function localUnitTest() {
  describe('calculator', () => {
    it('addsAndSubtracts', 0, () => {
      const calc = new Calculator()
      press(calc, '12+3=')
      expect(calc.getDisplay()).assertEqual('15')
      expect(calc.getExpression()).assertEqual('12 + 3 =')
      expect(calc.getStatus()).assertEqual(CALC_OK)

      press(calc, 'C1-5=')
      expect(calc.getDisplay()).assertEqual('-4')
      expect(calc.getExpression()).assertEqual('1 - 5 =')

      press(calc, 'C1+2+3=')
      expect(calc.getDisplay()).assertEqual('6')
      expect(calc.getExpression()).assertEqual('1 + 2 + 3 =')

      press(calc, 'C10-3-2=')
      expect(calc.getDisplay()).assertEqual('5')
    })

    it('multipliesBeforeAdding', 0, () => {
      const calc = new Calculator()
      press(calc, '2+3*4=')
      expect(calc.getDisplay()).assertEqual('14')
      expect(calc.getExpression()).assertEqual('2 + 3 × 4 =')

      press(calc, 'C9-3*2=')
      expect(calc.getDisplay()).assertEqual('3')

      press(calc, 'C8/2+1=')
      expect(calc.getDisplay()).assertEqual('5')
    })

    it('dividesAndRoundsDecimals', 0, () => {
      const calc = new Calculator()
      press(calc, '7/2=')
      expect(calc.getDisplay()).assertEqual('3.5')

      press(calc, 'C0.1+0.2=')
      expect(calc.getDisplay()).assertEqual('0.3')

      press(calc, 'C1..2')
      expect(calc.getDisplay()).assertEqual('1.2')

      press(calc, 'C1.2.3')
      expect(calc.getDisplay()).assertEqual('1.23')
    })

    it('rejectsDivideByZeroThenRecovers', 0, () => {
      const calc = new Calculator()
      press(calc, '8/0=')
      expect(calc.getStatus()).assertEqual(CALC_ERROR)
      expect(calc.getExpression()).assertEqual('8 ÷ 0')

      press(calc, '1')
      expect(calc.getStatus()).assertEqual(CALC_OK)
      expect(calc.getDisplay()).assertEqual('1')
      expect(calc.getExpression()).assertEqual('')
    })

    it('editsInputAndContinuesFromResult', 0, () => {
      const calc = new Calculator()
      press(calc, '12<')
      expect(calc.getDisplay()).assertEqual('1')

      press(calc, 'C12+<')
      expect(calc.getDisplay()).assertEqual('12')
      expect(calc.getExpression()).assertEqual('')

      press(calc, 'C8+*2=')
      expect(calc.getDisplay()).assertEqual('16')
      expect(calc.getExpression()).assertEqual('8 × 2 =')

      press(calc, '+3=')
      expect(calc.getDisplay()).assertEqual('19')
      expect(calc.getExpression()).assertEqual('16 + 3 =')

      press(calc, '9')
      expect(calc.getDisplay()).assertEqual('9')
      expect(calc.getExpression()).assertEqual('')
    })

    it('repeatsOperandWhenEqualsFollowsOperator', 0, () => {
      const calc = new Calculator()
      press(calc, '1+=')
      expect(calc.getDisplay()).assertEqual('2')
      expect(calc.getExpression()).assertEqual('1 + 1 =')
    })

    it('backsOutOfNegativeResultWithoutLoneSign', 0, () => {
      const calc = new Calculator()
      press(calc, '4-9=')
      expect(calc.getDisplay()).assertEqual('-5')

      press(calc, '<')
      expect(calc.getDisplay()).assertEqual('0')

      press(calc, '<')
      expect(calc.getDisplay()).assertEqual('0')

      press(calc, '5')
      expect(calc.getDisplay()).assertEqual('5')
      expect(calc.getExpression()).assertEqual('')
    })

    it('dropsTrailingDotBeforeOperator', 0, () => {
      const calc = new Calculator()
      press(calc, '3.+2=')
      expect(calc.getExpression()).assertEqual('3 + 2 =')
      expect(calc.getDisplay()).assertEqual('5')
    })
  })
}
