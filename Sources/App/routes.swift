import Vapor

func routes(_ app: Application) throws {

  let book1 = Book(id: 1, name: "A Room with a View", author: "E. M. Forster", date: "1908")
  let book2 = Book(
    id: 2, name: "Little Women; Or, Meg, Jo, Beth, and Amy", author: "Louisa May Alcott",
    date: "1868")
  let book3 = Book(id: 3, name: "Moby Dick", author: "Herman Melville", date: "1851")
  var books = [book1, book2, book3]

  let book1WithFile = BookWithFile(
    id: 1, name: "A Room with a View", author: "E. M. Forster", date: "1908",
    link: "http://127.0.0.1:8080/books/A Room with a View by E. M. Forster.epub")
  let book2WithFile = BookWithFile(
    id: 2, name: "Little Women; Or, Meg, Jo, Beth, and Amy", author: "Louisa May Alcott",
    date: "1868",
    link:
      "http://127.0.0.1:8080/books/Little Women; Or, Meg, Jo, Beth, and Amy by Louisa May Alcott.epub"
  )
  let book3WithFile = BookWithFile(
    id: 3, name: "Moby Dick", author: "Herman Melville", date: "1851",
    link: "http://127.0.0.1:8080/books/Moby Dick; Or, The Whale by Herman Melville.epub")
  var booksWithFiles = [book1WithFile, book2WithFile, book3WithFile]

  let file = FileMiddleware(publicDirectory: app.directory.publicDirectory)
  app.middleware.use(file)

  let protected = app.grouped(UserAuthenticator())
  protected.get("me") { req -> String in
    try req.auth.require(User.self).name
  }

  protected.get("buy", ":id") {
    req async throws -> BookWithFile in
    try req.auth.require(User.self).name
    guard let id: Int = req.parameters.get("id") else {
      throw Abort(.internalServerError)
    }
    return booksWithFiles[id - 1]
  }

  //protected.post("new_book")

  app.get("books") {
    req async -> Array in
    return books
  }

  app.get("books", ":id") {
    req async throws -> Book in
    guard let id: Int = req.parameters.get("id") else {
      throw Abort(.internalServerError)
    }
    return books[id - 1]
  }

  protected.delete("books", ":id") {
    req -> DeleteResponse in
    try req.auth.require(User.self).name
    guard let id: Int = req.parameters.get("id") else {
      throw Abort(.internalServerError)
    }
    if id > 0 && id < books.count {
      books.remove(at: (id - 1))
      return DeleteResponse(isDeleted: true)
    }
    return DeleteResponse(isDeleted: false)
  }

  protected.post("books") {
    req -> CreateResponse in
    try req.auth.require(User.self).name

    let newBookCreate: BookCreate = try req.content.decode(BookCreate.self)
    let newBook = Book(
      id: books.count + 1, name: newBookCreate.name, author: newBookCreate.author,
      date: newBookCreate.date)
    books.append(newBook)
    return CreateResponse(created: true, id: newBook.id)
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

struct BookWithFile: Content {
  let id: Int
  let name: String
  let author: String
  let date: String
  let link: String
}
