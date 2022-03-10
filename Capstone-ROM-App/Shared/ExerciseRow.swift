//
//  ExerciseRow.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 1/29/22.
//

import SwiftUI

struct ExerciseRow: View {
    @ObservedObject var exercise: Exercise

    var body: some View {
        HStack {
            Image(exercise.exerciseImageName).resizable().frame(width: 60.0, height: 60.0)
            Text(exercise.exerciseName).font(.largeTitle)
            Spacer()
            if exercise.exerciseCompleted
            {
                Image(systemName: "checkmark.square").resizable().frame(width: 50.0, height: 50.0)
                .foregroundColor(Color.green)
            }
            else
            {
                Image(systemName: "square").resizable().frame(width: 50.0, height: 50.0)
                    .foregroundColor(Color.gray)
            }
        }
    }
}

//struct ExerciseRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ExerciseRow(exercise: exercisesData[0])
//    }
//}
