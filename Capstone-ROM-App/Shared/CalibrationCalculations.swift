//
//  CalibrationCalculations.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 2/8/22.
//

import SwiftUI
import Accelerate
import simd

let g1 : [simd_double3] = [[6, 6, 3], [4, 8, 4], [6, 0, 7], [7, 9, 5], [2, 4, 8]]
let g2 : [simd_double3] = [[1, 9, 8], [3, 9, 9], [4, 6, 1], [9, 0, 7], [3, 4, 6]]
let thph1 : simd_double2 = [1.1, 2.9]
let thph2 : simd_double2 = [2.1, 0.5]
let thph : simd_double4 = [1.1, 2.9, 2.1, 0.5]
var ang : simd_double4 = thph
// polar unit vector: [sin(theta)cos(phi), sin(theta)sin(phi), cos(theta)]
func polarUnitVector(pArgs: simd_double2) -> simd_double3 {
    return [sin(pArgs[0])*cos(pArgs[1]), sin(pArgs[0])*sin(pArgs[1]), cos(pArgs[0])]
}

func polarUnitVectors(pArgs: simd_double4) -> [simd_double3] {
    return [polarUnitVector(pArgs: pArgs.lowHalf), polarUnitVector(pArgs: pArgs.highHalf)]
}

// d/dtheta (polar unit vector): [cos(theta)cos(phi), cos(theta)sin(phi), -sin(theta)]
func polarUnitVectorDtheta(pArgs: simd_double2) -> simd_double3 {
    return [cos(pArgs[0])*cos(pArgs[1]), cos(pArgs[0])*sin(pArgs[1]), -sin(pArgs[0])]
}

func polarUnitVectorsDtheta(pArgs: simd_double4) -> [simd_double3] {
    return [polarUnitVectorDtheta(pArgs: pArgs.lowHalf), polarUnitVectorDtheta(pArgs: pArgs.highHalf)]
}

// d/dphi (polar unit vector): [-sin(theta)sin(phi), sin(theta)cos(phi), 0]
func polarUnitVectorDphi(pArgs: simd_double2) -> simd_double3 {
    return [-sin(pArgs[0])*sin(pArgs[1]), sin(pArgs[0])*cos(pArgs[1]), 0]
}

func polarUnitVectorsDphi(pArgs: simd_double4) -> [simd_double3] {
    return [polarUnitVectorDphi(pArgs: pArgs.lowHalf), polarUnitVectorDphi(pArgs: pArgs.highHalf)]
}

// returns a list of local joint axis errors
func localJointAxisErrorList(g: [[simd_double3]], pArgs: simd_double4) -> [Double] {
    let pVecs : [simd_double3] = polarUnitVectors(pArgs: pArgs)
    var errorList = [Double]()
    for row in 0..<min(g[0].count, g[1].count) {
        errorList.append(simd_length(simd_cross(g[0][row],pVecs[0])) - simd_length(simd_cross(g[1][row],pVecs[1])))
    }
    return errorList
}

func localJointAxisErrorJacobian(g: [[simd_double3]], pArgs: simd_double4) -> [[Double]] {
    let pVecs : [simd_double3] = polarUnitVectors(pArgs: pArgs)
    let pVecsDtheta : [simd_double3] = polarUnitVectorsDtheta(pArgs: pArgs)
    let pVecsDphi : [simd_double3] = polarUnitVectorsDphi(pArgs: pArgs)
    
    var dTermG1 = simd_double3()
    var dTermG2 = simd_double3()
    var jacobian = [[Double]]()
    
    for row in 0..<min(g[0].count, g[1].count) {
        dTermG1 = -g[0][row]*simd_dot(g[0][row],pVecs[0])/simd_length(simd_cross(g[0][row],pVecs[0]))
        dTermG2 = g[1][row]*simd_dot(g[1][row],pVecs[1])/simd_length(simd_cross(g[1][row],pVecs[1]))
        jacobian.append([simd_dot(dTermG1,pVecsDtheta[0]), simd_dot(dTermG1,pVecsDphi[0]), simd_dot(dTermG2,pVecsDtheta[1]), simd_dot(dTermG2,pVecsDphi[1])])
    }
    return jacobian
}

