import Vapor
import Validation
import ValidationProvider

//final class Routes: RouteCollection {
//    func build(_ builder: RouteBuilder) throws {
//
//        builder.get("version") { req in
//            let node = try Pokemon.database?.driver.raw("select sqlite_version();")
//            return try JSON(node: node)
//        }
//
//        builder.get("hello") { req in
//            var json = JSON()
//            try json.set("hello", "world")
//            return json
//        }
//
//        builder.get("plaintext") { req in
//            return "Hello, world!"
//        }
//
//        builder.get("info") { req in
//            return req.description
//        }
//
//        builder.get("description") {req in return req.description}
//
//        try builder.resource("posts", PostController.self)
//    }
//}
//
//extension Routes: EmptyInitializable { }

class User : JSONRepresentable, ResponseRepresentable, JSONInitializable {
    required convenience init(json: JSON) throws {
        try self.init(fName: json.get("firstName"), lName: json.get("lastName"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("firstName", self.fName)
        try json.set("lastName", self.lName)
        return json
    }
    
    var fName :String!
    var lName :String!
    
    init(fName :String, lName :String) {
        self.fName = fName
        self.lName = lName
    }
}


extension Droplet {
    func setupRoutes() throws {
        //email password validation
        post("employee") { req in
            guard let username = req.data["username"]?.string,
                let password = req.data["password"]?.string,
                let email = req.data["email"]?.string else {
                    return "One of the required params is missing"
            }
            
            if !password.passes(PasswordValidation()) {
                return "Password too short"
            }
            
            return "Success"
        }
        
        
        //put
        put("pokemon") { req in
            guard let id = req.json?["id"]?.int,
                let name = req.json?["name"]?.string
            else {
                fatalError("Pokemon not found")
            }
            
            guard let pokemon = try Pokemon.find(id) else {
                fatalError("Pokemon not found")
            }
            
            pokemon.name = name
            
            try pokemon.save()
            
            return try JSON(node: ["success":true])
        }
        
        //delete
        delete("pokemon") { req in
            guard let id = req.json?["id"]?.int else {
                fatalError("Pokemon not found")
            }
            guard let pokemon = try Pokemon.find(id) else {
                fatalError("Pokemon not found")
            }
            try pokemon.delete()
            return try JSON(node: ["success":true])
        }
        
        //fetch by title
        //localhost:8080/pokemon?name=Pikachu
        get("pokemon") { req in
            guard let name = req.query?["name"]?.string else {
                fatalError("Incorrect Query")
            }
            let pokemon = try Pokemon.all().filter {
                $0.name == name
            }
            return try pokemon.makeJSON()
        }
        
        //fetch by id
        get("pokemon", ":id") { req in
            guard let id = req.parameters["id"]?.int,
                let pokemon = try Pokemon.find(id)
            else {
                return try JSON(node: ["error":"Pokemon not found"])
            }
            
            return try pokemon.makeJSON()
        }
        
        //fetch all
        get("pokemon/all") { req in
            return try Pokemon.all().makeJSON()
            
        }
    
        //insert
        post("pokemon") { req in
            guard let name = req.json?["name"]?.string else {
                fatalError("Parameter name not found")
            }
            let pokemon = Pokemon(name: name)
            try pokemon.save()
            
            return try JSON(node: ["success":true])
        }
        
        //fluent provider
        get("version") { req in
            let node = try Pokemon.database?.driver.raw("select sqlite_version();")
            return try JSON(node: node)
        }
        try resource("posts", PostController.self)
        
        //controller
        let tasksController = TasksController()
        get("tasks", handler: tasksController.getAllTasks)
        
        get("tasks", ":taskID", handler: tasksController.getTasksByID)
        
        //rest controller
        
        let restTasksController = RestTasksController()
        resource("resttasks", restTasksController)
        
        //post
        post("customer") { req in
            guard let name = req.json?["name"]?.string,
                    let age = req.json?["age"]?.int
            else {
                fatalError("invalid params")
            }
            
            return "the name is \(name) and the age is \(age)"
        }
        
        //localhost:8080/v1/customers
        //localhost:8080/v1/users
        //localhost:8080/v1/admins
        group("v1") { v1 in
            // v1/customers
            v1.get("customers") { req in
                return "customers in v1"
            }
            
            v1.get("users") { req in
                    return "users in v1"
            }
                
            v1.get("admins") { req in
                    return "admins in v1"
            }
        }
        
        //grouped
        let v2 = grouped("v2")
        v2.get("customers") { req in
            return "customers in v2"
        }
        
        v2.get("users") { req in
            return "users in v2"
        }
        
        get("customer", Int.parameter) { req in
            let userID = try req.parameters.next(Int.self)
            return "customer id is \(userID)"
        }
        
        
        //localhost:8080/movies/genre/year
        get("movies/:genre/:year") { req in
            guard let genre = req.parameters["genre"]?.string,
                    let year = req.parameters["year"]?.int else {
                            fatalError("invalid params")
            }
            return "genre is \(genre) and year is \(year)"
        }
        
        //localhost:8080/user/12
        get("user", ":id") { req in
            guard let userID = req.parameters["id"]?.int else {
                fatalError("id not found")
            }
            return "user id is \(userID)"
        }
        
        //JSONInitializable
        get("userjsoninit") { req in
            var json = JSON()
            try json.set("firstName", "Sabil")
            try json.set("lastName", "Rahim")
            
            let user = try User(json: json)
            return user
        }
        
        //User Array
        get("usersarray") { req in
            var users = [User]()
            users.append(User(fName: "Buvi", lName: "Ramanathan"))
            users.append(User(fName: "Sonal", lName: "Patidar"))
            users.append(User(fName: "Narayan", lName: "Hebbar"))
            
            return try users.makeJSON()
        }
        
        // User class
        get("userclass") { req in
            let user = User(fName: "Buvi", lName: "Ramanathan")
            return try user.makeJSON()
        }
        
        //ResponseRepresentable
        get("userresp") { req in
            let user = User(fName: "Buvi", lName: "Ramanathan")
//            return try user.makeJSON() //response representable
            return user
        }
        
        get("user") { req in
            var json = JSON()
            try json.set("firstName", "John")
            try json.set("lastName", "Doe")
            return json
        }
        
        get("userdict") { req in
            
            let dictionary = ["firstName":"John", "lastName":"Doe"]
            var json = JSON()
            try json.set("user", dictionary)
            return json
        }

        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }

        try resource("posts", PostController.self)
    }
}
