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
    @ObservedObject var bleManager: BluetoothViewController
    @ObservedObject var angle: angleClass

    var body : some View {
        ZStack{
            // create a background with a linear gradient
            LinearGradient(gradient: Gradient(colors: [CustomColors.BackgroundColorBlue, CustomColors.BackgroundColorGreen]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            GeometryReader { geo in

            VStack{
                if exercisesCompleted
                {
                    CompletedWorkoutView()
                        .onAppear{
                            self.exercise.exerciseCompleted = true
                            /*self.bleManager.angle.clear()
                            self.bleManager.angle.runCalibration = false
                            self.bleManager.angle.runAngleCalculation = false
                            self.bleManager.angle.storeData = false
                            self.bleManager.angle.reallyRunCalibration = false
                            self.bleManager.angle.reallyRunAngleCalculation = false*/
                        }
                }
                else
                {
                    Text(exercise.exerciseName)
                        .font(.title)
                        .fontWeight(.bold).multilineTextAlignment(.center).frame(width: geo.size.width * 0.98, height: geo.size.height * 0.1)
                    
                    Image(exercise.wearablePlacementImageOn).resizable().frame(width: geo.size.width * 0.67, height: geo.size.height * 0.33)
                    
                    Text("\(exercise.instructions)").font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.14)
                    
                    HStack{
                        Text("Sets left: \(exercise.numberOfSets - setsCompleted)  |  Reps left: \(exercise.numberOfReps - repsCompleted)").font(.title3)
                            .multilineTextAlignment(.center)
                            .frame(width: geo.size.width * 0.95, height: geo.size.height * 0.10)
                    }
                    
                    Text("\(angle.angle)")
                    
                    Image("ColorBar").resizable().frame(width: geo.size.width, height: geo.size.height * 0.10).overlay( GeometryReader { topLevelImageGeo in
                        Image(systemName: "square").resizable().frame(width: topLevelImageGeo.size.width * 0.20, height: topLevelImageGeo.size.height).foregroundColor(Color.gray).position(x: topLevelImageGeo.size.width/1.6, y: topLevelImageGeo.size.height/2)
                    })
                    
                    // temp button to decrease reps
                    Button(
                        "Decrease reps", action: {let result = ModifySetsReps(currentRepsCompleted: &repsCompleted, targetReps: exercise.numberOfReps, currentSetsCompleted: &setsCompleted, targetSets: exercise.numberOfSets)
                            setsCompleted = result.setsCompleted
                            repsCompleted = result.repsCompleted
                            exercisesCompleted = result.exercisesCompleted
                            
                        }
                    ).buttonStyle(RoundedRectangleButtonStyle())
                }
            }.transition(.slide).animation(.easeIn(duration: 1), value: exercisesCompleted)
            }
        }.onAppear
        {
            self.angle.setStoreData(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.bleManager.runAngleCalculation = true
            }
            
            /*self.bleManager.angle.runCalibration = false
            self.bleManager.angle.runAngleCalculation = false
            self.bleManager.angle.storeData = true
            self.bleManager.angle.setMaxSize(size: 5)
            self.bleManager.angle.reallyRunCalibration = false
            self.bleManager.angle.reallyRunAngleCalculation = true
            // after approximately 1 second, there should be enough data collected to run angle calculations
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.bleManager.angle.runAngleCalculation = true
            }*/
        }
    }
}

/*
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView(exercise: exercisesData[0])
    }
}
*/

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
