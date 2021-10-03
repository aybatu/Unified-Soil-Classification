//
//  TestResultsCalculationModel.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import Foundation

struct TestResultsCalculationModel {
    var sieveSize = [75.0, 19.0, 4.75, 2.0, 0.425, 0.075]
    var dx: [String: Double] = ["60": 0.0, "30": 0.0, "10": 0.0]
    var passingPercent: [String: Double] = ["threeInchPer": 0.0, "threeFourInchPer": 0.0, "noFourPer": 0.0, "noTenPer": 0.0, "noFourtyPer": 0.0, "noTwoHundredPer": 0.0]
    var cC = 0.0
    var cU = 0.0
    var organicConstant = 0.0
    
    mutating func soilEvaluation(threeInch: Double, threeFourInch: Double, noFour: Double, noTen: Double, noFourty: Double, noTwoHundred: Double, pan: Double, plasticLimit: Double, liquidLimit: Double, driedWeight: Double, notDriedWeight: Double) {
        let totalWeightOfSamples = threeInch + threeFourInch + noFour + noTen + noFourty + noTwoHundred + pan
        
        let threeInchPercent = 100 - ((threeInch * 100) / totalWeightOfSamples)
        let threeFourInchPercent = 100 - (((threeFourInch + threeInch) * 100) / totalWeightOfSamples)
        let noFourPercent = 100 - (((threeFourInch + threeInch + noFour) * 100) / totalWeightOfSamples)
        let noTenPercent = 100 - (((threeFourInch + threeInch + noFour + noTen) * 100) / totalWeightOfSamples)
        let noFourtyPercent = 100 - (((threeFourInch + threeInch + noFour + noTen + noFourty) * 100) / totalWeightOfSamples)
        let noTwoHundredPercent = 100 - (((threeFourInch + threeInch + noFour + noTen + noFourty + noTwoHundred) * 100) / totalWeightOfSamples)
        
        let passingPercentArray = [threeInchPercent, threeFourInchPercent, noFourPercent, noTenPercent, noFourtyPercent, noTwoHundredPercent]
        
        passingPercent["threeInchPer"] = threeInchPercent
        passingPercent["threeFourInchPer"] = threeFourInchPercent
        passingPercent["noFourPer"] = noFourPercent
        passingPercent["noTenPer"] = noTenPercent
        passingPercent["noFourtyPer"] = noFourtyPercent
        passingPercent["noTwoHundredPer"] = noTwoHundredPercent
        
        if threeInchPercent > 0 {
            gradation(yAxis: passingPercentArray, xAxis: sieveSize, dx: 60, n: 0)
            gradation(yAxis: passingPercentArray, xAxis: sieveSize, dx: 30, n: 0)
            gradation(yAxis: passingPercentArray, xAxis: sieveSize, dx: 10, n: 0)
        }
          
        organicConstant = (liquidLimit - driedWeight) / (liquidLimit - notDriedWeight)
        
    }
    
    mutating private func gradation(yAxis passingPercentArray: [Double], xAxis sieveSize: [Double], dx: Double, n: Int) {
        var n = 0

        while n < passingPercentArray.count {
            if passingPercentArray[n] == dx {
                self.dx[String(dx)] = sieveSize[n]
                break
            } else if passingPercentArray[n] < dx {
                if n == 0 {
                    print(n)
                    gradateCalc(x1: sieveSize[n], x2: 0, y1:passingPercentArray[n], y2: 100, constant: dx, n: n)
                } else {
                    gradateCalc(x1: sieveSize[n], x2: sieveSize[n - 1], y1:passingPercentArray[n], y2: passingPercentArray[n - 1], constant: dx, n: n)
                }
                break
            }
            n += 1
        }
    }
    
    mutating private func gradateCalc(x1: Double, x2: Double, y1: Double, y2: Double, constant: Double, n: Int?) {
    
        let x = x2 - x1
        let y = y2 - y1
        
        let m = y / x
      
        let b = y1 - (m * x1)
        
        if constant == 60 {
            dx["60"] = (constant - b) / m
        } else if constant == 30 {
            dx["30"] = (constant - b) / m
        } else if constant == 10 {
            dx["10"] = (constant - b) / m
        }
        
        if let d60 = dx["60"], let d30 = dx["30"], let d10 = dx["10"] {
            calculationOfCcCu(d60: d60, d30: d30, d10: d10)
//            print(d60, d30, d10)
        }
    }
    
    mutating func calculationOfCcCu(d60: Double, d30: Double, d10: Double) {
        cC = pow(d30, 2) / ( d60 * d10)
        cU = d60 / d10
    }
}
