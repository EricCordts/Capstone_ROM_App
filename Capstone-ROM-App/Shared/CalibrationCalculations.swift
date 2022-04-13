//
//  CalibrationCalculations.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Eric Cordts on 2/8/22.
//

import SwiftUI
import Accelerate
import Foundation

// returns a polar unit vector when given Double([zenith angle, azimuthal angle]) in radians
// [sin(theta)cos(phi), sin(theta)sin(phi), cos(theta)]
func puVec(_ pArgs: [Float]) -> [Float] {
    return [sin(pArgs[0])*cos(pArgs[1]), sin(pArgs[0])*sin(pArgs[1]), cos(pArgs[0])]
}
// returns 2 puVec
func puVecs(_ pArgs: [[Float]]) -> [[Float]] { return [puVec(pArgs[0]), puVec(pArgs[1])] }

// derivative of polar unit vector with respect to zenith angle
// [cos(theta)cos(phi), cos(theta)sin(phi), -sin(theta)]
func puVecDzen(_ pArgs: [Float]) -> [Float] {
    return [cos(pArgs[0])*cos(pArgs[1]), cos(pArgs[0])*sin(pArgs[1]), -sin(pArgs[0])]
}
// returns 2 puVecDzen
func puVecsDzen(_ pArgs: [[Float]]) -> [[Float]] { return [puVecDzen(pArgs[0]), puVecDzen(pArgs[1])] }

// derivative of polar unit vector with respect to azimuthal angle
// [-sin(theta)sin(phi), sin(theta)cos(phi), 0]
func puVecDazi(_ pArgs: [Float]) -> [Float] {
    return [-sin(pArgs[0])*sin(pArgs[1]), sin(pArgs[0])*cos(pArgs[1]), 0]
}
// returns 2 puVecDazi
func puVecsDazi(_ pArgs: [[Float]]) -> [[Float]] { return [puVecDazi(pArgs[0]), puVecDazi(pArgs[1])] }

func mod(_ x: Float, _ m: Float) -> Float {
    let r = fmod(x, m)
    return r >= 0 ? r : r+m
}

