//
//  CalibrationCalculations.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 2/8/22.
//

import SwiftUI
import Accelerate
import simd

let gq1 : [[Double]] = [[8,7,3],[6,8,1],[6,4,6],[0,7,3],[8,1,6]]
let gq2 : [[Double]] = [[4,6,5],[4,7,4],[9,1,5],[8,4,6],[3,6,3]]
let gq12 = [gq1,gq2]
let gl1 : [[Double]] = [[9,6,8],[9,5,2],[7,5,0],[3,9,0],[6,0,8]]
let gl2 : [[Double]] = [[2,4,3],[9,9,2],[9,6,3],[0,4,2],[4,8,2]]
let gl12 = [gl1,gl2]
let thph1 : [Double] = [1.1, 2.9]
let thph2 : [Double] = [2.1, 0.5]
let thph12 = [thph1, thph2]

// returns a polar unit vector when given Double([zenith angle, azimuthal angle]) in radians
// [sin(theta)cos(phi), sin(theta)sin(phi), cos(theta)]
func puVec(_ pArgs: [Double]) -> [Double] {
    return [sin(pArgs[0])*cos(pArgs[1]), sin(pArgs[0])*sin(pArgs[1]), cos(pArgs[0])]
}
// returns 2 puVec
func puVecs(_ pArgs: [[Double]]) -> [[Double]] { return [puVec(pArgs[0]), puVec(pArgs[1])] }

// derivative of polar unit vector with respect to zenith angle
// [cos(theta)cos(phi), cos(theta)sin(phi), -sin(theta)]
func puVecDzen(_ pArgs: [Double]) -> [Double] {
    return [cos(pArgs[0])*cos(pArgs[1]), cos(pArgs[0])*sin(pArgs[1]), -sin(pArgs[0])]
}
// returns 2 puVecDzen
func puVecsDzen(_ pArgs: [[Double]]) -> [[Double]] { return [puVecDzen(pArgs[0]), puVecDzen(pArgs[1])] }

// derivative of polar unit vector with respect to azimuthal angle
// [-sin(theta)sin(phi), sin(theta)cos(phi), 0]
func puVecDazi(_ pArgs: [Double]) -> [Double] {
    return [-sin(pArgs[0])*sin(pArgs[1]), sin(pArgs[0])*cos(pArgs[1]), 0]
}
// returns 2 puVecDazi
func puVecsDazi(_ pArgs: [[Double]]) -> [[Double]] { return [puVecDazi(pArgs[0]), puVecDazi(pArgs[1])] }

// returns a list of local joint axis errors
func localJointAxisErrorList(_ g: [[[Double]]], _ pArgs: [[Double]]) -> [Double] {
    let pvecs : [[Double]] = puVecs(pArgs)
    var errorList = [Double]()
    for row in 0..<min(g[0].count, g[1].count) {
        errorList.append(norm(vcross(g[0][row],pvecs[0])) - norm(vcross(g[1][row],pvecs[1])))
    }
    return errorList
}

func localJointAxisErrorJacobian(_ g: [[[Double]]], _ pArgs: [[Double]]) -> [[Double]] {
    let pvecs : [[Double]] = puVecs(pArgs)
    let pvecsDzen : [[Double]] = puVecsDzen(pArgs)
    let pvecsDazi : [[Double]] = puVecsDazi(pArgs)
    
    var jacobian = [[Double]]()
    
    for row in 0..<min(g[0].count, g[1].count) {
        let dTermG0 = -vdot(g[0][row],pvecs[0]) / norm(vcross(g[0][row],pvecs[0]))
        let dTermG1 = vdot(g[1][row],pvecs[1]) / norm(vcross(g[1][row],pvecs[1]))
        jacobian.append([dTermG0*vdot(g[0][row],pvecsDzen[0]), dTermG0*vdot(g[0][row],pvecsDazi[0]), dTermG1*vdot(g[1][row],pvecsDzen[1]), dTermG1*vdot(g[1][row],pvecsDazi[1])])
    }
    return jacobian
}

