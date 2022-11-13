import Vapor

struct User: Authenticatable {
    var name: String
}