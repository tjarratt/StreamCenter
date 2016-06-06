//
//  M3UParser.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation

class M3UParser {
    
    static func parseToDict(data : String) -> [TwitchStreamVideo]? {
        let dataByLine = data.componentsSeparatedByString("\n")
        
        var resultArray = [TwitchStreamVideo]()
        
        if(dataByLine[0] == "#EXTM3U"){
            for i in (1 ..< dataByLine.count) {
                if(dataByLine[i].hasPrefix("#EXT-X-STREAM-INF:PROGRAM-ID=1,")){
                    let line = dataByLine[i]
                    var codecs : String?
                    var quality : String?
                    var url : NSURL?
                    
                    if let codecsRange = line.rangeOfString("CODECS=\"") {
                        if let videoRange = line.rangeOfString("VIDEO=\"") {
                            let codesTypeRange : Range = codecsRange.endIndex ..< videoRange.startIndex.advancedBy(-2)
                            codecs = line.substringWithRange(codesTypeRange)

                            let qualityRange : Range = videoRange.endIndex ..< line.endIndex.advancedBy(-1)
                            quality = line.substringWithRange(qualityRange)
                            
                            if(dataByLine[i+1].hasPrefix("http")){
                                url = NSURL(string: dataByLine[i+1].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                            }
                        }
                    }
                    
                    if(codecs != nil && quality != nil && url != nil){
                        resultArray.append(TwitchStreamVideo(quality: quality!, url: url!, codecs: codecs!))
                    }
                    
                }
            }
        }
        else {
            Logger.Error("Data is not a valid M3U file")
        }
    
        return resultArray
    }
}
