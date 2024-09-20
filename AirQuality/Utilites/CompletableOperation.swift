//
//  CompletableOperation.swift
//  AirQuality
//
//  Created by Tomasz Kukułka on 20/09/2024.
//

import Foundation

class CompletableOperation: Operation {
    
    typealias Completion = () -> ()
    
    // MARK: Properties
    
    override var isAsynchronous: Bool {
        true
    }
    
    // MARK: Properties
    
    private var _isExecuting: Bool = false
    private var _isFinished: Bool = false
    
    override private(set) var isExecuting: Bool {
        get {
            _isExecuting
        } set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override private(set) var isFinished: Bool {
        get {
            _isFinished
        } set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var operationBlock: (@escaping Completion) -> () = { _ in }
    
    init(
        priority: Operation.QueuePriority = .normal,
        operationBlock: @escaping (@escaping Completion) -> ()
    ) {
        super.init()
        
        self.queuePriority = priority
        self.operationBlock = operationBlock
    }
    
    override func start() {
        super.start()
        
        operationBlock({ [weak self] in
            self?.isFinished = true
        })
    }
}
