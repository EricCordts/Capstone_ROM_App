//
//  Exercise.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//

import Foundation
import SwiftUI

struct Exercise : Identifiable{
    var id: Int
    var exerciseName: String
    var description: String

    var imageName: String
    //var image: Image {
    //    Image(imageName)
    //}
    
    var numberOfSets: Int
    var numberOfReps: Int
}
