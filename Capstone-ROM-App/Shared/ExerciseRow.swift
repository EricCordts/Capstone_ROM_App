//
//  ExerciseRow.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//

import SwiftUI

struct ExerciseRow: View {
    var exercise: Exercise

    var body: some View {
        HStack {
            
            // commented out until we get actual images
            //exercise.exerciseImage.resizeable().frame(width: 60, height: 60)
            // use ROMSymbol as a temporary image
            Image("ROMSymbol").resizable().frame(width: 75.0, height: 75.0)
            Text(exercise.exerciseName).font(.largeTitle)
            Spacer()
        }
    }
}

struct ExerciseRow_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRow(exercise: exercises[3])
    }
}
