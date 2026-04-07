//
//  SaveService.swift
//  VideoReel
//
//  Created by Amit on 24/01/23.
//

import Foundation
import UIKit
import Photos

extension SaveService {
    
    enum Error: LocalizedError {
        
        case accessDenied
        
        case unknown
    }
}

final class SaveService {
    
    static func getArrayOfAllAssets() -> [PHAssetResource?] {
        
        var arrayOfPHAssetResource: [PHAssetResource?] = []
        
        let fetchOptions = PHFetchOptions()
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //print("collection.count:\(collection.count)")
        let fetchedAssets = PHAsset.fetchAssets(with: nil)//Get all the files in the album
        //print("fetchedAssets.count:\(fetchedAssets.count)")
        let fetchCount = fetchedAssets.count
        for i in 0..<fetchCount {
            let coverAssetAti = fetchedAssets[i]
            var resources: [PHAssetResource]? = nil
            if let lastObject = coverAssetAti as? PHAsset {
                resources = PHAssetResource.assetResources(for: lastObject)
                
//                print("file orgFilename >>", resources)
                
                arrayOfPHAssetResource.append(contentsOf: resources!)
            }
        }
        return arrayOfPHAssetResource
    }
    
    static func saveVideo(_ remoteUrl: URL, itemID : String, completion: @escaping (Error?) -> ()) {
        //print("remote url >>", remoteUrl)
        
        let oldArrayAsset = self.getArrayOfAllAssets()
        //print("oldArrayAsset >> ", oldArrayAsset.count)
        
        let defaultData = UserDefaultManager.sharedInstance.getAlbumData()
        if (defaultData?.count ?? 0 > 0){
            
            for i in 0..<defaultData!.count{
                let dict = defaultData![i]// as? [String:Any]
                for j in 0..<oldArrayAsset.count{
                    let itemIdent = oldArrayAsset[j]?.assetLocalIdentifier

                    if ((itemID == dict["fileID"] as? String) && (dict["identifier"] as? String == itemIdent)){
//                    if ((dict["fileID"] as? String == itemID)){
                        // exist
                        return
                    }else{
                        // not exist
                    }
                }
            }
        }
        
        downloadVideo(with: remoteUrl) { videoUrl in
            guard let videoUrl = videoUrl else {
                return DispatchQueue.main.async {
                    completion(.unknown)
                }
            }
            //print("video url >>", videoUrl)

            writeVideoToLibrary(videoUrl, itemID: itemID) { (error) in
                completion(error)
            }
            
//            writeVideoToLibrary(videoUrl) { error in
//                completion(error)
//            }
        }
    }
        
    private static func writeVideoToLibrary(_ videoUrl: URL, itemID: String, completion: @escaping (Error?) -> ()) {
        PHPhotoLibrary.requestAuthorization { status in
            //print("status  >>", status)
            guard status == .authorized else {
                return DispatchQueue.main.async {
                    completion(.accessDenied)
                }
            }
            
            PHPhotoLibrary.shared().performChanges({
                //print("videoFileUrl creation path url >>", videoUrl.path)

                //print("videoFileUrl creation url >>", videoUrl.absoluteURL)

                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)

//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: videoUrl.path))
            }) { saved, error in
                try? FileManager.default.removeItem(at: videoUrl)
                DispatchQueue.main.async {
                    if saved, error == nil {
                        
                        let newArrayAsset = self.getArrayOfAllAssets()
                        //print("newArrayAsset >> ", newArrayAsset.count)
                        
                        if let test = newArrayAsset.last{
                            var defaultData = UserDefaultManager.sharedInstance.getAlbumData()
                            if defaultData == nil{
                                var tempArray = [[String:Any]]()
                                
                                var tempDict1 = [String:Any]()
                                tempDict1["fileID"] = itemID
                                tempDict1["identifier"] = test?.assetLocalIdentifier
                                tempArray.append(tempDict1)
                                UserDefaultManager.sharedInstance.setAlbumData(albumData: tempArray)
                                
                            }else{
                                var tempDict1 = [String:Any]()
                                tempDict1["fileID"] = itemID
                                tempDict1["identifier"] = test?.assetLocalIdentifier
                                defaultData?.append(tempDict1)
                                UserDefaultManager.sharedInstance.clearUserDefault()
                                UserDefaultManager.sharedInstance.setAlbumData(albumData: defaultData!)
                            }
                        }

                        var tempArray = [[String:Any]]()
                        
                        let defaulttotalData = UserDefaultManager.sharedInstance.getAlbumData()
                        if (newArrayAsset.count > 0){
                            for i in 0..<newArrayAsset.count{
                                let dict = newArrayAsset[i]// as? [String:Any]
                                let assetIdenti = dict?.assetLocalIdentifier ?? ""
                                
                                if defaulttotalData?.count ?? 0 > 0{
                                    for j in 0..<(defaulttotalData?.count ?? 0){
                                        let tempDict = defaulttotalData?[j]
                                        let itemIdentifier = tempDict?["identifier"] as? String
                                        if (itemIdentifier == assetIdenti) {
                                            var tempDict1 = [String:Any]()
                                            tempDict1["fileID"] = tempDict?["fileID"]
                                            tempDict1["identifier"] = tempDict?["identifier"]
                                            tempArray.append(tempDict1)
                                        }else{
                                            // not exist
                                        }
                                    }
                                }
                            }
                            UserDefaultManager.sharedInstance.clearUserDefault()
                            UserDefaultManager.sharedInstance.setAlbumData(albumData: tempArray)
                        }
                        
                        
                        completion(nil)
                    } else {
                        completion(.unknown)
                    }
                }
            }
        }
    }
    
    private static func downloadVideo(with url: URL, completion: @escaping (URL?) -> ()) {
        URLSession.shared.downloadTask(with: url) { url, response, error in
            guard let tempUrl = url, error == nil else {
                return completion(nil)
            }
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let videoFileUrl = documentsUrl.appendingPathComponent("videoTest.mp4")
            if fileManager.fileExists(atPath: videoFileUrl.path) {
                try? fileManager.removeItem(at: videoFileUrl)
            }
            do {
                try fileManager.moveItem(at: tempUrl, to: videoFileUrl)
                print("videoFileUrl url >>", videoFileUrl)

                completion(videoFileUrl)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}




class UserDefaultManager{
    static let sharedInstance = UserDefaultManager()

    let kSaveImageVideoData = "Image_Video_Data"

    //MARK:- used for save and fetch data from album
    //MARK:- set data
    func setAlbumData(albumData: [[String:Any]]){
        UserDefaults.standard.setValue(albumData, forKey: kSaveImageVideoData)
        UserDefaults.standard.synchronize()
    }

     //MARK: - Get Album data
    func getAlbumData() -> [[String:Any]]?{
        if let data = UserDefaults.standard.value(forKey: kSaveImageVideoData) as? [[String:Any]]{
            return data
        }else{
            return nil
        }
    }
    
    //MARK: - Clear All Defaults
    func clearUserDefault(){
        UserDefaults.standard.removeObject(forKey: kSaveImageVideoData)
        UserDefaults.standard.synchronize()
    }    
}
