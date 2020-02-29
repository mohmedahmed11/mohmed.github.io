//
//  PaymentViewController.swift
//  compress app
//
//  Created by MacBook Pro on 02/07/1441 AH.
//  Copyright © 1441 Pita Studio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

import Foundation
import CommonCrypto
 
var str = "Agnostic Development"
 
/**
 * Example SHA 256 Hash using CommonCrypto
 * CC_SHA256 API exposed from from CommonCrypto-60118.50.1:
 * https://opensource.apple.com/source/CommonCrypto/CommonCrypto-60118.50.1/include/CommonDigest.h.auto.html
 **/
func sha256(str: String) -> String {
 
    if let strData = str.data(using: String.Encoding.utf8) {
        /// #define CC_SHA256_DIGEST_LENGTH     32
        /// Creates an array of unsigned 8 bit integers that contains 32 zeros
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
 
        /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
        /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
        strData.withUnsafeBytes {
            // CommonCrypto
            // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
            // OpenSSL                                                                             |
            // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
            CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
        }
 
        var sha256String = ""
        /// Unpack each byte in the digest array and add them to the sha256String
        for byte in digest {
            sha256String += String(format:"%02x", UInt8(byte))
        }
 
        if sha256String.uppercased() == "E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188" {
            print("Matching sha256 hash: E8721A6EBEA3B23768D943D075035C7819662B581E487456FDB1A7129C769188")
        } else {
            print("sha256 hash does not match: \(sha256String)")
        }
        return sha256String
    }
    return ""
}

class PaymentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadIbSession()
        // Do any additional setup after loading the view.
    }
    
    func loadIbSession() {
        let url = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
        
        let shaString = "asdfaccess_code=lrYQoSprur5faH0ZuLyyAdevice_id=272E8227-76BA-4911-A4DD-30EA3569D9D2language=enmerchant_identifier=52bd2413service_command=SDK_TOKENasdf"
        
        let sha256Str = sha256(str: shaString)
        print(sha256Str)


        
        let parameters: Parameters = [ "access_code": "lrYQoSprur5faH0ZuLyy", "device_id": "\(UIDevice.current.identifierForVendor!.uuidString)", "language": "en", "merchant_identifier": "52bd2413","service_command":"SDK_TOKEN", "signature": sha256Str]
        let headers: HTTPHeaders = [
            "Accept": "application/json",
        ]
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { (data) in
            print("\(parameters)")
        }
        .responseString { (data) in
            print(data)
            print("\(shaString)")
        }
        
//        Alamofire.request(<#T##url: URLConvertible##URLConvertible#>, method: <#T##HTTPMethod#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

import CommonCrypto
import CryptoKit
import Foundation


extension String {
    func sha256(_ data: Data) -> Data? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return res as Data
    }

    func sha256() -> String? {
        guard
            let data = self.data(using: String.Encoding.utf8),
            let shaData = sha256(data)
            else { return nil }
        let rc = shaData.base64EncodedString(options: [])
        return rc
    }
}

