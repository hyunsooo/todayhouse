//
//  Model.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/24.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import Foundation

struct Model: Decodable {
    let id: Int
    let imageUrl: String
    let nickname: String
    let profileImageUrl: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl = "image_url"
        case nickname
        case profileImageUrl = "profile_image_url"
        case description
    }
}


struct Filter {
    let title: String
    let value: String
}
