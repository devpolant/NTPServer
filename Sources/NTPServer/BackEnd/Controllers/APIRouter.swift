//
//  APIController.swift
//  NTPServer
//
//  Created by Anton Poltoratskyi on 17.04.17.
//
//

import Kitura

protocol APIRouter {
    var router: Router { get set }
}
