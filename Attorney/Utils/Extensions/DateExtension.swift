//
//  DateExtension.swift
//  Attorney
//
//  Created by ThinhTCQ on 10/23/22.
//

import UIKit

extension Date {
    func toStringLocalTime(format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        formatter.amSymbol = "a.m"
        formatter.pmSymbol = "p.m"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }

    func toStringUTCTime(format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self)
    }

    func yesterday() -> Date? {
        var dateComponents = DateComponents()
        dateComponents.setValue(-1, for: .day) // -1 day

        let now = Date() // Current date
        let yesterday = Calendar(identifier: .gregorian).date(byAdding: dateComponents, to: now) // Add the DateComponents

        return yesterday
    }

    func toDateLocalTime() -> Date {
        // agnosticdev.com/content/how-convert-swift-dates-timezone
        // 1) Get the current TimeZone's seconds from GMT. Since I am in Chicago this will be: 60*60*5 (18000)
        let timezoneOffset = TimeZone.current.secondsFromGMT()

        // 2) Get the current date (GMT) in seconds since 1970. Epoch datetime.
        let epochDate = self.timeIntervalSince1970
        // 3) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
        //    local date since 1970.
        //    This may look a bit strange, but since timezoneOffset is given as -18000.0, adding epochDate and timezoneOffset
        //    calculates correctly.
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        // 4) Finally, create a date using the seconds offset since 1970 for the local date.
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }

    func getTimeStemp() -> String {
        return "\(self.timeIntervalSince1970)"
    }

    func hasSame(_ components: Calendar.Component..., as date: Date, using calendar: Calendar = .autoupdatingCurrent) -> Bool {
        return components.filter { calendar.component($0, from: date) != calendar.component($0, from: self) }.isEmpty
    }

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        return calendar.dateComponents([component], from: self, to: date).value(for: component)
    }
}
