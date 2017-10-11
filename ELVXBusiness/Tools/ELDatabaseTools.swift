    //
//  ELDatabaseTools.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/25.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation
import FMDB
import FileKit

class ELDatabaseTools {

    static let shared = ELDatabaseTools()

    private init() {
        prepare()
    }

    fileprivate let path = Path.userDocuments + kDatabaseName
    fileprivate lazy var createPhonesTableSQL: String = {
        return "create table if not exists \(kPhonesTableName)("
            + "id INTEGER PRIMARY KEY autoincrement, "
            + "\(kPhonesTableColumnMobile) TEXT NOT NULL, "
            + "\(kPhonesTableColumnIsp) TEXT, "
            + "\(kPhonesTableColumnProvince) TEXT, "
            + "\(kPhonesTableColumnCity) TEXT, "
            + "\(kPhonesTableColumnAreaCode) INTEGER, "
            + "\(kPhonesTableColumnZipCode) INTEGER, "
            + "\(kPhonesTableColumnStandard) INTEGER, "
            + "\(kCommonTableColumnCreateDate) INTEGER);"
    }()

    fileprivate var _database: FMDatabaseQueue?
    fileprivate var _isOpened = false

    deinit {
        _database?.close()
    }

    func prepare() {
        openIfNeeded()
        _database?.inDatabase({ (db) in
            db.executeStatements(createPhonesTableSQL)
        })
    }

    func close() {
        if _database != nil {
            _database?.close()
            _database = nil
        }
        _isOpened = false
    }

    fileprivate func open() {
        close()

        let pathRaw = path.rawValue
        let db = FMDatabaseQueue(path: pathRaw)
        _isOpened = true
        _database = db

        print("database file path is \(pathRaw)")
    }

    fileprivate func openIfNeeded() {
        guard !_isOpened else { return }
        open()
    }

