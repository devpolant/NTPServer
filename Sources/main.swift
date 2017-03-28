import Foundation
import Kitura
import HeliumLogger

HeliumLogger.use()

let router = Router()

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
