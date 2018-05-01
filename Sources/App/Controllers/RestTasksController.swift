//
//  RestTasksController.swift
//  App
//
//  Created by Buvi R on 4/30/18.
//

import Foundation
import Vapor
import HTTP

final class RestTasksController : ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return "Index"
    }
    
    func create(_ req: Request) throws -> ResponseRepresentable {
        return "Create"
    }
    
    func show(_ req: Request, post:String) throws -> ResponseRepresentable {
        return "Show"
    }
    
    func delete(_ req: Request, post:String) throws -> ResponseRepresentable {
        return "Delete"
    }
    
    func makeResource() -> Resource<String> {
        return Resource(
            index: index,
            store: create,
            show: show,
            destroy: delete
        )
    }
}

extension RestTasksController: EmptyInitializable { }
