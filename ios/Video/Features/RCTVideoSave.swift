import AVFoundation

enum RCTVideoSave {
    
    static func saveThumbnails(
        options: NSDictionary!,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock,

        playerItem: AVPlayerItem?
    ) {
        let asset: AVAsset! = playerItem?.asset

        guard asset != nil else {
            reject("ERROR_ASSET_NIL", "Asset is nil", nil)
            return
        }
        
        var imageGenerator = AVAssetImageGenerator(asset: asset)
        
        guard let times = options["times"] as? [Int] else {
            reject("ERROR_ASSET_NIL", "Times are not set", nil)
            return
        }
        
        // TODO: Let user choice an image folder for this video or use random string
        let videoFolder = UUID().uuidString
        
        let imageTimes = times.map { seconds in
            CMTimeMake(value: Int64(seconds), timescale: 1)
        }
        let nsValues = imageTimes.map { NSValue(time: $0) }
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: nsValues) { requestedTime, img, actTime, result, error in
            guard let requestImg = img else {
                return
            }
            
            guard let path = RCTVideoSave.generatePathInDirectory(
                directory: URL(fileURLWithPath: RCTVideoSave.cacheDirectoryPath() ?? "").appendingPathComponent("Thumbnails/\(videoFolder)").path,
                withExtension: ".jpg",
                fName: String(Int(requestedTime.seconds))
            ) else {
                return
            }
            
            let fileURL = URL(fileURLWithPath: path)
            let uiImage = UIImage(cgImage: requestImg)
            if let imageData = uiImage.pngData() {
                    // 3. Speichere die Bilddaten im temporären Pfad
                    do {
                        try imageData.write(to: fileURL)
                        print("Bild erfolgreich gespeichert in: \(fileURL.path)")
                    } catch {
                        print("Fehler beim Speichern des Bildes: \(error)")
                    }
                }
        }
    }
    
    static func save(
        options _: NSDictionary!,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock,

        playerItem: AVPlayerItem?
    ) {
        let asset: AVAsset! = playerItem?.asset

        guard asset != nil else {
            reject("ERROR_ASSET_NIL", "Asset is nil", nil)
            return
        }

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            reject("ERROR_COULD_NOT_CREATE_EXPORT_SESSION", "Could not create export session", nil)
            return
        }
        var path: String!
        path = RCTVideoSave.generatePathInDirectory(
            directory: URL(fileURLWithPath: RCTVideoSave.cacheDirectoryPath() ?? "").appendingPathComponent("Videos").path,
            withExtension: ".mp4"
        )
        let url: NSURL! = NSURL.fileURL(withPath: path) as NSURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.outputURL = url as URL?
        exportSession.videoComposition = playerItem?.videoComposition
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .failed:
                reject("ERROR_COULD_NOT_EXPORT_VIDEO", "Could not export video", exportSession.error)
            case .cancelled:
                reject("ERROR_EXPORT_SESSION_CANCELLED", "Export session was cancelled", exportSession.error)
            default:
                resolve(["uri": url.absoluteString])
            }
        })
    }

    static func generatePathInDirectory(directory: String?, withExtension extension: String?, fName: String? = nil) -> String? {
        let fileName = (fName ?? UUID().uuidString) + (`extension` ?? "")
        RCTVideoSave.ensureDirExists(withPath: directory)
        return URL(fileURLWithPath: directory ?? "").appendingPathComponent(fileName).path
    }

    static func cacheDirectoryPath() -> String? {
        let array = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).map(\.path)
        return array[0]
    }

    static func ensureDirExists(withPath path: String?) -> Bool {
        var isDir: ObjCBool = false
        var error: Error?
        let exists = FileManager.default.fileExists(atPath: path ?? "", isDirectory: &isDir)
        if !(exists && isDir.boolValue) {
            do {
                try FileManager.default.createDirectory(atPath: path ?? "", withIntermediateDirectories: true, attributes: nil)
            } catch {}
            if error != nil {
                return false
            }
        }
        return true
    }
}
