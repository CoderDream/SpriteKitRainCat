
//
//  Constants.swift
//  RainCat
//
//  Created by CoderDream on 2019/1/3.
//  Copyright © 2019 CoderDream. All rights reserved.
//

import Foundation

// 通过移位运算符来为不同物理实体的categoryBitMasks设置不同的唯一值
let WorldCategory       : UInt32 = 0x1 << 1
let RainDropCategory    : UInt32 = 0x1 << 2
let FloorCategory       : UInt32 = 0x1 << 3
let CatCategory         : UInt32 = 0x1 << 4
let FoodCategory        : UInt32 = 0x1 << 5

let ScoreKey = "RAINCAT_HIGHSCORE"
let MuteKey = "RAINCAT_MUTED"
