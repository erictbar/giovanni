//
//  FileManagerAdditions.swift
//  GIOVANNI
//
//  Copyright (c) <2017>, Gabriel O'Flaherty-Chan
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. All advertising materials mentioning features or use of this software
//  must display the following acknowledgement:
//  This product includes software developed by skysent.
//  4. Neither the name of the skysent nor the
//  names of its contributors may be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY skysent ''AS IS'' AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL skysent BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

extension String {
	var isValidROMExtension: Bool {
        var beta = false;
		
        if(beta == true) {
            return ["gb", "gbc", "nes","snes", "zip"].contains(self)
        } else {
            return ["gb", "gbc", "zip"].contains(self)
        }
	}
}

extension FileManager {
	
	enum FileError: LocalizedError {
		case invalidExtension
		
		public var errorDescription: String? {
			switch self {
			case .invalidExtension:
				return "Not a valid ROM file"
			}
		}
	}
	
	var sharedDirectory: URL? {
        // Use the app's Documents directory instead of shared container
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	}

    var documentsDirectory: URL? {
        guard let shared = sharedDirectory else {
            return nil
        }
        var gamesDirectory = shared.appendingPathComponent("Games", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: gamesDirectory, withIntermediateDirectories: true)
            // Add .nosync to prevent iCloud backup if needed
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try gamesDirectory.setResourceValues(resourceValues)
        } catch {
            print("Error creating directory: \(error)")
        }
        return gamesDirectory
    }
	
	func receiveFile(at fileURL: URL, completion: ((String) -> Bool), failure: ((Error) -> Bool)) -> Bool {
		
		guard fileURL.pathExtension.isValidROMExtension else {
			return failure(FileError.invalidExtension)
		}
		
		do {
			let name = fileURL.lastPathComponent
			let destinationPath = documentsDirectory!.appendingPathComponent(name)
			try FileManager.default.moveItem(at: fileURL, to: destinationPath)
			return completion(name)
		} catch (let error) {
			return failure(error)
		}
	}
}
