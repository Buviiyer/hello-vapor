//
//  TasksController.swift
//  App
//
//  Created by Buvi R on 4/30/18.
//

import Foundation
import Vapor

class TasksController {
    func getAllTasks(request :Request) -> ResponseRepresentable {
        return "get all tasks"
    }
    
    func getTasksByID(request :Request) -> ResponseRepresentable {
        
        guard let taskID = request.parameters["taskID"]?.int else {
            fatalError("task id not found")
        }
        return "the task id is \(taskID)"
    }
}
