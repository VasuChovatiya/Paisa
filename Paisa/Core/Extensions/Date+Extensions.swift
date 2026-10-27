//
//  Date+Extensions.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import Foundation

// MARK: - Date + Calendar Helpers

extension Date {
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }

    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth) ?? self
    }

    func addingMonths(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: n, to: self) ?? self
    }

    var monthYearString: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: self)
    }

    var shortDayString: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: self)
    }

    var transactionDisplayString: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) { return "Today" }
        if cal.isDateInYesterday(self) { return "Yesterday" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: self)
    }
}