func nextGaussNewtonJointAxis(g: [[simd_double3]], pArgs: simd_double4) -> simd_double4 {
    var returnVal = simd_double4()
    let JJ : [[Double]] = localJointAxisErrorJacobian(g: [g1, g2], pArgs: pArgs)
    returnVal = pArgs - simd_double4(mmult(mat1: mmult(mat1: gaussJordanInverse(mmult(mat1: JJ.transpose(),mat2: JJ)),mat2: JJ.transpose()),mat2: localJointAxisErrorList(g: g, pArgs: pArgs)))

    if abs(returnVal[0]) > Double.pi
    {
        returnVal[0] = returnVal[0].truncatingRemainder(dividingBy: Double.pi)
    }
    
    if returnVal[0] < 0
    {
        returnVal[0] += Double.pi
    }
    
    if abs(returnVal[1]) > 2*Double.pi
    {
        returnVal[1] = returnVal[1].truncatingRemainder(dividingBy: 2*Double.pi)
    }
    
    if returnVal[1] < 0
    {
        returnVal[1] += 2*Double.pi
    }
    
    if abs(returnVal[2]) > Double.pi
    {
        returnVal[2] = returnVal[2].truncatingRemainder(dividingBy: Double.pi)
    }
    
    if returnVal[2] < 0
    {
        returnVal[2] += Double.pi
    }
    
    if abs(returnVal[3]) > 2*Double.pi
    {
        returnVal[3] = returnVal[3].truncatingRemainder(dividingBy: 2*Double.pi)
    }
    
    if returnVal[3] < 0
    {
        returnVal[3] += 2*Double.pi
    }

    return returnVal
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0+size, count)])
        }
    }
}

extension Collection where Self.Iterator.Element: RandomAccessCollection {
    // PRECONDITION: `self` must be rectangular, i.e. every row has equal size.
    func transpose() -> [[Self.Iterator.Element.Iterator.Element]] {
        guard let firstRow = self.first else { return [] }
        return firstRow.indices.map { index in
            self.map{ $0[index] }
        }
    }
}

func mmult(mat1: [[Double]], mat2: [[Double]]) -> [[Double]] {
    let mat2t = mat2.transpose()
    let m = mat1.count
    let n = mat2[0].count
    var mat1i = [Double]()
    var result : [[Double]] = Array(repeating: Array(repeating: 0, count: n), count: m)
    for i in 0..<m {
        mat1i = mat1[i]
        for j in 0..<n {
            result[i][j] = zip(mat1i,mat2t[j]).map(*).reduce(0,+)
        }
    }
    return result
}

func mmult(mat1: [[Double]], mat2: [Double]) -> [Double] {
    let m = mat1.count
    var result : [Double] = Array(repeating: 0, count: m)
    for i in 0..<m { result[i] = zip(mat1[i],mat2).map(*).reduce(0,+) }
    return result
}
/*
func TwoDimensionalDoubleMatrixToSimd_Double4x4(TwoDMatrix: [[Double]]) -> simd_double4x4
{
    return simd_double4x4(simd_double4(TwoDMatrix[0]), simd_double4(TwoDMatrix[1]), simd_double4(TwoDMatrix[2]), simd_double4(TwoDMatrix[3]))
}

func Simd_Double4x4ToTwoDimensionalDoubleMatrix(Simd_Double4x4: simd_double4x4) -> [[Double]]
{
    return [
        [ Simd_Double4x4[0][0], Simd_Double4x4[0][1], Simd_Double4x4[0][2], Simd_Double4x4[0][3]  ],
        
        [ Simd_Double4x4[1][0], Simd_Double4x4[1][1], Simd_Double4x4[1][2], Simd_Double4x4[1][3]  ],
        
        [ Simd_Double4x4[2][0], Simd_Double4x4[2][1], Simd_Double4x4[2][2], Simd_Double4x4[2][3]  ],
        
        [ Simd_Double4x4[3][0], Simd_Double4x4[3][1], Simd_Double4x4[3][2], Simd_Double4x4[3][3]  ]
    ]
}*/

