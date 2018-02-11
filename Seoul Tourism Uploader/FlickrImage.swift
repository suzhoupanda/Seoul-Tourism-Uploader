//
//  FlickrImage.swift
//  Seoul Tourism Uploader
//
//  Created by Aleksander Makedonski on 2/10/18.
//  Copyright © 2018 Aleksander Makedonski. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

struct FlickrImage{
    
    var copyrightNotice: String
    var disclaimerNotice: String
    var flickrAuthor: String
    var flickrAuthorURL: String
    var flickrURL: String
    var licenseInfo: String
    var licenseURL: String
    var searchTerm: String
    
    var imageName: String
    var imageExtension: String
    
    var fetchedImage: UIImage?
    
    init(copyrightNotice: String, disclaimerNotice: String, flickrAuthor: String, flickrAuthorURL: String, flickrURL: String, licenseInfo: String, licenseURL: String, searchTerm: String, imageName: String, imageExtension: String){
        
        self.copyrightNotice = copyrightNotice
        self.disclaimerNotice = disclaimerNotice
        
        self.flickrAuthor = flickrAuthor
        self.flickrAuthorURL = flickrAuthorURL
        self.flickrURL = flickrURL
        
        self.licenseURL = licenseURL
        self.licenseInfo = licenseInfo
        
        self.searchTerm = searchTerm
        
        self.imageName = imageName
        self.imageExtension = imageExtension
    }
    
    init?(withCKRecord record: CKRecord) {
        
        
        guard let licenseInfo = record[RemoteFlickrField.LicenseInfo] as? String, let licenseURL = record[RemoteFlickrField.LicenseURL] as? String else { return nil }
        
        
        self.licenseInfo = licenseInfo
        self.licenseURL = licenseURL
        
        guard let searchTerm = record[RemoteFlickrField.SearchTerm] as? String else { return nil }
        
        self.searchTerm = searchTerm
        
        guard let copyrightNotice = record[RemoteFlickrField.CopyrightNotice] as? String, let disclaimerNotice =       record[RemoteFlickrField.DisclaimerNotice] as? String else { return nil }
        
        self.copyrightNotice = copyrightNotice
        self.disclaimerNotice = disclaimerNotice
        
        guard let flickrAuthor = record[RemoteFlickrField.FlickrAuthor] as? String, let flickrURL = record[RemoteFlickrField.FlickrURL] as? String, let flickrAuthorURL = record[RemoteFlickrField.FlickrAuthorURL] as? String else {
            return nil
        }
        
        self.flickrURL = flickrURL
        self.flickrAuthorURL = flickrAuthorURL
        self.flickrAuthor = flickrAuthor
        
      
        if let asset = record[RemoteFlickrField.FlickrImage] as? CKAsset{
            
            let fileURL = asset.fileURL
            
            let imageData = NSData(contentsOf: fileURL)
            
            if let image = UIImage(data: imageData as! Data){
                self.fetchedImage = image
            }
        
        }
        
        self.imageName = String()
        self.imageExtension = String()
    }
    
    func getCKRecord() -> CKRecord{
        
        let record = CKRecord(recordType: RemoteRecords.FlickrImage)
        
        
        record[RemoteFlickrField.LicenseInfo] = self.licenseInfo as NSString
        
        record[RemoteFlickrField.LicenseURL] = self.licenseURL as NSString
        
        record[RemoteFlickrField.SearchTerm] = self.searchTerm as NSString
        
        record[RemoteFlickrField.CopyrightNotice] = self.copyrightNotice as NSString
        record[RemoteFlickrField.DisclaimerNotice] = self.disclaimerNotice as NSString
        record[RemoteFlickrField.FlickrAuthor] = self.flickrAuthor as NSString
        record[RemoteFlickrField.FlickrURL] = self.flickrURL as NSString
        record[RemoteFlickrField.FlickrAuthorURL] = self.flickrAuthorURL as NSString
        record[RemoteFlickrField.FlickrAuthor] = self.flickrAuthor as NSString
        
        if let imageURL = Bundle.main.url(forResource: self.imageName, withExtension: self.imageExtension){
            let ckAsset = CKAsset(fileURL: imageURL)
            record[RemoteFlickrField.FlickrImage] = ckAsset
        }
        
        return record
    }
    
}
