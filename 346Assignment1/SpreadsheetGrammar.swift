//
//  SpreadsheetGrammar.swift
//  346Assignment1
//
//  Created by Percy Hu on 25/08/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//
//  Provides functions (fulfill requirements and parse down) to each grammar rule

import Foundation

/** 
 The top-level GrammarRule.
 Spreadsheet -> Assignment | Print | Epsilon
 */
class GRSpreadsheet : GrammarRule {
    let myGRAssignment = GRAssignment()
    let myGRPrint = GRPrint()
    init(){
        super.init(rhsRules: [[myGRAssignment], [myGRPrint], [Epsilon.theEpsilon]])
    }
}

class GRReferenceFree : GrammarRule {
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.currentRuleSet != nil {
                var combinedString = ""
                for rule in self.currentRuleSet! {
                    if !(rule.isEpsilon() || rule is Epsilon) {
                        combinedString += rule.stringValue!
                    }
                }
                if !self.isEpsilon() {
                    self.stringValue = combinedString
                }
            }
            return rest
        }
        return nil
    }
}

/// A GrammarRule for handling: Assignment -> AbsoluteCell := Expression Spreadsheet
class GRAssignment : GRReferenceFree {
    let absCell = GRAbsoluteCell()
    let assignmentOperator = GRLiteral(literal: ":=")
    let expression = GRExpression()
    
    init() {
        super.init(rhsRule: [absCell, assignmentOperator, expression])
    }
    
    override func parse(input: String) -> String? {
        if absCell.parse(input: input) != nil {
            expression.set(ref: absCell.cellReference)
        } else {
            return nil
        }
        if let rest = super.parse(input: input) {
            let contents = CellContents(expr: expression.stringValue!, value: expression.calculatedValue)
            Cells.add(absCell.cellReference!, contents)
            let spreadsheet = GRSpreadsheet()
            if let restOfRest = spreadsheet.parse(input: rest) {
                currentRuleSet?.append(spreadsheet)
                return restOfRest
            }
            return rest
        }
        return nil
    }
}

/// A GrammarRule for handling: Print -> print_value Expression Spreadsheet |
///                                      print_expr  Expression Spreadsheet
class GRPrint : GRReferenceFree {
    let printValue = GRLiteral(literal: "print_value")
    let printExpr = GRLiteral(literal: "print_expr")
    let expression = GRExpression()
    
    init() {
        super.init(rhsRules: [[printValue, expression], [printExpr, expression]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let cell = Cells.reGet(expression.stringValue!) {
                if(currentRuleSet?[0] === printExpr) {
                    print("Expression in cell \(expression.stringValue!) is \(cell.expr)")
                } else {
                    print("Value of cell \(expression.stringValue!) is \(cell.value.describing())")
                }
            } else {
                if(currentRuleSet?[0] === printExpr) {
                    print("Expression is \(expression.stringValue!)")
                } else {
                    print("Value is \(expression.calculatedValue.describing())")
                }
            }
            let spreadsheet = GRSpreadsheet()
            if let restOfRest = spreadsheet.parse(input: rest) {
                currentRuleSet?.append(spreadsheet)
                return restOfRest
            }
            return rest
        }
        return nil
    }
}

class GRReferenceNeeded : GRReferenceFree {
    var ref : CellReference?
    
    func set(ref: CellReference?) {
        self.ref = ref
        for ruleChoice in self.rhs {
            for rule in ruleChoice {
                if let contextRule = rule as? GRReferenceNeeded {
                    contextRule.set(ref: ref)
                }
            }
        }
    }
    
    override func stateReset() {
        super.stateReset()
        self.ref = nil
    }
}

/// A GrammarRule for handling: Expression -> ProductTerm ExpressionTail | QuotedString
class GRExpression : GRReferenceNeeded {
    let productTerm = GRProductTerm()
    let exprTail = GRExpressionTail()
    let quotedString = GRQuotedString()

    init(){
        super.init(rhsRules: [[productTerm, exprTail], [quotedString]])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input:input) {
            if(self.currentRuleSet!.contains(where: {$0 === quotedString})) {
                self.calculatedValue.assign(string: quotedString.stringValue!)
                return rest
            }
            if exprTail.isEpsilon() {
                self.calculatedValue = productTerm.calculatedValue.copy()
            } else {
                self.calculatedValue = productTerm.calculatedValue + exprTail.calculatedValue
            }
            return rest
        }
        self.stateReset()
        return nil
    }
}

/// A GrammarRule for handling: ExpressionTail -> "+" ProductTerm ExpressionTail | Epsilon
class GRExpressionTail : GRReferenceNeeded {
    let plus = GRLiteral(literal: "+")
    let productTerm = GRProductTerm()
    
    init(){
        super.init(rhsRules: [[plus, productTerm], [Epsilon.theEpsilon]])
    }

