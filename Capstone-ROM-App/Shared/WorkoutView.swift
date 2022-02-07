//
//  WorkoutView.swift
//  Capstone-ROM-App
//
//  Created by Eric Cordts on 2/1/22.
//

import SwiftUI

struct WorkoutView : View {
    @State var exercisesCompleted:Bool = false
    @State var setsCompleted = 0
    @State var repsCompleted = 0
    @ObservedObject var exercise: Exercise
    var body : some View {
        
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack{
                if exercisesCompleted
                {
                    CompletedWorkoutView()
                        .transition(.slide).onAppear{
                            self.exercise.exerciseCompleted.toggle()
                        }
                }
                else{
                    Text(exercise.exerciseTip)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    // temp image
                    Image("ROMSymbol").resizable().frame(width: 250, height: 250)
                    
                    HStack{
                        Text("Sets left: " + String(exercise.numberOfSets - setsCompleted) + "  |  Reps left: " + String(exercise.numberOfReps - repsCompleted))
                    }.padding()
                    
                    Text("Filler text for where moving bar would go").padding()
                    
                    Text("Instruction filler")
                    Text("Instruction 1 filler")
                    Text("Instruction 2 filler")
                    Text("Instruction 3 filler")
                    
                    // temp button to decrease reps
                    Button(
                        "Decrease reps", action: {let result = ModifySetsReps(currentRepsCompleted: &repsCompleted, targetReps: exercise.numberOfReps, currentSetsCompleted: &setsCompleted, targetSets: exercise.numberOfSets)
                            setsCompleted = result.setsCompleted
                            repsCompleted = result.repsCompleted
                            exercisesCompleted = result.exercisesCompleted
                            
                        }
                    ).buttonStyle(RoundedRectangleButtonStyle())
                }
            }
        }
    }
}

//struct WorkoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutView(exercise: exercises[0])
//    }
//}

func ModifySetsReps(currentRepsCompleted: inout Int, targetReps: Int, currentSetsCompleted: inout Int, targetSets: Int)->(repsCompleted: Int, setsCompleted: Int, exercisesCompleted: Bool)
{
    var exercisesCompleted : Bool = false
    if currentRepsCompleted < targetReps && currentSetsCompleted < targetSets
    {
        currentRepsCompleted += 1
    }
    if currentRepsCompleted == targetReps && currentSetsCompleted < targetSets - 1
    {
        currentRepsCompleted = 0
        currentSetsCompleted += 1
    }
    
    if currentRepsCompleted == targetReps && currentSetsCompleted == targetSets - 1
    {
        currentSetsCompleted = targetSets
        exercisesCompleted = true
    }

    return (currentRepsCompleted, currentSetsCompleted, exercisesCompleted)
}
