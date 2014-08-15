//
//  WPJSONParser.swift
//  WPJSONParser-Example
//
//  Created by Vavelin Kevin on 08/08/14.
//  Copyright (c) 2014 Vavelin Kevin. All rights reserved.
//

import UIKit

class WPJSONParser: NSObject {
    
    //MARK: Variables
    private var page : Int
    private var categoryPage: Int
    private var urlSite : String
    var categoryDic : NSDictionary?
    
    //MARK: Function
    
    //Init required because of singleton
    required init(url:NSString) {
        urlSite = url
        page = 1
        categoryPage = 1
        super.init()
    }
    
    //Singleton pattern
    class func sharedInstance(url:NSString)->WPJSONParser {
        struct Static {
            static var instance : WPJSONParser? = nil
            static var onceToken : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = self(url: url)
        }
        return Static.instance!
    }
    
    func getRecentPost(recentPost:(post:[AnyObject])->()) {
        var url : NSURL = NSURL(string: "http://\(urlSite)/api/get_recent_posts/?count=20")
        var data : NSData = NSData(contentsOfURL: url)
        if data != nil {
            var responseJson: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if responseJson != nil {
                var response : [AnyObject] = responseJson.objectForKey("posts") as [AnyObject]
                recentPost(post:response)
            }
        }
    }
    
    func getCategory(category:(response:NSDictionary)->()) {
        var url : NSURL = NSURL(string: "http://\(urlSite)/api/get_category_index")
        var data : NSData = NSData(contentsOfURL: url)
        if data != nil {
            var responseJson : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if responseJson != nil {
                var categoryInfos = responseJson.objectForKey("categories") as NSArray
                var categoryName = NSMutableArray()
                var categoryId = NSMutableArray()
                for var i = 0; i < categoryInfos.count; i++ {
                    var titleDictionary = categoryInfos.objectAtIndex(i) as NSDictionary
                    var idCategory = categoryInfos.objectAtIndex(i) as NSDictionary
                    var categoryIdString = idCategory.objectForKey("id") as NSString
                    var changeEncoding = titleDictionary.objectForKey("title").dataUsingEncoding(NSUTF8StringEncoding)
                    var titleCategoryString = NSString(data: changeEncoding, encoding: NSUTF8StringEncoding)
                    var finalString = titleCategoryString.stringByReplacingOccurrencesOfString("é", withString: "é")
                    categoryName.addObject(finalString)
                    categoryId.addObject(categoryIdString)
                }
                category(response:NSDictionary(objects: categoryId, forKeys: categoryName))
                categoryDic = NSDictionary(objects: categoryId, forKeys: categoryName)
            }
            
        }
    }
    
    func search(text:String, searchResult:(result:NSArray)->()) {
        var url : NSURL = NSURL(string: "http://\(urlSite)/api/get_recent_posts/?count=20")
        var data : NSData = NSData(contentsOfURL: url)
        if data != nil {
            var jsonData : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if jsonData != nil {
                searchResult(result:jsonData.objectForKey("posts") as NSArray)
            }
        }
    }
    
    func getPostOfCategory(categoryId:String, post:(post:NSArray)->()) {
        var url : NSURL = NSURL(string: "http://\(urlSite)/api/get_category/posts/?id=\(categoryId)")
        var data = NSData(contentsOfURL: url)
        if data != nil {
            var jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
            if jsonData != nil {
                post(post:jsonData.objectForKey("posts") as NSArray)
            }
        }
    }
    
    func getPostWithId(postsId:NSArray, postFromId:(post:NSArray)->()) {
        var posts = NSMutableArray()
        for var i = 0; i < postsId.count; i++ {
            var url = NSURL(string: "http://\(urlSite)/api/get_post/?id=\(postsId.objectAtIndex(i))")
            var data = NSData(contentsOfURL: url)
            if data != nil {
                var jsonData : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                if jsonData != nil {
                    posts.addObject(jsonData.objectForKey("post"))
                }
            }
        }
        postFromId(post:posts)
    }
    
    func getCountOfPost(post: NSArray, count:(count:NSArray)->()) {
        var url = NSURL(string: "http://\(urlSite)/api/get_category_index")
        var data = NSData(contentsOfURL: url)
        if data != nil {
            var jsonData : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if jsonData != nil {
                var categoryInfos : NSArray = jsonData.objectForKey("categories") as NSArray
                var countArray = NSMutableArray()
                for var i = 0; i < categoryInfos.count; i++ {
                    var categoryId: AnyObject! = categoryInfos.objectAtIndex(i)
                    countArray.addObject(categoryId.objectForKey("post_count"))
                }
                count(count:countArray)
            }
        }
    }
    
    func loadMorePost(newPost:(post:NSArray)->()) {
        page++;
        var url = NSURL(string: "http://\(urlSite)/api/get_recent_posts/?page=\(page)")
        var data = NSData(contentsOfURL: url)
        if data != nil {
            var jsonData : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if jsonData != nil {
                var newPostArray : NSArray = jsonData.objectForKey("posts") as NSArray
                newPost(post:newPostArray)
            }
        }
    }
    
    func loadMorePostInCategory(categoryId:String, newPost:(post:NSArray)->()) {
        categoryPage++;
        var url = NSURL(string: "http://\(urlSite)/api/get_category_posts/?id=\(categoryId)&page=\(categoryPage)")
        var data = NSData(contentsOfURL: url)
        if data != nil {
            var jsonData : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            if jsonData != nil {
                var newPostArray : NSArray = jsonData.objectForKey("posts") as NSArray
                newPost(post:newPostArray)
            }
        }
    }
    
}

