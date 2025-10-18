//
//  GameVM.swift
//  Crush Me
//
//  Created by Rony Vincent on 17/10/25.
//

import Foundation
import SwiftUI


@Observable

class GameVM {
    var score = 0
    var combo = 0
    var isMatch = false
    var isProcessing = false
    var gameTime = 30
    var isPlaying = false
    var isStop = false
    var timer: Timer?
    var isGameOver = false
    var rows = 8
    var columns = 8
    var board: [[IconType]] = Array(repeating: Array(repeating: IconType.empty, count: 8), count: 8)
    var firstButtonnPressed: (row: Int, col: Int)? = nil
    var secondButtonnPressed: (row: Int, col: Int)? = nil
    
    func fillGrid (){
        for row in 0..<rows {
            for col in 0..<columns {
                withAnimation(.easeInOut(duration: 0.3)){
                    board[row][col] = IconType.random()
                }
            }
        }
    }
    
    func isSelected(row:Int, col:Int)-> Bool{
        return firstButtonnPressed?.row == row && firstButtonnPressed?.col == col
    }
    
    func isPendingSwipe ()-> Bool {
        return firstButtonnPressed != nil && secondButtonnPressed != nil
    }
    
    func preventInitialMatches (){
        var hasMadeChanges = true
        
        while hasMadeChanges {
            hasMadeChanges = false
            for row in 0..<rows {
                for col in 0..<columns {
                    let current = board[row][col]
                    if hasMatch(row: row, col: col, type: current){
                        board[row][col] = IconType.core().first{
                            $0 != current
                        } ?? .empty
                        hasMadeChanges = true
                    }
                }
            }
        }
    }
    
    func hasMatch(row: Int, col: Int, type: IconType)-> Bool{
        let horizontal = (col >= 2 && board[row][col - 1] == type && board[row][col-2] == type ) || (col<columns-2 && board[row][col+1] == type && board[row][col+2] == type)
        let vertical = (row>=2 && board[row-1][col] == type && board[row-2][col] == type) || (row<rows-2 && board[row+1][col] == type && board[row+2][col] == type )
        return horizontal || vertical
    }
    func setupBoard (){
        self.board =  Array(repeating: Array(repeating: IconType.empty, count: 8), count: 8)
        withAnimation(.easeInOut(duration: 0.3)){
            fillGrid()
            preventInitialMatches()
        }
    }
    
    func gameStart () {
        self.score = 0
        self.gameTime = 30
        isPlaying = true
        
        setupBoard()
    }
    
    func markMatches(checkList: inout [[Bool]]){
        for row in 0..<rows {
            for col in 0..<(columns-2) {
                let type = board[row][col]
                
                if type != .empty && board[row][col+1] == type && board[row][col+2] == type {
                    checkList[row][col] = true
                    checkList[row][col+1] = true
                    checkList[row][col+2] = true
                    isMatch = true
                }
            }
        }
        
        for row in 0..<(rows - 2) {
            for col in 0..<columns{
                let type = board[row][col]
                
                if type != .empty && board[row+1][col] == type && board[row+2][col] == type {
                    checkList[row][col] = true
                    checkList[row+1][col] = true
                    checkList[row+2][col] = true
                    isMatch = true
                }
            }
        }
    }
    
