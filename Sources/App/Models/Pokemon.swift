//
//  Pokemon.swift
//  App
//
//  Created by Buvi R on 4/30/18.
//

import Vapor
import FluentProvider
import HTTP

final class Pokemon: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var name: String
    
    /// Creates a new Post
    init(name: String) {
        self.name = name
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        name = try row.get("name")
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

// MARK: Fluent Preparation

extension Pokemon: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Pokemon: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get("name")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Pokemon: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Pokemon: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Pokemon>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey("name", String.self) { post, name in
                post.name = name
            }
        ]
    }
}

