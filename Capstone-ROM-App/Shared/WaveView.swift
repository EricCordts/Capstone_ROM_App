//
//  WaveView.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Colin Regan on 3/22/22.
//

import SwiftUI 

struct Wave: Shape {
    var second: Int
    
    var animatableData: Int {
        get { second }
        set { self.second = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()

        // calculate some important values up front
        let width = Double(rect.width)
        let height = Double(rect.height)
        let _ = width / 2
        let midHeight = height / 2

        // start at the left center
        path.move(to: CGPoint(x: 0, y: midHeight))

        // now count across individual horizontal points one by one
        for _ in stride(from: 0, through: width, by: 1) {
            
            let newx = Double(second).converting(from: 0...60, to: 0...width)
            path.addLine(to: CGPoint(x: newx, y: midHeight))
        }
        
        return Path(path.cgPath)
    }

}

extension FloatingPoint {
    func converting(from input: ClosedRange<Self>, to output: ClosedRange<Self>) -> Self {
        let x = (output.upperBound - output.lowerBound) * (self - input.lowerBound)
        let y = (input.upperBound - input.lowerBound)
        return x / y + output.lowerBound
    }
}

extension BinaryInteger {
    func converting(from input: ClosedRange<Self>, to output: ClosedRange<Self>) -> Self {
        let x = (output.upperBound - output.lowerBound) * (self - input.lowerBound)
        let y = (input.upperBound - input.lowerBound)
        return x / y + output.lowerBound
    }
}

