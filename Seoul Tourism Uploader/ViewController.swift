//
//  ViewController.swift
//  Seoul Tourism Uploader
//
//  Created by Aleksander Makedonski on 2/10/18.
//  Copyright © 2018 Aleksander Makedonski. All rights reserved.
//

import UIKit
import CloudKit

class FoodImageController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var flickrImages = [FlickrImage]()
    var fetchedRecords = [FlickrImage]()
    var completedRecords: NSMutableSet!
    var chosenFood: String!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        

        self.fetchFlickrImages(withSearchTerm: self.chosenFood)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = false
        collectionView.isHidden = true
        activityIndicator.startAnimating()

        
        // Do any additional setup after loading the view, typically from a nib.
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchFlickrImages(withSearchTerm searchTerm: String){
        
        let predicate = NSPredicate(format: "searchTerm == %@", self.chosenFood)
        
        fetchFlickrImages(withPredicate: predicate)
    }
    
    func fetchAllFlickrImages(){
        
        let predicate = NSPredicate(value: true)
        fetchFlickrImages(withPredicate: predicate)
    }
    
    private func fetchFlickrImages(withPredicate predicate: NSPredicate){
        
        let query = CKQuery(recordType: RemoteRecords.FlickrImage, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = 5
        
        queryOperation.recordFetchedBlock = {
            record in
            
            if let flickrImage = FlickrImage(withCKRecord: record){
                self.fetchedRecords.append(flickrImage)
            }
            
            DispatchQueue.main.async {
                if self.view != nil{
                    
                 
                
                    if(self.collectionView.isHidden){
                        self.collectionView.isHidden = false
                        
                    }
                    
                    
                    if(!self.activityIndicator.isHidden){
                        self.activityIndicator.isHidden = true
                        
                    }
                    
                    if(self.activityIndicator.isAnimating){
                        self.activityIndicator.stopAnimating()
                    }
 
     
                    self.collectionView.reloadData()

                } else {
                    //TODO: error handling - the pictures loaded faster than the view itself
                }
            }
        }
        
        
        queryOperation.queryCompletionBlock = {
            
            cursor, error in
            
            if(error != nil){
                print(error!.localizedDescription)
            } else{
                if(cursor != nil){
                    print("Total records: \(self.fetchedRecords.count)")
                    self.queryServer(cursor!)
                }
            }
        }
        
        CKHelper.sharedHelper.publicDB.add(queryOperation)
       
    }
    
    
  
    
    func queryServer(_ queryCursor: CKQueryCursor){
        
        let queryOperation = CKQueryOperation(cursor: queryCursor)
        queryOperation.resultsLimit = 5
        
        queryOperation.recordFetchedBlock = {
            record in
            
            if let flickrImage = FlickrImage(withCKRecord: record){
                self.fetchedRecords.append(flickrImage)

            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        
        queryOperation.queryCompletionBlock = {
            
            cursor, error in
            
            if(error != nil){
                print(error!.localizedDescription)
            } else{
                if(cursor != nil){
                    print("Total records: \(self.fetchedRecords.count)")
                    self.queryServer(cursor!)
                }
            }
        }
        
        CKHelper.sharedHelper.publicDB.add(queryOperation)

    }
  
    func importFlickrImageData(){
        
        guard let plistUrl = Bundle.main.url(forResource: "FlickrFoods", withExtension: "plist"), let foodDicts = NSArray(contentsOf: plistUrl) else {
            return
        }
        
        for foodDict in foodDicts{
            
            guard let userInfo = foodDict as? Dictionary<String,Any> else {
                continue
            }
            
            guard let imageName = userInfo["imageName"] as? String, let imageExtension = userInfo["imageExtension"] as? String else {
                continue
            }
            
            guard let licenseURL = userInfo["licenseURL"] as? String, let licenseInfo = userInfo["licenseInfo"] as? String else {
                continue
            }
            
            guard let flickrURL = userInfo["flickrURL"] as? String, let flickrAuthorURL = userInfo["flickrAuthorURL"] as? String,let flickrAuthor = userInfo["flickrAuthor"] as? String else {
                continue
            }
            
            guard let disclaimerNotice = userInfo["disclaimerNotice"] as? String, let copyrightNotice = userInfo["copyrightNotice"] as? String else {
                continue
            }
            
            guard let searchTerm = userInfo["searchTerm"] as? String else {
                continue
            }
            
            let record = CKRecord(recordType: RemoteRecords.FlickrImage)
            
            
            record[RemoteFlickrField.LicenseInfo] = licenseInfo as NSString

            record[RemoteFlickrField.LicenseURL] = licenseURL as NSString

            record[RemoteFlickrField.SearchTerm] = searchTerm as NSString

            record[RemoteFlickrField.CopyrightNotice] = copyrightNotice as NSString
            record[RemoteFlickrField.DisclaimerNotice] = disclaimerNotice as NSString
            record[RemoteFlickrField.FlickrAuthor] = flickrAuthor as NSString
            record[RemoteFlickrField.FlickrURL] = flickrURL as NSString
            record[RemoteFlickrField.FlickrAuthorURL] = flickrAuthorURL as NSString
            record[RemoteFlickrField.FlickrAuthor] = flickrAuthor as NSString
            
            if let imageURL = Bundle.main.url(forResource: imageName, withExtension: imageExtension){
                let ckAsset = CKAsset(fileURL: imageURL)
                record[RemoteFlickrField.FlickrImage] = ckAsset
            }
            
            CKHelper.sharedHelper.publicDB.save(record){
                record, error in
                
                if(error != nil){
                    print(error!.localizedDescription)
                } else {
                    print("records imported")

                }
            }
        }
    }
    
    
    func saveFlickrImageRecords(){
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Emily", flickrAuthorURL: "https://www.flickr.com/photos/ebarney/", flickrURL: "https://www.flickr.com/photos/ebarney/5502492455/in/photolist-9oeHiz-9DSzcC-9uLVuA-9oeGxH-a2YATd-9ohCtu-9F6JKq-9ohzz5-652Nav-9F6JC9-6i5BeD-9YRBwQ-nQKthQ-dmoFmA-9jvKYz-5cjyzG-rFZYj5-EkzxaB-eU7tCq-9F6JoG-DJLEaK-6i5B7n-9F6K6E-f88dvR-6m2BCX-6m2Xsv-6m2XZg-6m6FN9-6m6Eny-6m6F7b-6m6DFs-6m7ad1-6m2AQ2-6m2Yyc-9ohD3C-6m2A3g-p7Ptfb-5kxJHE-6JGi4H-LpjLz6-9F6JV7-4EJ1sz-CXQ4A-6qvjQp-jsRzpv-9fgNLJ-oPQpD5-9Zcc7Y-6cGZ5f-9ohJZb", licenseInfo: "CC BY-NC 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc/2.0/", searchTerm: "deonjang", imageName: "doenjang1", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "jamiefrater", flickrAuthorURL: "https://www.flickr.com/photos/jfrater/", flickrURL: "https://www.flickr.com/photos/jfrater/5679431782/in/photolist-9DSzcC-9uLVuA-9oeGxH-a2YATd-9ohCtu-9F6JKq-9ohzz5-652Nav-9F6JC9-6i5BeD-9YRBwQ-nQKthQ-dmoFmA-9jvKYz-5cjyzG-rFZYj5-EkzxaB-eU7tCq-9F6JoG-DJLEaK-6i5B7n-9F6K6E-f88dvR-6m2BCX-6m2Xsv-6m2XZg-6m6FN9-6m6Eny-6m6F7b-6m6DFs-6m7ad1-6m2AQ2-6m2Yyc-9ohD3C-6m2A3g-p7Ptfb-5kxJHE-6JGi4H-LpjLz6-9F6JV7-4EJ1sz-CXQ4A-6qvjQp-jsRzpv-9fgNLJ-oPQpD5-9Zcc7Y-6cGZ5f-9ohJZb-9F6Jwu", licenseInfo: "CC BY-NC-ND 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc-nd/2.0/", searchTerm: "doenjang", imageName: "doenjang2", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Min Lee", flickrAuthorURL: "https://www.flickr.com/photos/mlee/", flickrURL: "https://www.flickr.com/photos/mlee/2401924877/in/photolist-4EfuzT-9oeHiz-9DSzcC-9uLVuA-9oeGxH-a2YATd-9ohCtu-9F6JKq-9ohzz5-652Nav-9F6JC9-6i5BeD-9YRBwQ-nQKthQ-dmoFmA-9jvKYz-5cjyzG-rFZYj5-EkzxaB-eU7tCq-9F6JoG-DJLEaK-6i5B7n-9F6K6E-f88dvR-6m2BCX-6m2Xsv-6m2XZg-6m6FN9-6m6Eny-6m6F7b-6m6DFs-6m7ad1-6m2AQ2-6m2Yyc-9ohD3C-6m2A3g-p7Ptfb-5kxJHE-6JGi4H-LpjLz6-9F6JV7-4EJ1sz-CXQ4A-6qvjQp-jsRzpv-9fgNLJ-oPQpD5-9Zcc7Y-6cGZ5f", licenseInfo: "CC BY-NC 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc-nd/2.0/", searchTerm: "doenjang", imageName: "doenjang3", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "James", flickrAuthorURL: "https://www.flickr.com/photos/40726522@N02/", flickrURL: "https://www.flickr.com/photos/40726522@N02/5894257936/in/photolist-9YRBwQ-nQKthQ-dmoFmA-9jvKYz-5cjyzG-rFZYj5-EkzxaB-eU7tCq-9F6JoG-DJLEaK-6i5B7n-9F6K6E-f88dvR-6m2BCX-6m2Xsv-6m2XZg-6m6FN9-6m6Eny-6m6F7b-6m6DFs-6m7ad1-6m2AQ2-6m2Yyc-9ohD3C-6m2A3g-p7Ptfb-5kxJHE-6JGi4H-LpjLz6-9F6JV7-4EJ1sz-CXQ4A-6qvjQp-jsRzpv-9fgNLJ-oPQpD5-9Zcc7Y-6cGZ5f-9ohJZb-9F6Jwu-9fgNPU-9fdEFB-iFqPN2-9fdERV-7sgo6H-7eKqC4-9fgNBj-7aMJXL-9ohQdN-6F7box", licenseInfo: "CC BY-NC-ND 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc-nd/2.0/", searchTerm: "doenjang", imageName: "doenjang4", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Republic of Korea", flickrAuthorURL: "https://www.flickr.com/photos/koreanet/", flickrURL: "https://www.flickr.com/photos/koreanet/7594461604/in/photolist-cz6ARb-Eck8NZ-7ycL6Z-aU4Ld4-YEJi76-aTcwsR-8Mygkq-bhWjsM-7qZLSy-5Lo5YX-5Lsk2Q-pZCXxA-fvUEu8-7qVRN4-56dR4b-9g8qbX-4n9rWT-9LtA45-i2beJN-7Fxohc-7XbMT9-56dSNm-4ceBRQ-fhv93z-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh", licenseInfo: "CC BY-SA 2.0", licenseURL: "https://creativecommons.org/licenses/by-sa/2.0/", searchTerm: "samgyetang", imageName: "samgyetang1", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "T.Tseng", flickrAuthorURL: "https://www.flickr.com/photos/68147320@N02/", flickrURL: "https://www.flickr.com/photos/68147320@N02/25069772041/in/photolist-Eck8NZ-7ycL6Z-aU4Ld4-YEJi76-aTcwsR-8Mygkq-bhWjsM-7qZLSy-5Lo5YX-5Lsk2Q-pZCXxA-fvUEu8-7qVRN4-56dR4b-9g8qbX-4n9rWT-9LtA45-i2beJN-7Fxohc-7XbMT9-56dSNm-4ceBRQ-fhv93z-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh-9KLnVh", licenseInfo: "CC BY 2.0", licenseURL: "https://creativecommons.org/licenses/by/2.0/", searchTerm: "samgyetang", imageName: "samgyetang2", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "jamiefrater", flickrAuthorURL: "https://www.flickr.com/photos/jfrater/", flickrURL: "https://www.flickr.com/photos/jfrater/5422048739/in/photolist-9g8qbX-4n9rWT-9LtA45-i2beJN-7Fxohc-7XbMT9-56dSNm-4ceBRQ-fhv93z-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh-9KLnVh-KLPm9q-JgwsdE-uKN5Rm-5UnV8E-5ADe9v-gEizv9-usPjR-q4ATCX-fsU2Ej-3qQDnX-Q3Xko-6XL9Wy-6YjyqM-6BvUjT", licenseInfo: "CC BY-NC-ND BY 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc-nd/2.0/", searchTerm: "samgyetang", imageName: "samgyetang3", imageExtension: "jpg"))
        
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Ilho Song", flickrAuthorURL: "https://www.flickr.com/photos/terasia/", flickrURL: "https://www.flickr.com/photos/terasia/4220244955/in/photolist-7qVRN4-56dR4b-9g8qbX-4n9rWT-9LtA45-i2beJN-7Fxohc-7XbMT9-56dSNm-4ceBRQ-fhv93z-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh-9KLnVh-KLPm9q-JgwsdE-uKN5Rm-5UnV8E-5ADe9v-gEizv9-usPjR-q4ATCX-fsU2Ej-3qQDnX-Q3Xko-6XL9Wy", licenseInfo: "CC BY-NC-ND BY 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc-nd/2.0/", searchTerm: "samgyetang", imageName: "samgyetang4", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Cecil Lee", flickrAuthorURL: "https://www.flickr.com/photos/27954114@N05/", flickrURL: "https://www.flickr.com/photos/27954114@N05/9527448423/in/photolist-fvUEu8-7qVRN4-56dR4b-9g8qbX-4n9rWT-9LtA45-i2beJN-7Fxohc-7XbMT9-56dSNm-4ceBRQ-fhv93z-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh-9KLnVh-KLPm9q-JgwsdE-uKN5Rm-5UnV8E-5ADe9v-gEizv9-usPjR-q4ATCX-fsU2Ej-3qQDnX-Q3Xko", licenseInfo: "CC BY-NC-ND BY 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc-nd/2.0/", searchTerm: "samgyetang", imageName: "samgyetang5", imageExtension: "jpg"))
        
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Katatonic28", flickrAuthorURL: "https://www.flickr.com/photos/midwestkimchee/", flickrURL: "https://www.flickr.com/photos/midwestkimchee/2684515916/in/photolist-56dR4b-9g8qbX-4n9rWT-9LtA45-i2beJN-7Fxohc-7XbMT9-56dSNm-4ceBRQ-fhv93z-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh-9KLnVh-KLPm9q-JgwsdE-uKN5Rm-5UnV8E-5ADe9v-gEizv9-usPjR-q4ATCX-fsU2Ej-3qQDnX-Q3Xko-6XL9Wy-6YjyqM", licenseInfo: "CC BY-NC-ND BY 2.0", licenseURL: "https://creativecommons.org/licenses/by-nc-nd/2.0/", searchTerm: "samgyetang", imageName: "samgyetang6", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Republic of Korea", flickrAuthorURL: "https://www.flickr.com/photos/koreanet/", flickrURL: "https://www.flickr.com/photos/koreanet/4385607371/in/photolist-7Fxohc-7XbMT9-56dSNm-4ceBRQ-fhv93z-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh-9KLnVh-KLPm9q-JgwsdE-uKN5Rm-5UnV8E-5ADe9v-gEizv9-usPjR-q4ATCX-fsU2Ej-3qQDnX-Q3Xko-6XL9Wy-6YjyqM-6BvUjT-2hzcc2-abDoVB-5N7Hbe-L3P7sd", licenseInfo: "CC BY-SA BY 2.0", licenseURL: "https://creativecommons.org/licenses/by-sa/2.0/", searchTerm: "samgyetang", imageName: "samgyetang7", imageExtension: "jpg"))
        
        flickrImages.append(FlickrImage(copyrightNotice: "", disclaimerNotice: "", flickrAuthor: "Marvin Lee", flickrAuthorURL: "https://www.flickr.com/photos/marvin_lee/", flickrURL: "https://www.flickr.com/photos/marvin_lee/3218163962/in/photolist-5UnW2y-64cDs4-nzP3cU-4caCua-7kcWN2-dxFMPL-dxAh9F-7kcWG2-7kcWBV-bVdTSG-cDBzjG-4caBZK-7kgQXq-5GKm4o-7kgR4h-pMeTC6-8Mvc5c-F1MwZj-7kcWu8-dL95yR-dLezBE-4CrMzF-8MvbZc-u7aUKF-umhWjw-fsU2Sh-9KLnVh-KLPm9q-JgwsdE-uKN5Rm-5UnV8E-5ADe9v-gEizv9-usPjR-q4ATCX-fsU2Ej-3qQDnX-Q3Xko-6XL9Wy-6YjyqM-6BvUjT-2hzcc2-abDoVB-5N7Hbe-L3P7sd-KgiDb9-KLPu8G-bhWjg8-9vv8wg-8X9Arg", licenseInfo: "CC BY 2.0", licenseURL: "https://creativecommons.org/licenses/by/2.0/", searchTerm: "samyetang", imageName: "samyetang8", imageExtension: "jpg"))
        
        
        completedRecords = NSMutableSet()
        
        let ckRecords: [CKRecord] = flickrImages.map({ $0.getCKRecord() })
        
        let saveOperation = CKModifyRecordsOperation(recordsToSave: ckRecords, recordIDsToDelete: nil)
        
        saveOperation.perRecordCompletionBlock = {
            record, error in
            
            if(error != nil){
                print(error!.localizedDescription)
            } else {
                
            }
        }
        
        let totalImages = Double(self.flickrImages.count)
        
        saveOperation.perRecordProgressBlock = {
            record, progress in
            
            if(progress >= 1){
                self.completedRecords.add(record)
                let totalSavedRecords = Double(self.completedRecords.count)
                let totalProgress = totalSavedRecords/totalImages
                print("Total progress: \(totalProgress)")
                
            }
        }
        
        saveOperation.completionBlock = {
            print("Operation complete")
        }
        
        CKHelper.sharedHelper.publicDB.add(saveOperation)
    }


}

extension FoodImageController: UICollectionViewDataSource{
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrImageCell", for: indexPath) as! FlickrImageCell
        
    
        let flickrImage = self.fetchedRecords[indexPath.row]
        
        if let image = flickrImage.fetchedImage{
            
            cell.flickrImageView.image = image

        }

        
        
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.fetchedRecords.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension FoodImageController: UICollectionViewDelegate{
    
    
}