    func checkDead()-> Bool{
        for row in board{
            for cell in row{
                switch cell {
                case .row, .column, .bang, .gift, .bomb:
                    return false
                default:
                    continue ///continue
                }
            }
        }
        
        for row in 0..<rows{
            for col in 0..<columns{
                let type = board[row][col]
                
                if col < columns - 1 && IconType.core().contains(type) && IconType.core().contains(board[row][col + 1 ]){
                    
                    if (col > 0 && IconType.core().contains(board[row][col - 1])) || (col < columns - 2 && IconType.core().contains(board[row][col + 2])){
                        return true
                    }
                }
                
                if row < rows - 1 && IconType.core().contains(type) && IconType.core().contains(board[row + 1][col]){
                    if (row > 0 && IconType.core().contains(board[row-1][col])) || (row < rows - 2 && IconType.core().contains(board[row+2][col])){
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func clearAll(){
        isMatch = true
        withAnimation(.easeInOut(duration:0.4)){
            board = Array(repeating: Array(repeating: IconType.empty, count: 8), count: 8)
        }
        withAnimation(.easeInOut(duration: 0.4)){
            fall()
        }
    }
    
    func runFunctionWithDelay(_ delay: Double, _ function: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false){_ in
            function()
        }
    }
    
    func checkAndMarkSpecialMatches (checkList: inout [[Bool]]) {
        for  column in 0..<columns {
            var matchLength = 0
            
            for row in 0..<rows {
                if checkList[row][column] {
                    matchLength += 1
                }
                else {
                    if matchLength >= 5 {
                        clearCheckListVertical(fromRow: row - matchLength, toRow: row - 1, column: column, checkList: &checkList)
                        setSpecialVertical(fromRow: row - matchLength, toRow: row - 1, column: column)
                        
                    }
                    matchLength = 0
                }
            }
            if matchLength >= 5 {
                clearCheckListVertical(fromRow: rows - matchLength, toRow: rows - 1, column: column, checkList: &checkList)
                setSpecialVertical(fromRow: rows - matchLength, toRow: rows - 1, column: column)
            }
        }
        
        for row in 0..<rows {
            var matchLength = 0
            
            for column in 0..<columns {
                if checkList[row][column] {
                    matchLength += 1
                }
                else {
                    if matchLength >= 5 {
                        clearCheckListHorizontal(fromColumn: column - matchLength, toColumn: column - 1, row: row, checkList: &checkList)
                        setSpecialCellHorizontal(fromColumn: column - matchLength, toColumn: column - 1, row: row,)
                    }
                    matchLength = 0
                }
            }
            if matchLength >= 5 {
                clearCheckListHorizontal(fromColumn: columns - matchLength, toColumn: columns - 1, row: row, checkList: &checkList)
                setSpecialCellHorizontal(fromColumn: columns - matchLength, toColumn: columns - 1, row: row)
            }
        }
    }
    
    func setSpecialCellHorizontal (fromColumn: Int, toColumn: Int, row: Int){
        withAnimation(.easeInOut(duration: 0.4)){
            for col in fromColumn..<toColumn {
                board[row][col] = .empty
            }
            board[row][toColumn] = .gift
        }
    }
    
    func clearCheckListHorizontal(fromColumn: Int, toColumn: Int, row: Int, checkList: inout [[Bool]]){
        for column in fromColumn...toColumn {
            checkList[row][column] = false
        }
    }
    
    func setSpecialVertical(fromRow: Int, toRow: Int, column: Int){
        withAnimation(.easeIn(duration: 0.4)){
            for row in fromRow...toRow {
                board[row][column] = .empty
            }
            board[toRow][column] = .gift
        }
    }
    
    func clearCheckListVertical(fromRow: Int, toRow: Int, column: Int, checkList: inout [[Bool]]){
        for row in fromRow...toRow {
            checkList[row][column] = false
        }
    }
    
    func markFourMatches (checkList: inout [[Bool]]){
        
        for row in 0..<rows {
            for column in 0..<(columns - 3) {
                
                if checkList[row][column] && board[row][column] == board[row][column+1] && board[row][column] == board[row][column + 2] && board[row][column] == board[row][column + 3] && IconType.core().contains(board[row][column]){
                    for i  in 0..<4{
                        checkList[row][column + i] = false
                        board[row][column + i]  = .empty
                    }
                    
                    withAnimation(.easeInOut(duration:0.4)){
                        board[row][column] = .row
                        
                    }
                }
            }
        }
        
        for row in (0..<rows-3){
            for column in 0..<columns{
                if checkList[row][column] && board[row][column] == board[row+1][column] && board[row][column] == board[row+2][column] && board[row][column] == board[row+3][column] && IconType.core().contains(board[row][column]){
                    for i in 0..<4 {
                        checkList[row + i][column] = false
                        board[row + i][column] = .empty
                    }
                    withAnimation(.easeInOut(duration:0.4)){
                        board[row][column] = .column}
                }
            }
        }
    }
    
    func processThreeInARow(checkList: inout [[Bool]]){
        for row in 0..<rows {
            for column in 0..<(columns - 2) {
                if checkList[row][column] && board[row][column] == board[row][column+1] && board[row][column] == board[row][column + 2] && IconType.core().contains(board[row][column]) {
                    for i  in 0..<3{
                        checkList[row][column + i] = false
                        board[row][column + i] = .empty
                    }
                }
            }
        }
        
        for row in (0..<rows-2){
            for column in 0..<columns{
                if checkList[row][column] && board[row][column] == board[row+1][column] && board[row][column] == board[row+2][column] && IconType.core().contains(board[row][column]){
                    for i in 0..<3 {
                        checkList[row + i][column] = false
                        board[row + i][column] = .empty
                    }
                }
            }
        }
        
    }
    
    func markShapeMatchesAsSpecial(checkList: inout [[Bool]]){
        for row in 0..<rows {
            for column in 0..<columns {
                if !checkList[row][column]{continue}
                let centreType = board[row][column]
                
                let positionOne = [(row,column), (row,column - 1), (row,column - 2),(row-1,column ), (row-2,column)]
                let positionTwo = [(row,column), (row,column + 1), (row,column + 2),(row-1,column ), (row-2,column)]
                let positionThree = [(row,column), (row,column + 1), (row,column + 2),(row+1,column ), (row+2,column)]
                let positionFour = [(row,column), (row,column - 1), (row,column - 2),(row+1,column ), (row+2,column)]
                
                func isLShape (positions: [(Int,Int)])-> Bool{
                    for position in positions {
                        if position.0 < 0 || position.0 >= rows || position.1 < 0 || position.1 >= columns || board[position.0][position.1] != centreType || !checkList[position.0][position.1]{
                            return false
                        }
                    }
                    return true}
                
                let isLShapeOne = isLShape(positions: positionOne)
                let isLShapeTwo = isLShape(positions: positionTwo)
                let isLShapeThree = isLShape(positions: positionThree)
                let isLShapeFour = isLShape(positions: positionFour)
                
                if isLShapeOne || isLShapeTwo || isLShapeThree || isLShapeFour {
                    [positionOne, positionTwo, positionThree, positionFour].forEach{ positions in
                        
                        positions.forEach{
                            position in
                            if position.0 >= 0 && position.0 < rows && position.1 >= 0 && position.1 < columns {
                                checkList[position.0][position.1] = false
                                board[position.0][position.1] = .empty
                            }
                        }}
                    withAnimation(.easeInOut(duration: 0.4)){
                        board[row][column] = .bomb
                        
                    }
                }
            }
        }
    }
    
    func clear (checkList: inout [[Bool]]){
        for row in 0..<rows{
            for column in 0..<columns{
                if checkList[row][column] == true {
                    withAnimation(.easeInOut(duration: 0.4)){
                        board[row][column] = .empty
                    }
                }
                checkList[row][column] = false
            }
        }
    }
    
    func checkMatch() {
        var checkList = Array(repeating: Array(repeating: false, count: columns), count: rows)
        
        withAnimation(.easeInOut(duration: 0.5)){
            markMatches(checkList: &checkList)
            checkAndMarkSpecialMatches(checkList: &checkList)
            markShapeMatchesAsSpecial(checkList: &checkList)
            markFourMatches(checkList: &checkList)
            processThreeInARow(checkList: &checkList)
            
            withAnimation(.easeInOut(duration: 0.3)){
                clear(checkList: &checkList)
            }
            
            if isMatch{
                runFunctionWithDelay(0.3){
                    self.fall()
                }
            }else {
                if checkDead(){
                    board.shuffle()
                    runFunctionWithDelay(0.3){
                        self.fall()
                    }
                }
                isProcessing = false
            }
        }
    }
    
    func fall(){
        var didChange: Bool
        repeat {
            didChange = false
            for row in 1..<rows{
                for column in 0..<columns{
                    if board[row][column] == .empty && board[row-1][column] != .empty {
                        (board[row][column], board[row-1][column]) = (board[row - 1][column], board[row][column])
                        didChange = true
                    }
                }
            }
            for col in 0..<columns where board[0][col] == .empty{
                board[0][col] = IconType.random()
                didChange = true
            }
        }while didChange
        
        isMatch = false
        runFunctionWithDelay(0.3) {
            self.checkMatch()
        }
    }
    
    func bomb (rowIndex: Int, columnIndex: Int){
        isMatch = true
        withAnimation(.easeIn(duration: 0.3)){
            board[rowIndex][columnIndex] = .empty
        }
        handledAdjacentCell(rowIndex: rowIndex-1, columnIndex: columnIndex)
        handledAdjacentCell(rowIndex: rowIndex+1, columnIndex: columnIndex)
        handledAdjacentCell(rowIndex: rowIndex, columnIndex: columnIndex-1)
        handledAdjacentCell(rowIndex: rowIndex, columnIndex: columnIndex+1)
        handledAdjacentCell(rowIndex: rowIndex-1, columnIndex: columnIndex-1)
        handledAdjacentCell(rowIndex: rowIndex+1, columnIndex: columnIndex+1)
        handledAdjacentCell(rowIndex: rowIndex+1, columnIndex: columnIndex-1)
        handledAdjacentCell(rowIndex: rowIndex-1, columnIndex: columnIndex+1)
    }
    
    func handledAdjacentCell (rowIndex: Int, columnIndex: Int){
        guard rowIndex >= 0, rowIndex < rows, columnIndex >= 0, columnIndex < columns else {return}
        
        let cell = board[rowIndex][columnIndex]
        
        switch cell {
        case .empty:
            break
        case .bomb:
            self.bomb(rowIndex: rowIndex, columnIndex: columnIndex)
        case .row:
            self.rowActivate(rowIndex: rowIndex, colIndex: columnIndex)
        case .column:
            self.colActivate(rowIndex: rowIndex, colIndex: columnIndex)
        case .gift:
            self.gift(rowIndex: rowIndex, colIndex: columnIndex, icon: IconType.random())
        case .bang:
            break
        default:
            withAnimation(.easeInOut(duration: 0.3)){
                board[rowIndex][columnIndex] = .empty
            }
        }
    }
    func multiRow (firstRowIndex: Int, firstColIndex: Int, secRowIndex: Int, secColIndex:Int){
        isMatch = true
        board[firstRowIndex][firstColIndex] = .empty
        board[secRowIndex][secColIndex] = .empty
        
        let random = IconType.random()
        
        for row in 0..<rows{
            for col in 0..<columns{
                if board[row][col] == random{
                    
                    board[row][col] = .row
                    
                }
            }
        }
        for row in 0..<rows{
            for col in 0..<columns{
                if board[row][col] == .row{
                    self.rowActivate(rowIndex: row, colIndex: col)
                }
            }
        }
    }
    
    func multiCol (firstRowIndex: Int, firstColIndex: Int, secRowIndex: Int, secColIndex:Int){
        isMatch = true
        board[firstRowIndex][firstColIndex] = .empty
        board[secRowIndex][secColIndex] = .empty
        
        let random = IconType.random()
        
        for row in 0..<rows{
            for col in 0..<columns{
                if board[row][col] == random{
                    board[row][col] = .column
                }
            }
        }
        for row in 0..<rows{
            for col in 0..<columns{
                if board[row][col] == .column{
                    self.colActivate(rowIndex: row, colIndex: col)
                }
            }
        }
    }
    
    func rowActivate(rowIndex: Int, colIndex: Int){
        isMatch = true
        board[rowIndex][colIndex] = .empty
        
        for col in 0..<columns{
            let cell = board[rowIndex][col]
            switch cell {
            case .empty:
                break
            case .row:
                break
            case .column:
                self.colActivate(rowIndex: rowIndex, colIndex: col)
            case .bang:
                break
            case .gift:
                self.gift(rowIndex: rowIndex, colIndex: col, icon: IconType.random())
            case .bomb:
                self.bomb(rowIndex: rowIndex, columnIndex: col)
            default:
                withAnimation{
                    board[rowIndex][col] = .empty
                }
            }
        }
    }
    
    func colActivate(rowIndex: Int, colIndex: Int){
        isMatch = true
        board[rowIndex][colIndex] = .empty
        
        for row in 0..<rows{
            let cell = board[row][colIndex]
            switch cell {
            case .empty:
                break
            case .row:
                self.rowActivate(rowIndex: row, colIndex: colIndex)
            case .column:
                break
            case .bang:
                break
            case .gift:
                self.gift(rowIndex: row, colIndex: colIndex, icon: IconType.random())
            case .bomb:
                self.bomb(rowIndex: row, columnIndex: colIndex)
            default:
                withAnimation{
                    board[row][colIndex] = .empty
                }
            }
        }
    }
    
    func multiBomb(firstRowIndex: Int, firstColIndex: Int, secRowIndex: Int, secColIndex:Int){
        isMatch = true
        board[firstRowIndex][firstColIndex] = .empty
        board[secRowIndex][secColIndex] = .empty
        
        let random = IconType.random()
        
        for row in 0..<rows{
            for col in 0..<columns{
                if board[row][col] == random{
                    board[row][col] = .bomb
                }
            }
        }
        for row in 0..<rows{
            for col in 0..<columns{
                if board[row][col] == .bomb{
                    self.bomb(rowIndex: row, columnIndex: col)
                }
            }
        }
    }
    
    func gift (rowIndex: Int, colIndex: Int, icon: IconType){
        isMatch = true
        board[rowIndex][colIndex] = .empty
        
        for row in 0..<rows{
            for col in 0..<columns{
                if board[row][col] == icon{
                    board[row][col] = .empty
                }
            }
        }
    }
    
    func cross (firstRowIndex: Int, firstColIndex: Int, secRowIndex: Int, secColIndex:Int){
        isMatch = true
        board[firstRowIndex][firstColIndex] = .empty
        board[secRowIndex][secColIndex] = .empty
        
        self.rowActivate(rowIndex: firstRowIndex, colIndex: firstColIndex)
        self.colActivate(rowIndex: firstRowIndex, colIndex: firstColIndex)
        withAnimation(.easeInOut(duration: 0.3)){
            fall()
        }
        self.rowActivate(rowIndex: secRowIndex, colIndex: secColIndex)
        self.colActivate(rowIndex: secRowIndex, colIndex: secColIndex)
        
    }
    
    func bigCross (firstRowIndex: Int, firstColIndex: Int, secRowIndex: Int, secColIndex:Int){
        isMatch = true
        
        func indicesToClear (index: Int) -> [Int] {
            let possibleIndices = [index-1, index, index+1]
            return possibleIndices.filter{
                $0 >= 0 && $0 < 8
            }
        }
        let firstRowIndicesToClear = indicesToClear(index: firstRowIndex)
        let firstColIndicesToClear = indicesToClear(index: firstColIndex)
        
        for col in firstColIndicesToClear {
            self.colActivate(rowIndex: firstRowIndex, colIndex: col)
        }
        for row in firstRowIndicesToClear {
            self.rowActivate(rowIndex: row, colIndex: firstColIndex)
        }
        withAnimation(.easeInOut(duration: 0.4)){
            fall()
        }
        let secRowIndicesToClear = indicesToClear(index: secRowIndex)
        let secColIndicesToClear = indicesToClear(index: secColIndex)
        for col in secColIndicesToClear {
            self.colActivate(rowIndex: secRowIndex, colIndex: col)
        }
        for row in secRowIndicesToClear {
            self.rowActivate(rowIndex: row, colIndex: secColIndex)
        }
        withAnimation(.easeInOut(duration: 0.4)){
            fall()
        }
    }
    func tryProcess (row: Int, col: Int){
        if firstButtonnPressed == nil {
            firstButtonnPressed = (row, col)
        } else if secondButtonnPressed == nil {
            secondButtonnPressed = (row, col)
            
            if let(rowOrigin, colOrigin) = firstButtonnPressed, let (rowDestination, colDestination) = secondButtonnPressed
            {
                process(rowOrigin:rowOrigin,colOrigin:colOrigin,rowDestination:rowDestination,colDestination:colDestination)
            }
            firstButtonnPressed = nil
            secondButtonnPressed = nil
        }
    }
    
    func process(rowOrigin: Int, colOrigin: Int, rowDestination: Int, colDestination: Int) {
        guard !isProcessing, (abs(rowOrigin - rowDestination) == 1  && colOrigin == colDestination) || (abs(colOrigin-colDestination) == 1 && rowOrigin == rowDestination)
        else {return}
        isProcessing = true
        withAnimation(.easeInOut(duration: 0.4)){
            (board[rowOrigin][colOrigin], board[rowDestination][colDestination]) = (board[rowDestination][colDestination], board[rowOrigin][colOrigin])
        }
        let left = board[rowOrigin][colOrigin], right = board[rowDestination][colDestination]
        
        if [left,right].allSatisfy({$0 == .gift}){self.clearAll()}
        else if left == .gift && right == .bomb || left == .bomb && right == .gift {
            self.multiBomb(firstRowIndex: rowOrigin, firstColIndex: colOrigin, secRowIndex: rowDestination, secColIndex: colDestination)}
        else if left == .gift && right == .row || left == .row && right == .gift {
            self.multiRow(firstRowIndex: rowOrigin, firstColIndex: colOrigin, secRowIndex: rowDestination, secColIndex: colDestination)}
        else if left == .gift && right == .column || left == .column && right == .gift {
            self.multiCol(firstRowIndex: rowOrigin, firstColIndex: colOrigin, secRowIndex: rowDestination, secColIndex: colDestination)}
        else if [left,right].allSatisfy({$0 == .bomb}){
            self.multiBomb(firstRowIndex: rowOrigin, firstColIndex: colOrigin, secRowIndex: rowDestination, secColIndex: colDestination)}
        else if [.row, .column].contains(left) && right == .bomb || [.row, .column].contains(right) && left == .bomb {
            self.bigCross(firstRowIndex: rowOrigin, firstColIndex: colOrigin, secRowIndex: rowDestination, secColIndex: colDestination)}
        else if [.row, .column].contains(left) && [.row, .column].contains(right){
            self.cross(firstRowIndex: rowOrigin, firstColIndex: colOrigin, secRowIndex: rowDestination, secColIndex: colDestination)}
        else if left == .gift {self.gift(rowIndex: rowOrigin, colIndex: colOrigin, icon: board[rowDestination][colDestination])}
        else if left == .bomb {self.bomb(rowIndex: rowOrigin, columnIndex: colOrigin)}
        else if left == .row {self.rowActivate(rowIndex: rowOrigin, colIndex: colOrigin)}
        else if left == .column {self.colActivate(rowIndex: rowOrigin, colIndex: colOrigin)}
        else if right == .gift {self.gift(rowIndex: rowDestination, colIndex: colDestination, icon: board[rowOrigin][colOrigin])}
        else if right == .bomb {self.bomb(rowIndex: rowDestination, columnIndex: colDestination)}
        else if right == .row {self.rowActivate(rowIndex: rowDestination, colIndex: colDestination)}
        else if right == .column {self.colActivate(rowIndex: rowDestination, colIndex: colDestination)}
        else {
            runFunctionWithDelay(0.4){
                self.checkMatch()
                if !self.isMatch {
                    withAnimation(.easeInOut(duration: 0.4)){
                        (self.board[rowOrigin][colOrigin], self.board[rowDestination][colDestination]) = (self.board[rowDestination][colDestination], self.board[rowOrigin][colOrigin])
                    }
                    self.isProcessing = false
                }
            }
            return
        }
        withAnimation(.easeInOut(duration: 0.4)){
            fall()
        }
    }
}

