//
//  CKHelper.swift
//  Seoul Tourism Uploader
//
//  Created by Aleksander Makedonski on 2/10/18.
//  Copyright © 2018 Aleksander Makedonski. All rights reserved.
//

import Foundation
import CloudKit


class CKHelper{
    
    static let sharedHelper = CKHelper()
    
     let container: CKContainer!
    
    let publicDB: CKDatabase!
    let privateDB: CKDatabase!
    let sharedDB: CKDatabase!
    
    
    
    private init(){
        container = CKContainer(identifier: "iCloud.SeoulTourism")
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
        sharedDB = container.sharedCloudDatabase
    }
}
