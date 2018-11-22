//
//  DataFetcher.swift
//  Poq.iOS.Platform.Clients
//
//  Created by Nikolay Dzhulay on 11/24/16.
//
//

import Foundation
import Haneke
import PoqModuling
import PoqUtilities

/// Describe API which is required to cache object and get it from cache
/// To put this object to cache, we need make is subclass of NSObject
public protocol DataPresentable: NSObjectProtocol {
    
    /// Instance will be inited not on main thread, so safe to make long running operations
    init(data: Data, url: URL)
    
    /// Memory occupied by objects may vary, so lets make it depended on type of cached object
    static var memoryCacheItemsCountLimit: Int { get }
}

// Have to place 'Caches' ouside beacuse of error 'static stored poperties net yet supported in generic types'
// TODO: right now we don't sync work with caches, so we even can loose some progress. need to fix it

/// Store caches by generic type key(class name)
/// Each cache use Url as key, Data as value
private var Caches = [String: NSCache<AnyObject, AnyObject>]()

private let OperationQueue = Foundation.OperationQueue()

private let UrlSesion = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue)

/// We need separate object too keep info about cacellation of fetching
/// Since we have 3 different layers of data fetching, we can't create only one operation and cancel it
/// Depends on layer, we will or cancel it, or just remember that opearation was cancelled
/// NOTE: since downloading/fetching happens in async way - main thread become point of syncing and checking - cancelled task or not
public class FetchCancelationToken {
    
    /// Can be modified only on main thread
    /// If true - completion won't be called. Default is false 
    public var isCancelled = false
    
    fileprivate var urlSessionTask: URLSessionTask?
}

/// Request data from network, cache it in memeory and on disk
/// For disk cache we will use system cache folder, which cleaned when system need it
/// Order of cache: memory, disk, net
public final class DataFetcher<FetchClass: DataPresentable> {
    
    public typealias DataFetchingCompletion = (_ result: FetchClass?, _ error: Error?) -> Void

    /// Fetch data from cache or from net and return in completion block
    /// - parameter url: source of data
    /// - parameter completion: callback, will be called on main thread
    /// - returns: If we don't have cached object - cancelation token returned
    /// NOTE: should be called from main thread. If we have cashed object: completion will be called immediately.
    public static func fetchData(_ url: URL, completion: @escaping DataFetchingCompletion) -> FetchCancelationToken? {

        
        let key = String(describing: FetchClass.self)

        // step 1: check in-memory cache
        if let cache = Caches[key], let instance = cache.object(forKey: url as AnyObject) as? FetchClass {
            Log.verbose("Return instance without async job")
            completion(instance, nil)
            return nil
        }
        
        let cancellationToken = FetchCancelationToken()
        
        let onDiskCacheCheck = BlockOperation() {
            // step 2: load from local file cache
            DataFetcher.loadFromFileCache(url, cancellationToken: cancellationToken, completion: completion)
        }
        
        OperationQueue.addOperation(onDiskCacheCheck)
        
        return cancellationToken
    }
    
    // MARK: Private 
    
    /// Check local cache storage and load data from it, if such exists
    fileprivate static func loadFromFileCache(_ url: URL, cancellationToken: FetchCancelationToken, completion: @escaping DataFetchingCompletion) {
        guard let cacheFilePath = DataFetcher.cacheFilePath(for: url) else {
            // setp 3: direct download from source
            DataFetcher.downloadDataFromSource(url, cancellationToken: cancellationToken, completion: completion)
            return
        }
        
        let fileCacheCheck = BlockOperation() {
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: cacheFilePath)) else {
                // setp 3: direct download from source
                DataFetcher.downloadDataFromSource(url, cancellationToken: cancellationToken, completion: completion)
                return
            }

            DataFetcher.executeCompletion(completion, cancellationToken: cancellationToken, resultData: data, from: url, error: nil)

        }
        OperationQueue.addOperation(fileCacheCheck)
    }
    
    /// Download data directly from source
    fileprivate static func downloadDataFromSource(_ url: URL, cancellationToken: FetchCancelationToken, completion: @escaping DataFetchingCompletion) {
        
        let task: URLSessionDataTask = UrlSesion.dataTask(with: url, completionHandler: {
            (data: Data?, response: URLResponse?, error: Error?) in

            if let existedData = data {
                saveToDiskCache(existedData, forUrl: url)
            }

            DataFetcher.executeCompletion(completion, cancellationToken: cancellationToken, resultData: data, from: url, error: error)
        })
        
        task.resume()
    }
    
    fileprivate static func saveToMemoryCache(_ fetchedObject: FetchClass, forUrl url: URL) {
        
        let key = String(describing: FetchClass.self)
        let cache: NSCache = Caches[key] ?? NSCache()
        
        cache.countLimit = FetchClass.memoryCacheItemsCountLimit
        cache.setObject(fetchedObject, forKey: url as AnyObject)
        Caches[key] = cache
    }
    
    fileprivate static func saveToDiskCache(_ data: Data, forUrl url: URL) {
        
        guard let filePath = DataFetcher.cacheFilePath(for: url) else {
            return
        }

        let fileCacheSave = BlockOperation() {
            
            let url = URL(fileURLWithPath: filePath)
            
            let directory = url.deletingLastPathComponent()
            
            if !FileManager.default.fileExists(atPath: directory.absoluteString) {
                do {
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    Log.error("Catch exception while creating caching directory")
                }
            }
            
            do {
                try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            } catch {
                Log.error("Catch exception while saving file to cache")
            }
            
        }
        
        OperationQueue.addOperation(fileCacheSave)
    }
    
    /// Create cache file path name based on URL
    fileprivate static func cacheFilePath(for url: URL) -> String? {

        guard let cachesFolerPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return nil
        }
        
        let filename = url.absoluteString.MD5String()
        
        let cacheFilename = cachesFolerPath + "/\(String(describing: FetchClass.self))/\(filename)"
        return cacheFilename
    }
    
    fileprivate static func executeCompletion(_ completion: @escaping DataFetchingCompletion, cancellationToken: FetchCancelationToken, resultData: Data?, from url: URL, error: Error?) {
        
        let instance: FetchClass?
        if let existedData = resultData {
            instance = FetchClass(data: existedData, url: url)
        } else {
            instance = nil
        }

        DispatchQueue.main.async(execute: {
            
            if let instanceUnwraped = instance {
                saveToMemoryCache(instanceUnwraped, forUrl: url)
            }
            
            
            guard !cancellationToken.isCancelled else {
                return
            }

            completion(instance, error)
        })

    }
    
}

