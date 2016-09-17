//
//  ConcurrencyHelpers.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Foundation

struct ConcurrencyHelpers {
    static func createDispatchTimer(queue: DispatchQueue,
                                    block: @escaping ()->()) -> DispatchSourceTimer {
        let flags = DispatchSource.TimerFlags(rawValue: UInt(0))
        let timer = DispatchSource.makeTimerSource(flags: flags, queue: queue)

        timer.scheduleRepeating(deadline: DispatchTime.now(),
                                interval: .milliseconds(500) as DispatchTimeInterval,
                                leeway: .milliseconds(500) as DispatchTimeInterval)

        timer.setEventHandler { block() }

        timer.resume()
        return timer
    }
}
