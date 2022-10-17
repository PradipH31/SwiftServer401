import Vapor

func routes(_ app: Application) throws {

  let book1 = Book(id: 1, name: "The Castle in the Sky", author: "ABC", date: "2022")
  let book2 = Book(id: 2, name: "Lily Daw", author: "Eudora Welty", date: "1950")
  let book3 = Book(id: 3, name: "Christopher Columbus", author: "ABC", date: "1990")
  var books = [book1, book2, book3]

  app.get("books") {
    req async -> Array in
    return books
  }

  app.get("books", ":id") {
    req async -> Book in
    guard let id: Int = req.parameters.get("id") else {
      throw Abort(.internalServerError)
    }
    return books[id - 1]
  }

  app.delete("books", ":id") {
    req -> DeleteResponse in
    guard let id: Int = req.parameters.get("id") else {
      throw Abort(.internalServerError)
    }
    if id > 0 && id < books.count {
      books.remove(at: (id+1))
      return DeleteResponse(isDeleted: true)
    }
    return DeleteResponse(isDeleted: false)
  }

  app.post("books"){
    req -> CreateResponse in

    let newBookCreate: BookCreate = try req.content.decode(BookCreate.self)
    let newBook = Book(id:books.count+1,name:newBookCreate.name,author:newBookCreate.author,date:newBookCreate.date)
    books.append(newBook)
    return CreateResponse(created:true, id:newBook.id)
  }
}

struct DeleteResponse: Content {
  let isDeleted: Bool
}

struct BookCreate: Content {
  let name: String
  let author: String
  let date: String
}

struct CreateResponse: Content {
    let created: Bool
    let id: Int
}

struct Book: Content {
  let id: Int
  let name: String
  let author: String
  let date: String
}