/*
 USED FOR MANUALLY INVERTING A MATRIX
 */
func augment(_ matrix: [[Double]]) -> [[Double]] {
    var augmented = matrix
    var idrow = Array(repeating: 0.0, count: matrix.count)
    idrow[0] = 1.0
    for row in 0..<matrix.count {
        augmented[row] += idrow
        idrow.insert(0.0, at:0)
        idrow.removeLast()
    }
    return augmented
}
 
func deaugment(_ matrix: [[Double]]) -> [[Double]] {
    var deaugmented = matrix
    
    for row in 0..<matrix.count {
        for _ in 0..<matrix.count {
            deaugmented[row].remove(at:0)
        }
    }
    return deaugmented
}
 
func partialPivot(_ matrix: inout [[Double]]) {
    for row1 in 0..<matrix.count {
        for row2 in row1..<matrix.count {
            if abs(matrix[row1][row1]) < abs(matrix[row2][row2]) {
                (matrix[row1],matrix[row2]) = (matrix[row2],matrix[row1])
            }
        }
    }
}
 
func scaleRow(_ matrix: inout [[Double]], row: Int, scale: Double) {
    for col in 0..<matrix[row].count {
        matrix[row][col] *= scale
    }
}
 
func addRow(_ matrix: inout [[Double]], row: Int, scaledBy: Double, toRow: Int) {
    for col in 0..<matrix[row].count {
        matrix[toRow][col] += scaledBy * matrix[row][col]
    }
}
 
func pivot(_ matrix: inout [[Double]], row pivotRow: Int, col pivotCol: Int, forward: Bool) {
    let scale = 1.0 / matrix[pivotRow][pivotCol]
    scaleRow(&matrix, row: pivotRow, scale: scale)
    
    if forward {
        for toRow in (pivotRow+1)..<matrix.count {
            let scaleBy = -1.0 * matrix[toRow][pivotCol]
            addRow(&matrix, row: pivotRow, scaledBy: scaleBy, toRow: toRow)
        }
    } else {
        for toRow in (0..<pivotRow).reversed() {
            let scaleBy = -1.0 * matrix[toRow][pivotCol]
            addRow(&matrix, row: pivotRow, scaledBy: scaleBy, toRow: toRow)
        }
    }
}
 
func gaussJordanInverse(_ matrix: [[Double]]) -> [[Double]] {
    var matrix = augment(matrix)
    partialPivot(&matrix)
    
    for p in 0..<matrix.count {
        pivot(&matrix, row: p, col: p, forward: true)
    }
    
    for p in (0..<matrix.count).reversed() {
        pivot(&matrix, row: p, col: p, forward: false)
    }
 
    matrix = deaugment(matrix)
    
    return matrix
}
/*
 USED FOR MANUALLY INVERTING A MATRIX
 */

let lst : [simd_float2] = [[1,2],[3,4]]
let lst2 : [simd_float2] = [[0,1],[1,0]]
let lst3 : [[Double]] = [[1,2,3],[4,5,6],[7,8,9]]
let lst4 : [[Double]] = [[1,3,0.5,2],[6,-4,3,1],[2,2.5,4,3]]
let lst5 : [Double] = [3,4,5,6]
//print(mmult(mat1: lst4,mat2: lst5))
//print(mmult(mat1: lst3, mat2: lst4))

struct CalibrationTest : View {
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                Text("Summary filler text")
                Spacer()
                Button(
                    "Return to home", action: {
                       
                       
                        ang = nextGaussNewtonJointAxis(g: [g1, g2], pArgs: ang)
                        
                        print(ang)
                        
                        print()
                    }
                ).buttonStyle(RoundedRectangleButtonStyle())
            }
        }
    }
}

struct CalibrationTest_Previews: PreviewProvider {
    static var previews: some View {
        CalibrationTest()
    }
}



