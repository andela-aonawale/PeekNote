//
//  ManagedObjectContext.swift
//  PeekNote
//
//  Created by Ahmed Onawale on 5/1/16.
//  Copyright © 2016 Ahmed Onawale. All rights reserved.
//  --------------------------------------------
//
//  Simple extensions to help with managed object context fetch, save and deletion.
//
//  --------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func saveChanges() {
        do {
            try save()
        } catch {
            print("NSManagedObjectContext save error: \(error)")
            rollback()
        }
    }
    
    func fetchEntity(entity: NSManagedObject.Type, matchingPredicate predicate: NSPredicate?, sortBy: [String: Bool]? = nil) -> [NSManagedObject]? {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortBy?.map { NSSortDescriptor(key: $0, ascending: $1)}
        do {
            return try executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch {
            return nil
        }
    }
    
    func deleteAllEntity(entity: NSManagedObject.Type, matchingPredicate predicate: NSPredicate?) {
        let fetchRequest = NSFetchRequest(entityName: entity.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.includesPropertyValues = false
        if #available(iOS 9.0, *) {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try executeRequest(batchDeleteRequest)
                reset()
            } catch {
                print("NSBatchDeleteRequest error: \(error)")
                rollback()
            }
        } else {
            // Fallback on earlier versions
            fetchEntity(entity, matchingPredicate: predicate)?.forEach { deleteObject($0) }
        }
    }
    
}