//
//  main.swift
//  346Assignment1
//
//  Created by Percy Hu on 25/08/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//
//  Read commands from file if a file name is given, otherwise run the testing code

import Foundation

if CommandLine.arguments.count>1 {
    var filenames = CommandLine.arguments
    filenames.removeFirst() // first argument is the name of the executable
    
    func stderrPrint(_ message:String) {
        let stderr = FileHandle.standardError
        stderr.write(message.data(using: String.Encoding.utf8)!)
    }
    
    for filename in filenames {
        do {
            let filecontents : String = try String.init(contentsOfFile: filename)
            let aGRSpreadsheet = GRSpreadsheet()
            if let remainder = aGRSpreadsheet.parse(input: filecontents) {
                if remainder != "" {
                    stderrPrint("Parsing left remainder [\(remainder)].\n")
                }
            }
        } catch {
            stderrPrint("Error opening and reading file with filename [\(filename)].\n")
        }
    }
}else{
    func testGrammarRule(rule:GrammarRule, input:String) {
        if let remainingInput = rule.parse(input: input){
            print("Was able to parse input=\"\(input)\", with remainingInput=\"\(remainingInput)\"")
        } else {
            print("Was unable to parse input=\"\(input)\"")
        }
    }
    
    /**
     * Test parsing, assignment, ect. for each grammar rule, test is on the left hand side of the condition,
     * and the correct answer is on the right hand side, if the condition fails the program
     * stops executing and shows the line number of where the test failed.
     */
    
    // Create some sample cells and set values
    let value = CellValue()
    value.assign(int: 2)
    Cells.add(CellReference(colLabel: "A", rowNum: 2), CellContents(expr: "1+1", value: value))
    
    let value2 = CellValue()
    value2.assign(int: 36)
    Cells.add(CellReference(colLabel: "A", rowNum: 3), CellContents(expr: "12*3", value: value2))
    
    // Integer test
    let myGRInteger = GRInteger()
    if myGRInteger.parse(input: "6g") != "g" { assert(false) }
    if myGRInteger.calculatedValue.get() != 6 { assert(false) }
    if myGRInteger.stringValue != "6" { assert(false) }
    if myGRInteger.parse(input: "abc") != nil { assert(false) }
    if myGRInteger.calculatedValue.get() != nil { assert(false) }
    if myGRInteger.stringValue != nil { assert(false) }
    if myGRInteger.parse(input: "-6") != "" { assert(false) }
    if myGRInteger.calculatedValue.get() != -6 { assert(false) }
    if myGRInteger.stringValue != "-6" { assert(false) }
    
    // PositiveInteger test
    let myGRPositiveInteger = GRPositiveInteger()
    if myGRPositiveInteger.parse(input: "6g") != "g" { assert(false) }
    if myGRPositiveInteger.calculatedValue.get() != 6 { assert(false) }
    if myGRPositiveInteger.stringValue != "6" { assert(false) }
    if myGRPositiveInteger.parse(input: "abc") != nil { assert(false) }
    if myGRPositiveInteger.calculatedValue.get() != nil { assert(false) }
    if myGRPositiveInteger.stringValue != nil { assert(false) }
    if myGRPositiveInteger.parse(input: "0") != nil { assert(false) }
    if myGRPositiveInteger.calculatedValue.get() != nil { assert(false) }
    if myGRPositiveInteger.stringValue != nil { assert(false) }
    
    // StringNoQuote test
    let myGRStringNoQuote = GRStringNoQuote()
    if myGRStringNoQuote.parse(input: "\"abc") != nil { assert(false) }
    if myGRStringNoQuote.calculatedValue.get() != nil { assert(false) }
    if myGRStringNoQuote.stringValue != nil { assert(false) }
    if myGRStringNoQuote.parse(input: "abc") != "" { assert(false) }
    if myGRStringNoQuote.calculatedValue.get() != nil { assert(false) }
    if myGRStringNoQuote.stringValue != "abc" { assert(false) }
    
    // RelativeCell test
    let myGRRelativeCell = GRRelativeCell()
    myGRRelativeCell.set(ref: CellReference(colLabel: "B", rowNum: 2)) // assign it a cell
    if myGRRelativeCell.parse(input: "r-1c3") != "" { assert(false) }
    if myGRRelativeCell.calculatedValue.get() != nil { assert(false) }
    if myGRRelativeCell.stringValue != "r-1c3" { assert(false) }
    if myGRRelativeCell.cellReference != CellReference(colLabel: "E", rowNum: 1) { assert(false) }
    if myGRRelativeCell.parse(input: "r-10c-10") != nil { assert(false) }
    if myGRRelativeCell.calculatedValue.get() != nil { assert(false) }
    if myGRRelativeCell.stringValue != nil { assert(false) }
    if myGRRelativeCell.cellReference != nil { assert(false) }
    
    // RowNumber test
    let myGRRowNumber = GRRowNumber()
    if myGRRowNumber.parse(input: "6g") != "g" { assert(false) }
    if myGRRowNumber.calculatedValue.get() != 6 { assert(false) }
    if myGRRowNumber.stringValue != "6" { assert(false) }
    if myGRRowNumber.parse(input: "-6") != nil { assert(false) }
    if myGRRowNumber.calculatedValue.get() != nil { assert(false) }
    if myGRRowNumber.stringValue != nil { assert(false) }
    
    // UpperAlphaString test
    let myGRUpperAlphaString = GRUpperAlphaString()
    if myGRUpperAlphaString.parse(input: "Gg") != "g" { assert(false) }
    if myGRUpperAlphaString.calculatedValue.get() != nil { assert(false) }
    if myGRUpperAlphaString.stringValue != "G" { assert(false) }
    if myGRUpperAlphaString.parse(input: "6G") != nil { assert(false) }
    if myGRUpperAlphaString.calculatedValue.get() != nil { assert(false) }
    if myGRUpperAlphaString.stringValue != nil { assert(false) }
    
    // ColumnLabel test
    let myGRColumnLabel = GRColumnLabel()
    if myGRColumnLabel.parse(input: "Gg") != "g" { assert(false) }
    if myGRColumnLabel.calculatedValue.get() != nil { assert(false) }
    if myGRColumnLabel.stringValue != "G" { assert(false) }
    if myGRColumnLabel.parse(input: "6G") != nil { assert(false) }
    if myGRColumnLabel.calculatedValue.get() != nil { assert(false) }
    if myGRColumnLabel.stringValue != nil { assert(false) }
    
    // AbsoluteCell test
    let myGRAbsoluteCell = GRAbsoluteCell()
    if myGRAbsoluteCell.parse(input: "BA12>") != ">" { assert(false) }
    if myGRAbsoluteCell.calculatedValue.get() != nil { assert(false) }
    if myGRAbsoluteCell.stringValue != "BA12" { assert(false) }
    if myGRAbsoluteCell.parse(input: "ba12") != nil { assert(false) }
    if myGRAbsoluteCell.calculatedValue.get() != nil { assert(false) }
    if myGRAbsoluteCell.stringValue != nil { assert(false) }
    
    // CellReference test
    let myGRCellReference = GRCellReference()
    if myGRCellReference.parse(input: "AZ12C") != "C" { assert(false) }
    if myGRCellReference.calculatedValue.get() != nil { assert(false) }
    if myGRCellReference.stringValue != "AZ12" { assert(false) }
    if myGRCellReference.cellReference != CellReference(colLabel: "AZ", rowNum: 12) { assert(false) }
    if myGRCellReference.parse(input: "raaa") != nil { assert(false) }
    if myGRCellReference.calculatedValue.get() != nil { assert(false) }
    if myGRCellReference.stringValue != nil { assert(false) }
    if myGRCellReference.cellReference != nil { assert(false) }

    // Value test
    let myGRValue = GRValue()
    if myGRValue.parse(input: "A2") != "" { assert(false) }
    if myGRValue.calculatedValue.get() != 2 { assert(false) }
    if myGRValue.stringValue != "A2" { assert(false) }
    if myGRValue.parse(input: "9+1") != "+1" { assert(false) }
    if myGRValue.calculatedValue.get() != 9 { assert(false) }
    if myGRValue.stringValue != "9" { assert(false) }
    
    // ProductTermTail test
    let myGRProductTermTail = GRProductTermTail()
    if myGRProductTermTail.parse(input: "*2*A3") != "" { assert(false) }
    if myGRProductTermTail.calculatedValue.get() != 72 { assert(false) }
    if myGRProductTermTail.stringValue != "*2*A3" { assert(false) }
    if myGRProductTermTail.parse(input: "*ZA12") != "" { assert(false) }
    if myGRProductTermTail.calculatedValue.get() != 0 { assert(false) }
    if myGRProductTermTail.stringValue != "*ZA12" { assert(false) }
    if myGRProductTermTail.parse(input: "+1") != "+1" { assert(false) }
    if myGRProductTermTail.calculatedValue.get() != nil { assert(false) }
    if myGRProductTermTail.stringValue != nil { assert(false) }
    
    // ProductTerm test
    let myGRProductTerm = GRProductTerm()
    if myGRProductTerm.parse(input: "A3*2") != "" { assert(false) }
    if myGRProductTerm.calculatedValue.get() != 72 { assert(false) }
    if myGRProductTerm.stringValue != "A3*2" { assert(false) }
    if myGRProductTerm.parse(input: "2") != "" { assert(false) }
    if myGRProductTerm.calculatedValue.get() != 2 { assert(false) }
    if myGRProductTerm.stringValue != "2" { assert(false) }
    if myGRProductTerm.parse(input: "*2") != nil { assert(false) }
    if myGRProductTerm.calculatedValue.get() != nil { assert(false) }
    if myGRProductTerm.stringValue != nil { assert(false) }
    
    // QuotedString test
    let myGRQuotedString = GRQuotedString()
    if myGRQuotedString.parse(input: "\"\"a\"") != nil { assert(false) }
    if myGRQuotedString.calculatedValue.get() != nil { assert(false) }
    if myGRQuotedString.stringValue != nil { assert(false) }
    if myGRQuotedString.parse(input: "\"a\"") != "" { assert(false) }
    if myGRQuotedString.calculatedValue.get() != nil { assert(false) }
    if myGRQuotedString.stringValue != "\"a\"" { assert(false) }
    if myGRQuotedString.parse(input: "\"a\"bb") != "bb" { assert(false) }
    if myGRQuotedString.calculatedValue.get() != nil { assert(false) }
    if myGRQuotedString.stringValue != "\"a\"" { assert(false) }
    
    // ExpressionTail test
    let myGRExpressionTail = GRExpressionTail()
    if myGRExpressionTail.parse(input: "+2*A3") != "" { assert(false) }
    if myGRExpressionTail.calculatedValue.get() != 72 { assert(false) }
    if myGRExpressionTail.stringValue != "+2*A3" { assert(false) }
    if myGRExpressionTail.parse(input: "+ZA12") != "" { assert(false) }
    if myGRExpressionTail.calculatedValue.get() != 0 { assert(false) }
    if myGRExpressionTail.stringValue != "+ZA12" { assert(false) }
    if myGRExpressionTail.parse(input: "+1") != "" { assert(false) }
    if myGRExpressionTail.calculatedValue.get() != 1 { assert(false) }
    if myGRExpressionTail.stringValue != "+1" { assert(false) }
    if myGRExpressionTail.parse(input: "+2*A3+A3*1") != "" { assert(false) }
    if myGRExpressionTail.calculatedValue.get() != 108 { assert(false) }
    if myGRExpressionTail.stringValue != "+2*A3+A3*1" { assert(false) }
    
    // Expression test
    let myGRExpression = GRExpression()
    if myGRExpression.parse(input: "A3*2+3*2") != "" { assert(false) }
    if myGRExpression.calculatedValue.get() != 78 { assert(false) }
    if myGRExpression.stringValue != "A3*2+3*2" { assert(false) }
    if myGRExpression.parse(input: "2") != "" { assert(false) }
    if myGRExpression.calculatedValue.get() != 2 { assert(false) }
    if myGRExpression.stringValue != "2" { assert(false) }
    if myGRExpression.parse(input: "+2") != nil { assert(false) }
    if myGRExpression.calculatedValue.get() != nil { assert(false) }
    if myGRExpression.stringValue != nil { assert(false) }
    if myGRExpression.parse(input: "\"abc\"+3") != "+3" { assert(false) }
    if myGRExpression.calculatedValue.get() != nil { assert(false) }
    if myGRExpression.stringValue != "\"abc\"" { assert(false) }
    
    // Print test
    let myGRPrint = GRPrint()
    if myGRPrint.parse(input: "print_value A2") != "" { assert(false) }
    if myGRPrint.parse(input: "print_value A3 print_expr A3") != "" { assert(false) }
    if myGRPrint.parse(input: "print_value 1*2*3") != "" { assert(false) }
    if myGRPrint.parse(input: "print_expr \"1*2*3\"") != "" { assert(false) }
    if myGRPrint.parse(input: "print something") != nil { assert(false) }
    
    // Assignment test
    let myGRAssignment = GRAssignment()
    let B1 = CellReference(colLabel: "B", rowNum: 1)
    if myGRAssignment.parse(input: "B1 := 3*3+0") != "" { assert(false) }
    if Cells.get(B1).expr != "3*3+0" { assert(false) }
    if Cells.get(B1).value.get() != 9 { assert(false) }
    if myGRAssignment.parse(input: "B1 := B1+1") != "" { assert(false) }
    if Cells.get(B1).expr != "B1+1" { assert(false) }
    if Cells.get(B1).value.get() != 10 { assert(false) }
    if myGRAssignment.parse(input: "B1:=\"a\"c") != "c" { assert(false) }
    if Cells.get(B1).expr != "\"a\"" { assert(false) }
    if Cells.get(B1).value.describing() != "\"a\"" { assert(false) }
    
    // Spreadsheet test
    let myGRSpreadsheet = GRSpreadsheet()
    if myGRSpreadsheet.parse(input: "C1:=1 C2:=2 C3:=C1+C2 print_value C3") != "" { assert(false) }
    
    Cells.clear()
    print("\n******** All Tests Passed ********\n")
}