func modpAngs(_ x: [[Float]]) -> [[Float]] {
    var xm = x
    for i in 0..<xm.count {
        xm[i][0] = mod(xm[i][0],Float.pi)
        xm[i][1] = mod(xm[i][1],2*Float.pi)
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
 
// returns the inverse of an nxn matrix
func inv(_ mat: [[Float]]) -> [[Float]] {
    var matinv = mat.flatMap() {$0.map(){Double($0)}}
    var N = __CLPK_integer(sqrt(Double(matinv.count)))
    let n = Int(N)
    var pivots = [__CLPK_integer](repeating: 0, count: n)
    var workspace = [Double](repeating: 0.0, count: n)
    var error : __CLPK_integer = 0
    
    withUnsafeMutablePointer(to: &N) {
        dgetrf_($0, $0, &matinv, $0, &pivots, &error)
        dgetri_($0, &matinv, $0, &pivots, &workspace, $0, &error)
    }
    return matinv.map { Float($0) }.chunked(n)
}

// returns the left Moore-Penrose pseudoinverse of an mxn matrix
public func pinv(_ A: [[Float]]) -> [[Float]] {
    let _A = transpose(A.map(){$0.map(){Double($0)}})
    var _Af = _A.flatMap(){$0}
    let job : UnsafeMutablePointer<Int8> = UnsafeMutablePointer(mutating: ("A" as NSString).utf8String!)
    var _m : __CLPK_integer = __CLPK_integer(A.count)
    var _n : __CLPK_integer = __CLPK_integer(_A.count)
    var lda : __CLPK_integer = _m
    var ldu : __CLPK_integer = _m
    var ldvt : __CLPK_integer = _n
    let m = Int(_m)
    let n = Int(_n)
    
    var s : [Double] = [Double](repeating: 0.0, count: n)
    var u : [Double] = [Double](repeating: 0.0, count: Int(ldu*_m))
    var vt : [Double] = [Double](repeating: 0.0, count: Int(ldvt*_n))
    var wkopt : __CLPK_doublereal = 0
    var lwork : __CLPK_integer = -1
    var info : __CLPK_integer = 0
    var iwork : [__CLPK_integer] = [__CLPK_integer](repeating: 0, count: 8*min(n,m))
    dgesdd_(job, &_m, &_n, &_Af, &lda, &s, &u, &ldu, &vt, &ldvt, &wkopt, &lwork, &iwork, &info)
    lwork = __CLPK_integer(wkopt)
    var work = [Double](repeating: 0.0, count: Int(lwork))
    dgesdd_(job, &_m, &_n, &_Af, &lda, &s, &u, &ldu, &vt, &ldvt, &work, &lwork, &iwork, &info)
    
    /* Check for convergence */
    //if( info > 0 ) {} // the algorithm computing SVD failed to converge
    //if( info < 0 ) {} // wrong parameters provided
    
    if (m>n) {
        var VT : [[Double]] = transpose(vt.chunked(n))
        for i in 0..<n { VT[i] = s[i] == 0 ? svmult(VT[i],0) : svmult(VT[i],1/s[i]) }
        return mmult(transpose(VT),[[Double]](u.chunked(m)[0..<n])).map(){$0.map(){Float($0)}}
    }
    else if (n>m) {
        var UT : [[Double]] = u.chunked(m)
        for i in 0..<m { UT[i] = s[i] == 0 ? svmult(UT[i],0) : svmult(UT[i],1/s[i]) }
        return mmult(transpose([[Double]](transpose(vt.chunked(n))[0..<m])),UT).map(){$0.map(){Float($0)}}
    }
    else {
        var UT : [[Double]] = u.chunked(m)
        for i in 0..<m { UT[i] = s[i] == 0 ? svmult(UT[i],0) : svmult(UT[i],1/s[i]) }
        return mmult(vt.chunked(n),UT).map(){$0.map(){Float($0)}}
    }
}

// returns the transpose of a rectangular matrix
func transpose<T>(_ mat: [[T]]) -> [[T]] {
    guard let firstRow = mat.first else { return [] }
    return firstRow.indices.map { index in mat.map{ $0[index] } }
}

func mmult<T: Numeric>(_ mat1: [[T]], _ mat2: [[T]]) -> [[T]] {
    assert(mat1[0].count == mat2.count)
    let mat2t = transpose(mat2)
    let m = mat1.count
    let n = mat2t.count
    var mat1i = [T]()
    var result : [[T]] = [[T]](repeating: [T](repeating: 0, count: n), count: m)
    for i in 0..<m {
    mat1i = mat1[i]
    for j in 0..<n {
        result[i][j] = zip(mat1i,mat2t[j]).map(*).reduce(0,+)
}
}
    return result
}

func mmult<T: Numeric>(_ mat1: [[T]], _ mat2: [T]) -> [T] {
    let m = mat1.count
    var result = [T](repeating: 0, count: m)
    for i in 0..<m { result[i] = zip(mat1[i],mat2).map(*).reduce(0,+) }
    return result
}

func svmult<T: Numeric>(_ v: [T], _ s: T) -> [T] { return v.map(){ $0*s } }
func smmult<T: Numeric>(_ mat: [[T]], _ s: T) -> [[T]] { return mat.map(){ $0.map(){ $0*s } } }
func madd<T: Numeric>(_ mat1: [[T]], _ mat2: [[T]]) -> [[T]] { return zip(mat1,mat2).map {zip($0,$1).map(+)} }
func msub<T: Numeric>(_ mat1: [[T]], _ mat2: [[T]]) -> [[T]] { return zip(mat1,mat2).map {zip($0,$1).map(-)} }
func vadd<T: Numeric>(_ v1: [T], _ v2: [T]) -> [T] { return zip(v1,v2).map(+) }
func vsub<T: Numeric>(_ v1: [T], _ v2: [T]) -> [T] { return zip(v1,v2).map(-) }
func vdot<T: Numeric>(_ v1: [T], _ v2: [T]) -> T { return zip(v1,v2).map(*).reduce(0,+) }

func vcross<T: Numeric>(_ a: [T], _ b: [T]) -> [T] {
    return [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]
}

func trace<T: Numeric>(_ mat: [[T]]) -> T {
    var retVal : T = 0
    for i in 0..<mat[0].count { retVal += mat[i][i] }
    return retVal
}

func norm<T: FloatingPoint>(_ v: [T]) -> T { return sqrt(zip(v,v).map(*).reduce(0,+)) }
func normv<T: FloatingPoint>(_ v: [T]) -> [T] { return svmult(v,1/norm(v)) }
func matSqSumSq<T: FloatingPoint>(_ mat: [[T]]) -> T { return norm(mat.flatMap(){$0}) }

func matMTMInvErr(_ mat: [[Float]]) -> Float {
    let mtm = mmult(transpose(mat),mat)
    let n = mat[0].count
    var idn = [[Float]](repeating: [Float](repeating: 0, count: n), count: n)
    for i in 0..<n { idn[i][i] = 1 }
    let zerx = msub(mmult(inv(mtm),mtm),idn)
    return matSqSumSq(zerx)
}
