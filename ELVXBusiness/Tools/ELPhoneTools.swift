//
//  ELPhoneTools.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/26.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation

struct ELPhoneTools {

    static let shared = ELPhoneTools()
    private init() { }

    func generateSelectedIndexes(_ selectedCellIndexes: [Int], dataArray: [String]) -> [Int] {

        var selectedIndexes = selectedCellIndexes
        if selectedIndexes.count == 1 && selectedIndexes[0] == 0 {
            selectedIndexes.removeAll()

            // 随机取几个数呢？
            let randomNum = max(1, random(dataArray.count + 1))
            if randomNum == dataArray.count {
                // 全取
                var addtional: Int = -1
                selectedIndexes = Array(repeating: -1, count: dataArray.count).map { (item) -> Int in
                    addtional += 1
                    return addtional
                }
            } else {
                // 随机取
                var addtional: Int = -1
                var allIndexes = Array(repeating: -1, count: dataArray.count).map { (item) -> Int in
                    addtional += 1
                    return addtional
                }
                for _ in 0 ..< randomNum {
                    let _random = random(allIndexes.count)
                    selectedIndexes.append(allIndexes[_random])
                    allIndexes.remove(at: _random)
                }
            }
        } else {
            // "随机"占了索引0的位置，后面的索引实际上都比自身大1，因此要减去1
            selectedIndexes = selectedCellIndexes.map { $0 - 1 }
        }
        return selectedIndexes
    }

    func random(_ uniform: Int = 10) -> Int {
        return Int(arc4random_uniform(UInt32(uniform)))
    }

    func diffNumber(_ compare: Int...) -> Int {
        var diff: Int = random()
        while compare.contains(diff) {
            diff = random()
        }
        return diff
    }

