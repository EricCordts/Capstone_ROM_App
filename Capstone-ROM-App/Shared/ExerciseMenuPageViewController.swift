//
//  ExerciseMenuPageViewController.swift
//  Capstone-ROM-App (iOS)
//
//  Created by Colin Regan on 3/8/22.
//

import Foundation
import UIKit

class ExerciseMenuPageViewController: UIViewController {
    var exercises: [Exercise] = []
    var modelController: ModelController!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let list = modelController.exercises
        self.exercises = list
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let editViewController = segue.destination as?  {
//            editViewController.modelController = modelController
//        }
//    }
}