    func insert(to phone: ELPhone, _ createDate: Date = Date()) {
        openIfNeeded()

        let mobile = phone.mobile
        let isp = phone.isp.rawValue
        let province = phone.province
        let city = phone.city
        let areaCode = phone.areaCode
        let zipCode = phone.zipCode
        let standard = phone.standard.hashValue

        let columns = [
            kPhonesTableColumnMobile,
            kPhonesTableColumnIsp,
            kPhonesTableColumnProvince,
            kPhonesTableColumnCity,
            kPhonesTableColumnAreaCode,
            kPhonesTableColumnZipCode,
            kPhonesTableColumnStandard,
            kCommonTableColumnCreateDate
        ].joined(separator: ", ")

        let updateSQL = "INSERT INTO \(kPhonesTableName) (\(columns)) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        _database?.inDatabase({ (db) in
            do {
                let result = try db.executeQuery("select \(kPhonesTableColumnMobile) from \(kPhonesTableName) where \(kPhonesTableColumnMobile) = ?;", values: [mobile])

                defer {
                    print("insert >> query result close execute.")
                    result.close()
                }

                if result.next() {
                    print("database `table has contained this record. \(mobile)")
                } else {
                    try db.executeUpdate(updateSQL, values: [mobile, isp, province, city, areaCode, zipCode, standard, createDate.timeIntervalSince1970])
                }
            } catch {
                print("insert error: \(error)")
            }
        })
    }

    func exists(with phoneNumber: String) -> Bool {
        return query(with: phoneNumber) != nil
    }

    func query(with phoneNumber: String) -> ELPhone? {
        openIfNeeded()

        var result: FMResultSet?
        var phone: ELPhone?

        _database?.inDatabase {
            do {
                result = try $0.executeQuery("select \(kPhonesTableColumnMobile) from \(kPhonesTableName) where \(kPhonesTableColumnMobile) = ?;", values: [phoneNumber])

                defer {
                    print("query >> query result close execute.")
                    result?.close()
                }

                if let _result = result, _result.next() {
                    phone = ELPhone(_result)
                }

            } catch {
                print("query with phoneNumber: \(phoneNumber) error: \(error)")
            }
        }

        return phone
    }

    func count() -> Int {
        openIfNeeded()

        var _count: Int = 0
        _database?.inDatabase {
            do {
                let result = try $0.executeQuery("select count(*) from \(kPhonesTableName);", values: nil)

                defer {
                    print("count >> query result close execute.")
                    result.close()
                }

                if result.next() {
                    _count = Int(result.int(forColumnIndex: 0))
                }
            } catch {
                print("count error: \(error)")
            }
        }
        return _count
    }

    // 按时间分组查询
    func queryGroupByCreateTime() -> [Date] {
        openIfNeeded()

        var dates = [Date]()

        _database?.inDatabase {
            do {
                let result = try $0.executeQuery("select \(kCommonTableColumnCreateDate) from \(kPhonesTableName) group by \(kCommonTableColumnCreateDate) order by \(kCommonTableColumnCreateDate) desc;", values: nil)

                defer {
                    print("queryGroupByCreateTime >> query result close execute.")
                    result.close()
                }

                while result.next() {
                    let timeInterval = result.double(forColumnIndex: 0)
                    let date = Date(timeIntervalSince1970: timeInterval)
                    dates.append(date)
                }

            } catch {
                print("queryGroupByCreateTime error: \(error)")
            }
        }

        return dates
    }

    func query(with date: Date) -> [ELPhone] {
        openIfNeeded()

        var result: FMResultSet?
        var phones = [ELPhone]()

        _database?.inDatabase {

            do {
                let timeInterval = date.timeIntervalSince1970
                let querySQL = "select * from \(kPhonesTableName) where \(kCommonTableColumnCreateDate) = ?;"
                result = try $0.executeQuery(querySQL, values: [timeInterval])

                defer {
                    print("query with date >> query result close execute.")
                    result?.close()
                }

                while let _result = result, _result.next() {
                    let phone = ELPhone(_result)
                    phones.append(phone)
                }

            } catch {
                print("query with date: \(date) error: \(error)")
            }

        }

        return phones
    }

    // 【注意】extraStatement: 只能是分组或者排序语句
    func query(with date: Date, _ after: Bool = false, _ containQueryDate: Bool = true, _ endDate: Date? = nil, extraStatement: String? = nil) -> [ELPhone] {
        openIfNeeded()

        var result: FMResultSet?
        var phones = [ELPhone]()

        _database?.inDatabase {

            do {
                let timeInterval = date.timeIntervalSince1970
                var values = [timeInterval]

                var extraConditionStatement: String?
                let compareSignal: String = {
                    switch (after, containQueryDate) {
                    case (true, true):
                        if let _endDate = endDate {
                            extraConditionStatement = "and \(kCommonTableColumnCreateDate) <= ?"
                            values.append(_endDate.timeIntervalSince1970)
                        }
                        return ">="

                    case (true, false):
                        if let _endDate = endDate {
                            extraConditionStatement = "and \(kCommonTableColumnCreateDate) < ?"
                            values.append(_endDate.timeIntervalSince1970)
                        }
                         return ">"

                    case (false, true):
                        if let _endDate = endDate {
                            extraConditionStatement = "and \(kCommonTableColumnCreateDate) >= ?"
                            values.append(_endDate.timeIntervalSince1970)
                        }
                        return "<="

                    case (false, false):
                        if let _endDate = endDate {
                            extraConditionStatement = "and \(kCommonTableColumnCreateDate) > ?"
                            values.append(_endDate.timeIntervalSince1970)
                        }
                        return "<"
                    }
                }()

                let querySQL = "select * from \(kPhonesTableName) where \(kCommonTableColumnCreateDate) \(compareSignal) ? \(extraConditionStatement ?? "") \(extraStatement ?? "");"
                result = try $0.executeQuery(querySQL, values: values)

                defer {
                    print("query with date >> query result close execute.")
                    result?.close()
                }

                while let _result = result, _result.next() {
                    let phone = ELPhone(_result)
                    phones.append(phone)
                }

            } catch {
                print("query with date: \(date) error: \(error)")
            }

        }

        return phones
    }

}
