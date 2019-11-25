//
//  Cat.swift
//  App
//
//  Created by vorona.vyacheslav on 2019/11/25.
//

final class Cat {
    var id: Int?
    var name: String
    var age: Int
    private var breedString: String
    
    var breed: Breed? {
        return Breed(rawValue: breedString)
    }
    
    var json: [String: Any] {
        return [
            "name": name,
            "age": age,
            "breedString": breedString
        ]
    }

    init(id: Int? = nil, name: String, age:Int, breed: Breed) {
        self.id = id
        self.name = name
        self.age = age
        self.breedString = breed.rawValue
    }
    
    static func make(from json: [String: Any]) -> Cat? {
        guard let name = json["name"] as? String else { return nil }
        guard let age = json["age"] as? Int else { return nil }
        guard let breedString = json["breedString"] as? String,
            let breed = Breed(rawValue: breedString) else { return nil }
        let id = json["id"] as? Int
        
        return Cat(id: id, name: name, age: age, breed: breed)
    }
}

#if canImport(Vapor) && canImport(FluentSQLite)

import FluentSQLite
import Vapor

extension Cat: SQLiteModel {}
extension Cat: Migration {}
extension Cat: Content {}
extension Cat: Parameter {}

#endif

// MARK: - Breed

enum Breed: String {
    case persian = "persian"
    case russianBlue = "russian blue"
    case britishShorthair = "british shorthair"
}