func nextGaussNewtonJointAxis(_ g: [[[Double]]], _ pArgs: [[Double]]) -> [[Double]] {
    return modpAngs(msub(pArgs,svmult(mmult(localJointAxisErrorJacobian(g, pArgs).pseudoinv(),localJointAxisErrorList(g, pArgs)),0.65).chunked(2)))
}

func nthJointAxis(_ g: [[[Double]]], _ pArgs: [[Double]], _ n: Int) -> [[Double]] {
    var pargs = pArgs
    for _ in 1...n { pargs = nextGaussNewtonJointAxis(g, pargs) }
    return pargs
}

let lst4l : [Double] = (1...16).map{_ in .random(in: 0...100)}
let lst4 = lst4l.chunked(4)
let id4 : [[Double]] = [[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]

func mod(_ x: Double, _ m: Double) -> Double {
    let r = fmod(x, m)
    return r >= 0 ? r : r+m
}

func modpAngs(_ x: [[Double]]) -> [[Double]] {
    var xm = x
    for i in 0..<xm.count {
        xm[i][0] = mod(xm[i][0],Double.pi)
        xm[i][1] = mod(xm[i][1],2*Double.pi)
    }
    return xm
}

extension Array {
    func chunked(_ size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0+size, count)])
        }
    }
}

extension Array where Self.Iterator.Element == [Double] {
    func inverse() -> [[Double]] {
        // returns the inverse of an nxn matrix
        var inMatrix = self.flatMap() {$0}
        var N = __CLPK_integer(sqrt(Double(inMatrix.count)))
        let n = Int(N)
        var pivots = [__CLPK_integer](repeating: 0, count: n)
        var workspace = [Double](repeating: 0.0, count: n)
        var error : __CLPK_integer = 0
        
        withUnsafeMutablePointer(to: &N) {
            dgetrf_($0, $0, &inMatrix, $0, &pivots, &error)
            dgetri_($0, &inMatrix, $0, &pivots, &workspace, $0, &error)
        }
        return inMatrix.chunked(n)
    }
}

extension Array where Self.Iterator.Element == [Double] {
    func pseudoinv() -> [[Double]] {
        // returns the left Moore-Penrose pseudoinverse of an nxm matrix
        let selft = self.transpose()
        return mmult(mmult(selft,self).inverse(),selft)
    }
}

extension Collection where Self.Iterator.Element: RandomAccessCollection {
    func transpose() -> [[Self.Iterator.Element.Iterator.Element]] {
        // returns the transpose of a rectangular matrix
        guard let firstRow = self.first else { return [] }
        return firstRow.indices.map { index in self.map{ $0[index] } }
    }
}

func mmult(_ mat1: [[Double]], _ mat2: [[Double]]) -> [[Double]] {
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

func mmult(_ mat1: [[Double]], _ mat2: [Double]) -> [Double] {
    let m = mat1.count
    var result : [Double] = Array(repeating: 0, count: m)
    for i in 0..<m { result[i] = zip(mat1[i],mat2).map(*).reduce(0,+) }
    return result
}

func svmult(_ v: [Double], _ s: Double) -> [Double] { return v.map(){ $0*s } }

func smmult(_ mat: [[Double]], _ s: Double) -> [[Double]] { return mat.map(){ $0.map(){ $0*s } } }

func vdot(_ v1: [Double], _ v2: [Double]) -> Double { return zip(v1,v2).map(*).reduce(0,+) }

func vcross(_ a: [Double], _ b: [Double]) -> [Double] {
    return [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]
}

func norm(_ v: [Double]) -> Double { return sqrt(zip(v,v).map(*).reduce(0,+)) }

func madd(_ mat1: [[Double]], _ mat2: [[Double]]) -> [[Double]] {
    return zip(mat1,mat2).map {zip($0,$1).map(+)}
}

func msub(_ mat1: [[Double]], _ mat2: [[Double]]) -> [[Double]] {
    return zip(mat1,mat2).map {zip($0,$1).map(-)}
}

func matSumSq(_ mat: [[Double]]) -> Double {
    let mtm = mmult(mat.transpose(),mat)
    var retVal : Double = 0
    for i in 0..<mat[0].count { retVal += mtm[i][i] }
    return retVal
}

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
                        print( nthJointAxis(gl12, thph12, 500))
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
