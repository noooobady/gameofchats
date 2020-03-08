//
//  extensions.swift
//  gameofchats
//
//  Created by No Body on 2020/1/8.
//  Copyright © 2020 No Body. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()//避免重复下载

extension UIImageView{//扩展UIImageView的功能
    func loadImageUsingCacheWithUrlString(_ urlSrting: String){//下载图片//左边的小圆头像都是用这个下载的
        
        self.image = nil//先让图为空白，防止下拉时闪图
        
        //check catch for image first//节约流量
        if let cachedImage = imageCache.object(forKey: urlSrting as NSString)as? UIImage{
            self.image = cachedImage
            return
            
        }

        //otherwise fire off a new download
        let url = URL(string: urlSrting)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            //download hit an error so lets return out
            if let error = error{
            print(error)
                return
            }
            DispatchQueue.main.async {
                
                if let dowmloadedImage = UIImage(data: data!){//下载图片
                    imageCache.setObject(dowmloadedImage, forKey: urlSrting as NSString)//存入catch
                    self.image = dowmloadedImage
                }
                
                //cell.imageView?.image =  UIImage(data: data!)
            }
        }.resume()
    }
}
