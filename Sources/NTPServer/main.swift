import Foundation
import Kitura
import HeliumLogger

HeliumLogger.use()

let backend = BackEnd()
let frontend = FrontEnd()

Kitura.addHTTPServer(onPort: 8089, with: backend.router)
Kitura.addHTTPServer(onPort: 8090, with: frontend.router)

Kitura.run()
