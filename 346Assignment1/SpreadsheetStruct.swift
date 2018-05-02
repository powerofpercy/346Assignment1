//
//  SpreadsheetStruct.swift
//  346Assignment1
//
//  Created by Percy Hu on 25/08/17.
//  Copyright © 2017 Percy Hu. All rights reserved.
//
//  Provides internal structures of spreadsheet cells

import Foundation

/**
 Stores expression and value of a cell
 */
struct CellContents {
    var expr : String = ""
    var value = CellValue(0)
}

/**
 Uses dictionary to manage contents of cells
 */
struct Cells {
    private static var currentCell : CellReference? = nil
    private static var cells = [CellReference: CellContents]()
    
    // Add a content to a given cell
    static func add(_ cellReference : CellReference, _ cellContents: CellContents) {
        cells[cellReference] = cellContents
    }
    
    // Retrieve cell properties based on cell label
    static func get(_ label : String)-> CellContents? {
        let reference = GRCellReference()
        
        if(reference.parse(input: label) == "") {
            return get(reference.cellReference!)
        }
        return nil
    }
    
    static func reGet(_ label : String)-> CellContents? {
        let reference = GRCellReference()
        if(reference.parse(input: label) == "") {
            return reGet(reference.cellReference!)
        }
        return nil
    }
    
    // Retrieve cell properties based on cell reference
    static func get(_ ref: CellReference)-> CellContents {
        if cells[ref] == nil {
            return CellContents()
        }
        return cells[ref]!
    }
    
    static func reGet(_ ref : CellReference)-> CellContents {
        let expression = GRExpression()
        expression.set(ref: ref)
        if let cell = cells[ref] {
            if expression.parse(input: cell.expr) != nil {
                cells[ref] = CellContents(expr: expression.stringValue!, value: expression.calculatedValue)
                return cells[ref]!
            }
        }
        return CellContents()
    }
    
    // Clear the dictionary
    static func clear() {
        cells.removeAll()
    }
}

// The class for representing the string value and calculated value (nil if non exists) of a cell
class CellValue {
    private var stringValue : String?
    private var calculatedValue : Int?
    
    init() {
        stringValue = nil
        calculatedValue = nil
    }
    
    // Only modify calculatedValue if cell value is an integer
    convenience init(_ int: Int) {
        self.init()
        calculatedValue = int
    }
    
    func assign(int: Int){
        self.calculatedValue = int
    }
    
    func assign(string: String) {
        self.stringValue = string;
    }
    
    func get()-> Int? {
        return self.calculatedValue
    }
    
    func describing()-> String {
        if self.stringValue != nil {
            return stringValue!
        }
        if self.calculatedValue != nil {
            return String(describing: self.calculatedValue!)
        }
        return ""
    }
    
    func copy()-> CellValue {
        let copiedValue = CellValue()
        if self.stringValue != nil {
            copiedValue.assign(string: self.stringValue!)
        }
        
        if self.calculatedValue != nil {
            copiedValue.assign(int: self.calculatedValue!)
        }
        return copiedValue
    }
    
    // Overloads the default operators
    static func +(value1: CellValue, value2: CellValue)-> CellValue {
        let sum = CellValue()
        if value1.get() != nil && value2.get() != nil {
            sum.assign(int: value1.get()! + value2.get()!)
        }
        return sum
    }
    
    static func +=(value1: CellValue, value2: CellValue) {
        if value1.get() != nil && value2.get() != nil {
            value1.assign(int: value1.get()! + value2.get()!)
        }
    }
    
    static func *(value1: CellValue, value2: CellValue)-> CellValue {
        let product = CellValue()
        if value1.get() != nil && value2.get() != nil {
            product.assign(int: value1.get()! * value2.get()!)
        }
        return product
    }
    
    static func *=(value1: CellValue, value2: CellValue) {
        if value1.get() != nil && value2.get() != nil {
            value1.assign(int: value1.get()! * value2.get()!)
        }
    }
}

/**
 Provides functionality for converting between AbsoluteCell and RelativeCell
 references (by converting column label to numbers and vice versa).
 */
class CellReference : Hashable {
    private var row : Int
    private var col : Int
    private var abs : String
    
    internal var hashValue: Int {
        return abs.hashValue
    }
    
    // For creating cell with given column label and row number
    init(colLabel : String, rowNum : Int) {
        abs = colLabel + String(rowNum)
        let intLetterA = Int(UnicodeScalar("A").value)
        var colLetterLocation = colLabel.characters.count - 1
        var colNum = 0
        for letter in colLabel.unicodeScalars {
            colNum += (Int(letter.value) - intLetterA+1) * Int(pow(Double(26), Double(colLetterLocation)))
            colLetterLocation -= 1
        }
        row = rowNum-1
        col = colNum-1
    }
    
    // For existing cell references
    init?(ref: CellReference, rowOffset: Int, colOffset: Int) {
        if ref.row + rowOffset < 0 || ref.col + colOffset < 0 {
            return nil
        }
        row = ref.row + rowOffset
        col = ref.col + colOffset
        var colNum = col
        let intLetterA = Int(UnicodeScalar("A").value)
        var colLabel = ""
        var digit : Int
        var count = 1
        while colNum >= 0 {
            digit = colNum % Int(pow(Double(26), Double(count))) + 1
            colNum -= digit
            digit /= Int(pow(Double(26), Double(count - 1)))
            colLabel += String(UnicodeScalar(digit + intLetterA-1)!)
            count += 1
        }
        abs = String(colLabel.characters.reversed()) + String(row+1)
    }
    
    // Overrides the default operator for comparing references
    static func == (lhs: CellReference, rhs: CellReference) -> Bool {
        return lhs.abs == rhs.abs
    }
}
