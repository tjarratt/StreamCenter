import Foundation

protocol AsyncMainQueueRunner {
    func runOnMainQueue(cb: () -> () )
}

struct AsyncMainQueueRunnerImpl : AsyncMainQueueRunner {
    func runOnMainQueue(cb: () -> () ) {
        dispatch_async(dispatch_get_main_queue(),{
            cb()
        })
    }
}