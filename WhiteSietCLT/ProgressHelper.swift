//
//  ProgressHelper.swift
//  ProgressHelper
//
//  Created by 朱浩宇 on 2021/8/6.
//

import Foundation

class ProgressHelper {
    static let share = ProgressHelper()
    
    var pool = [UUID]()
    var waitPool = [UUID]()
    
    func creatProgress(_ command: @escaping (UUID) -> ()) -> UUID {
        let id = UUID()
        pool.append(id)
        
        DispatchQueue.global().async { command(id) }
        
        return id
    }
    
    func stopProgress(_ id: UUID) {
        if let index = pool.firstIndex(of: id) { pool.remove(at: index) }
    }
    
    func state(_ id: UUID) -> Bool {
        return self.pool.firstIndex(of: id) != nil
    }
    
    func wait(_ id: UUID) {
        waitPool.append(id)
    }
    
    func stopWait(_ id: UUID) {
        if let index = waitPool.firstIndex(of: id) { waitPool.remove(at: index) }
    }
    
    func join(_ id: UUID, refreshTiem: UInt32 = UInt32(0.1)) {
        while waitPool.firstIndex(of: id) != nil {
            sleep(refreshTiem)
        }
    }
}
