//
//  M3UParser.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation

class M3UParser {

    static func parseToDict(_ data : String) -> [TwitchStreamVideo]? {
        let dataByLine = data.components(separatedBy: "\n")

        var resultArray = [TwitchStreamVideo]()

        if dataByLine[0] == "#EXTM3U" {
            for i in (1 ..< dataByLine.count) {
                if(dataByLine[i].hasPrefix("#EXT-X-STREAM-INF:PROGRAM-ID=1,")){
                    let line = dataByLine[i]
                    var codecs : String?
                    var quality : String?
                    var url : URL?

                    if let codecsRange = line.range(of: "CODECS=\"") {
                        if let videoRange = line.range(of: "VIDEO=\"") {
                            let lowerBound = codecsRange.upperBound
                            let upperBound = line.index(codecsRange.lowerBound, offsetBy: -2)
                            let codesTypeRange = upperBound ..< lowerBound
                            codecs = line.substring(with: codesTypeRange)

                            let qualityRange : Range = videoRange.upperBound ..< line.characters.index(line.endIndex, offsetBy: -1)
                            quality = line.substring(with: qualityRange)

                            if dataByLine[i+1].hasPrefix("http") {
                                url = URL(string: dataByLine[i+1].addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
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
