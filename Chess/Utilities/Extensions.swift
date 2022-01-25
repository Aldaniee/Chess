//
//  UtilityExtensions.swift
//  Chess
//
//  Created by Aidan Lee on 12/30/21.
//

import Foundation
import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
extension Int {
    func toLetterAtAlphabeticalIndex() -> Character {
        let startingValue = Int(("a" as UnicodeScalar).value)
        return Character(UnicodeScalar(self + startingValue) ?? UnicodeScalar(0))
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
    func alphabeticalIndex() -> Int {
        let startingValue: Int = Int(("a" as UnicodeScalar).value)
        let currentValue = Int((Unicode.Scalar(String(self)))?.value ?? UInt32(startingValue))
        return currentValue - startingValue
    }
}

extension Array where Element == (piece: Piece, count: Int) {

    mutating func appendAndSort(piece: Piece) -> [(piece: Piece, count: Int)] {
        var newArray = self
        if let index = self.firstIndex(where: {$0.piece.type == piece.type}) {
            self[index].count += 1
        }
        else {
            self.append((piece, 1))
        }
        return self.sorted { p1, p2 in
            p1.piece.points == p2.piece.points ? p1.piece.type.name > p2.piece.type.name : p1.piece.points < p2.piece.points
        }
    }
    
}

extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType)}) {
            provider.loadObject(ofClass: theType) { object, error in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType)}) {
            let _ = provider.loadObject(ofClass: theType) { object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
}
