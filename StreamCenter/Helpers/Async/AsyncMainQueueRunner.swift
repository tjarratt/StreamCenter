import Foundation

protocol AsyncMainQueueRunner {
    func runOnMainQueue(_ cb: @escaping () -> () )
}

struct AsyncMainQueueRunnerImpl : AsyncMainQueueRunner {
    func runOnMainQueue(_ cb: @escaping () -> () ) {
        DispatchQueue.main.async(execute: {
            cb()
        })
    }
}