    func generatePhoneNumber(with prefix: ELPhonePrefix, medium: ELPhoneMedium, suffix: ELPhoneSuffix) -> String? {

        let phonePrefix = prefix.rawValue

        var medium4: Int = 1
        var medium5: Int = 1
        var medium6: Int = 1
        var medium7: Int = 1

        var suffix8: Int = 1
        var suffix9: Int = 1
        var suffix10: Int = 1
        var suffix11: Int = 1

        switch medium {
        case .AAAA:
            medium4 = random()
            medium5 = medium4
            medium6 = medium4
            medium7 = medium4
        case .AAAB:
            medium4 = random()
            medium5 = medium4
            medium6 = medium4
            medium7 = diffNumber(medium6)
        case .AABB:
            medium4 = random()
            medium5 = medium4
            medium6 = diffNumber(medium5)
            medium7 = medium6
        case .ABAB:
            medium4 = random()
            medium5 = diffNumber(medium4)
            medium6 = medium4
            medium7 = medium5
        case .ABCD:
            medium4 = random()
            if medium4 <= 6 && medium4 >= 3 {
                // 可升可降(几率升各一半)
                if random() >= 5 {
                    medium5 = medium4 + 1
                    medium6 = medium5 + 1
                    medium7 = medium6 + 1
                } else {
                    medium5 = medium4 - 1
                    medium6 = medium5 - 1
                    medium7 = medium6 - 1
                }
            } else if medium4 < 3 {
                // 只能升
                medium5 = medium4 + 1
                medium6 = medium5 + 1
                medium7 = medium6 + 1
            } else if medium4 > 6 {
                // 只能降
                medium5 = medium4 - 1
                medium6 = medium5 - 1
                medium7 = medium6 - 1
            }
        case .BAAA:
            medium4 = random()
            medium5 = diffNumber(medium4)
            medium6 = medium5
            medium7 = medium5
        }

        switch suffix {
        case .AA:
            suffix8 = random()
            suffix9 = random()
            suffix10 = diffNumber(suffix9)
            suffix11 = suffix10
        case .AAA:
            suffix8 = random()
            suffix9 = diffNumber(suffix8)
            suffix10 = suffix9
            suffix11 = suffix9
        case .AAAA:
            suffix8 = random()
            suffix9 = suffix8
            suffix10 = suffix8
            suffix11 = suffix8
        case .AAAAA:
            suffix8 = medium7
            suffix9 = medium7
            suffix10 = medium7
            suffix11 = medium7
        case .AAAAB:
            suffix8 = medium7
            suffix9 = medium7
            suffix10 = medium7
            suffix11 = diffNumber(suffix10)
        case .AAAB:
            suffix8 = random()
            suffix9 = suffix8
            suffix10 = suffix8
            suffix11 = diffNumber(suffix8)
        case .AABB:
            suffix8 = random()
            suffix9 = suffix8
            suffix10 = diffNumber(suffix8)
            suffix11 = suffix10
        case .AABBB:
            suffix8 = medium7
            suffix9 = diffNumber(suffix8)
            suffix10 = suffix9
            suffix11 = suffix9
        case .AABBCC:
            if medium == .AAAA || medium == .AABB || medium == .BAAA {
                suffix8 = random()
                suffix9 = suffix8
                suffix10 = diffNumber(suffix8)
                suffix11 = suffix10
            } else {
                return nil
            }
        case .AABBCCx:
            if medium == .AAAA || medium == .AAAB || medium == .BAAA {
                suffix8 = medium7
                suffix9 = diffNumber(suffix8)
                suffix10 = suffix9
                suffix11 = diffNumber(suffix9)
            } else {
                return nil
            }
        case .ABAB:
            suffix8 = random()
            suffix9 = diffNumber(suffix8)
            suffix10 = suffix8
            suffix11 = suffix9
        case .ABABAB:
            if medium == .AAAB || medium == .ABAB || medium == .ABCD {
                suffix8 = medium6
                suffix9 = medium7
                suffix10 = medium6
                suffix11 = medium7
            } else {
                return nil
            }
        case .ABABABx:
            if medium == .ABAB {
                suffix8 = medium6
                suffix9 = medium7
                suffix10 = medium6
                suffix11 = diffNumber(medium6, medium7)
            } else {
                return nil
            }
        case .ABC:
            suffix9 = random()
            if suffix9 <= 7 && suffix9 >= 2 {
                // 可升可降(几率升各一半)
                if random() >= 5 {
                    suffix10 = suffix9 + 1
                    suffix11 = suffix10 + 1
                } else {
                    suffix10 = suffix9 - 1
                    suffix11 = suffix10 - 1
                }
            } else if suffix9 < 2 {
                // 只能升
                suffix10 = suffix9 + 1
                suffix11 = suffix10 + 1
            } else if suffix9 > 7 {
                // 只能降
                suffix10 = suffix9 - 1
                suffix11 = suffix10 - 1
            }
            suffix8 = diffNumber(suffix9, suffix10, suffix11)
        case .ABCABC:
            if medium == .AAAB || medium == .ABAB {
                suffix9 = medium6
                suffix10 = medium7
                suffix8 = diffNumber(medium6, medium7)
                suffix11 = suffix8
            } else if medium == .ABCD {
                suffix9 = medium4
                suffix10 = medium5
                suffix8 = medium6
                suffix11 = medium6
            } else {
                return nil
            }
        case .ABCABCx:
            if medium == .AAAA {
                suffix8 = medium7
                suffix9 = medium7
                suffix10 = medium7
                suffix11 = diffNumber(medium7)
            } else if medium == .AAAB {
                suffix8 = medium6
                suffix9 = medium6
                suffix10 = medium7
                suffix11 = diffNumber(medium6, medium7)
            } else if medium == .AABB {
                suffix8 = medium5
                suffix9 = medium6
                suffix10 = medium6
                suffix11 = diffNumber(medium5, medium6)
            } else if medium == .ABAB {
                suffix8 = medium7
                suffix9 = medium6
                suffix10 = medium7
                suffix11 = diffNumber(medium6, medium7)
            } else if medium == .ABCD {
                suffix8 = medium5
                suffix9 = medium6
                suffix10 = medium7
                suffix11 = diffNumber(medium5, medium6, medium7)
            } else if medium == .BAAA {
                suffix8 = medium7
                suffix9 = medium7
                suffix10 = medium7
                suffix11 = random()
            }
        case .ABCD:
            suffix8 = random()
            suffix9 = diffNumber(suffix8)
            suffix10 = diffNumber(suffix8, suffix9)
            suffix11 = diffNumber(suffix8, suffix9, suffix10)
        case .ABCDABCD:
            if medium == .ABCD {
                suffix8 = medium4
                suffix9 = medium5
                suffix10 = medium6
                suffix11 = medium7
            } else {
                return nil
            }
        case .ABCxxABC:
            if medium == .ABAB || medium == .ABCD {
                suffix8 = diffNumber(medium4, medium5, medium6)
                suffix9 = medium4
                suffix10 = medium5
                suffix11 = medium6
            } else {
                return nil
            }
        case .xABCxABC:
            if medium == .AAAB || medium == .AABB || medium == .ABAB || medium == .ABCD {
                suffix8 = medium4
                suffix9 = medium5
                suffix10 = medium6
                suffix11 = medium7
            } else {
                return nil
            }
        }

        let phoneNumber = phonePrefix + "\(medium4)\(medium5)\(medium6)\(medium7)\(suffix8)\(suffix9)\(suffix10)\(suffix11)"
        return phoneNumber
    }

}
