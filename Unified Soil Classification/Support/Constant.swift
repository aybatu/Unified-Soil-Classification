//
//  Constant.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import Foundation

struct K {
    struct Segue {
        static let sieveResultsToTabCtrl = "sieveResultsToTabController"
        static let resultViewToTableView = "resultViewToTableView"
        static let sampleViewToResult = "savedSamplesToResult"
    }
    struct Cell {
        static let savedSampleCell = "sampleCell"
    }
    struct FinesType {
        static let clMl = "clMl"
        static let cl = "cl"
        static let ml = "ml"
        static let ch = "ch"
        static let mh = "mh"
        static let ol = "ol"
        static let oh = "oh"
    }
    struct laboratoryTests {
        static let threeInch = "threeInch"
        static let threeFourInch = "threeFourInch"
        static let noFour = "noFour"
        static let noTen = "noTen"
        static let noFourty = "noFourty"
        static let noTwoHundred = "noTwoHundred"
        static let pan = "pan"
        static let plasticLimit = "plasticLimit"
        static let liquidLimit = "liquidLimit"
        static let wetWeight = "wetWeight"
        static let driedWeight = "driedWeight"
    }
}
