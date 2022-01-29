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
            Image("ROMSymbol").resizable().frame(width: 75.0, height: 75.0)
            //Text(bodyPart.imageName).font(.title2)
            Text(exercise.exerciseName).font(.largeTitle)
            Spacer()
        }
    }
}

struct BodyPartRow_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseRow(exercise: exercises[3])
    }
}