    override func parse(input: String) -> String? {
        // first parse
        if let rest = super.parse(input: input) {
            if self.isEpsilon() {
                return input
            }
            self.calculatedValue = productTerm.calculatedValue.copy()
            let exprTail = GRExpressionTail()
            // second parse
            if let restOfRest = exprTail.parse(input: rest) {
                self.currentRuleSet?.append(exprTail)
                if exprTail.isEpsilon() {
                    return rest
                }
                self.calculatedValue += exprTail.calculatedValue
                self.stringValue! += exprTail.stringValue!
                return restOfRest
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling QuotedString -> " StringNoQuote "
class GRQuotedString : GRReferenceFree {
    let quotation = GRLiteral(literal: "\"")
    let stringNoQuote = GRStringNoQuote()
    
    init() {
        super.init(rhsRule: [quotation, stringNoQuote, quotation])
    }
}

/// A Grammar Rule for handling ProductTerm -> Integer ProductTermTail
class GRProductTerm : GRReferenceNeeded {
    let value = GRValue()
    let productTermTail = GRProductTermTail()
    
    init(){
        super.init(rhsRule: [value, productTermTail])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input:input) {
            if productTermTail.isEpsilon(){
              self.calculatedValue = value.calculatedValue.copy()
            } else {
              self.calculatedValue = value.calculatedValue * productTermTail.calculatedValue
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling ProductTermTail -> "*" Value ProductTermTail | epsilon
class GRProductTermTail : GRReferenceNeeded {
    let times = GRLiteral(literal: "*")
    let value = GRValue()
    
    init() {
        super.init(rhsRules: [[times, value], [Epsilon.theEpsilon]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if self.isEpsilon() {
                return input
            }
            self.calculatedValue = value.calculatedValue.copy()
            let productTermTail = GRProductTermTail()
            if let restOfRest = productTermTail.parse(input: rest) {
                self.currentRuleSet?.append(productTermTail)
                if productTermTail.isEpsilon(){
                    return rest
                }
                self.calculatedValue *= productTermTail.calculatedValue
                self.stringValue! += productTermTail.stringValue!
                self.currentRuleSet?.append(productTermTail)
                return restOfRest
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling Value -> CellReference | Integer
class GRValue : GRReferenceNeeded {
    let cellRef = GRCellReference()
    let num = GRInteger()
    
    init() {
        super.init(rhsRules: [[cellRef], [num]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let cell = currentRuleSet?[0] as? GRCell {
                self.calculatedValue = Cells.reGet(cell.cellReference!).value.copy()
            } else {
                self.calculatedValue = num.calculatedValue.copy()
            }
            return rest
        }
        return nil
    }
}

/// A subclass of GRRefereceNeeded for resetting states
class GRCell : GRReferenceNeeded {
    var cellReference: CellReference?
    
    override func stateReset() {
        super.stateReset()
        cellReference = nil
    }
}

/// A Grammar Rule for handling CellReference -> AbsoluteCell | RelativeCell
class GRCellReference : GRCell {
    let absCell = GRAbsoluteCell()
    let relCell = GRRelativeCell()
    
    init() {
        super.init(rhsRules: [[absCell], [relCell]])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let cell = currentRuleSet?[0] as? GRCell {
                cellReference = cell.cellReference
            }
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling AbsoluteCell -> ColumnLabel RowNumber
class GRAbsoluteCell : GRCell {
    let colLabel = GRColumnLabel()
    let rowNum = GRRowNumber()
    
    init() {
        super.init(rhsRule: [colLabel, rowNum])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            cellReference = CellReference(colLabel: colLabel.stringValue!, rowNum: rowNum.calculatedValue.get()!)
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling ColumnLabel -> UpperAlphaString
class GRColumnLabel : GRReferenceFree {
    let upperAlphaStr = GRUpperAlphaString()
    init() {
        super.init(rhsRule: [upperAlphaStr])
    }
}

/// A Grammar Rule for handling RowNumber -> PositiveInteger
class GRRowNumber : GRReferenceFree {
    let positiveInt = GRPositiveInteger()
    init() {
        super.init(rhsRule: [positiveInt])
    }
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            self.calculatedValue = positiveInt.calculatedValue.copy()
            return rest
        }
        return nil
    }
}

/// A Grammar Rule for handling RelativeCell -> r Integer c Integer
class GRRelativeCell : GRCell {
    let r = GRLiteral(literal: "r")
    let row = GRInteger()
    let c = GRLiteral(literal: "c")
    let col = GRInteger()
    
    init() {
        super.init(rhsRule: [r, row, c, col])
    }
    
    override func parse(input: String) -> String? {
        if let rest = super.parse(input: input) {
            if let ref = self.ref {
                if let tempRef = CellReference(ref: ref, rowOffset: row.calculatedValue.get()!, colOffset: col.calculatedValue.get()!) {
                    cellReference = tempRef
                    return rest
                }
            }
        }
        self.stateReset()
        return nil
    }
}


