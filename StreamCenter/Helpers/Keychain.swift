//
//  Keychain.swift
//  KeychainAccess
//
//  Created by kishikawa katsumi on 2014/12/24.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

import Foundation
import Security

public let KeychainAccessErrorDomain = "com.OlivierBoucher.StreamCenter.error"

public enum ItemClass {
    case genericPassword
    case internetPassword
}

public enum ProtocolType {
    case ftp
    case ftpAccount
    case http
    case irc
    case nntp
    case pop3
    case smtp
    case socks
    case imap
    case ldap
    case appleTalk
    case afp
    case telnet
    case ssh
    case ftps
    case https
    case httpProxy
    case httpsProxy
    case ftpProxy
    case smb
    case rtsp
    case rtspProxy
    case daap
    case eppc
    case ipp
    case nntps
    case ldaps
    case telnetS
    case imaps
    case ircs
    case pop3S
}

public enum AuthenticationType {
    case ntlm
    case msn
    case dpa
    case rpa
    case httpBasic
    case httpDigest
    case htmlForm
    case `default`
}

public enum Accessibility {
    /**
     Item data can only be accessed
     while the device is unlocked. This is recommended for items that only
     need be accesible while the application is in the foreground. Items
     with this attribute will migrate to a new device when using encrypted
     backups.
     */
    case whenUnlocked
    
    /**
     Item data can only be
     accessed once the device has been unlocked after a restart. This is
     recommended for items that need to be accesible by background
     applications. Items with this attribute will migrate to a new device
     when using encrypted backups.
     */
    case afterFirstUnlock
    
    /**
     Item data can always be accessed
     regardless of the lock state of the device. This is not recommended
     for anything except system use. Items with this attribute will migrate
     to a new device when using encrypted backups.
     */
    case always
    
    /**
     Item data can
     only be accessed while the device is unlocked. This class is only
     available if a passcode is set on the device. This is recommended for
     items that only need to be accessible while the application is in the
     foreground. Items with this attribute will never migrate to a new
     device, so after a backup is restored to a new device, these items
     will be missing. No items can be stored in this class on devices
     without a passcode. Disabling the device passcode will cause all
     items in this class to be deleted.
     */
    @available(iOS 8.0, OSX 10.10, *)
    case whenPasscodeSetThisDeviceOnly
    
    /**
     Item data can only
     be accessed while the device is unlocked. This is recommended for items
     that only need be accesible while the application is in the foreground.
     Items with this attribute will never migrate to a new device, so after
     a backup is restored to a new device, these items will be missing.
     */
    case whenUnlockedThisDeviceOnly
    
    /**
     Item data can
     only be accessed once the device has been unlocked after a restart.
     This is recommended for items that need to be accessible by background
     applications. Items with this attribute will never migrate to a new
     device, so after a backup is restored to a new device these items will
     be missing.
     */
    case afterFirstUnlockThisDeviceOnly
    
    /**
     Item data can always
     be accessed regardless of the lock state of the device. This option
     is not recommended for anything except system use. Items with this
     attribute will never migrate to a new device, so after a backup is
     restored to a new device, these items will be missing.
     */
    case alwaysThisDeviceOnly
}

public struct AuthenticationPolicy : OptionSet {
    /**
     User presence policy using Touch ID or Passcode. Touch ID does not
     have to be available or enrolled. Item is still accessible by Touch ID
     even if fingers are added or removed.
     */
    @available(iOS 8.0, OSX 10.10, *)
    @available(watchOS, unavailable)
    public static let UserPresence = AuthenticationPolicy(rawValue: 1 << 0)
    
    /**
     Constraint: Touch ID (any finger). Touch ID must be available and
     at least one finger must be enrolled. Item is still accessible by
     Touch ID even if fingers are added or removed.
     */
    @available(iOS 9.0, *)
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    public static let TouchIDAny = AuthenticationPolicy(rawValue: 1 << 1)
    
    /**
     Constraint: Touch ID from the set of currently enrolled fingers.
     Touch ID must be available and at least one finger must be enrolled.
     When fingers are added or removed, the item is invalidated.
     */
    @available(iOS 9.0, *)
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    public static let TouchIDCurrentSet = AuthenticationPolicy(rawValue: 1 << 3)
    
    /**
     Constraint: Device passcode
     */
    @available(iOS 9.0, OSX 10.11, *)
    @available(watchOS, unavailable)
    public static let DevicePasscode = AuthenticationPolicy(rawValue: 1 << 4)
    
    /**
     Constraint logic operation: when using more than one constraint,
     at least one of them must be satisfied.
     */
    @available(iOS 9.0, *)
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    public static let Or = AuthenticationPolicy(rawValue: 1 << 14)
    
    /**
     Constraint logic operation: when using more than one constraint,
     all must be satisfied.
     */
    @available(iOS 9.0, *)
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    public static let And = AuthenticationPolicy(rawValue: 1 << 15)
    
    /**
     Create access control for private key operations (i.e. sign operation)
     */
    @available(iOS 9.0, *)
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    public static let PrivateKeyUsage = AuthenticationPolicy(rawValue: 1 << 30)
    
    /**
     Security: Application provided password for data encryption key generation.
     This is not a constraint but additional item encryption mechanism.
     */
    @available(iOS 9.0, *)
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    public static let ApplicationPassword = AuthenticationPolicy(rawValue: 1 << 31)
    
    public let rawValue : Int
    
    public init(rawValue:Int) {
        self.rawValue = rawValue
    }
}

/** Class Key Constant */
private let Class = kSecClass as String

/** Attribute Key Constants */
private let AttributeAccessible = kSecAttrAccessible as String

@available(iOS 8.0, OSX 10.10, *)
private let AttributeAccessControl = kSecAttrAccessControl as String

private let AttributeAccessGroup = kSecAttrAccessGroup as String
private let AttributeSynchronizable = kSecAttrSynchronizable as String
private let AttributeComment = kSecAttrComment as String
private let AttributeLabel = kSecAttrLabel as String
private let AttributeAccount = kSecAttrAccount as String
private let AttributeService = kSecAttrService as String
private let AttributeServer = kSecAttrServer as String
private let AttributeProtocol = kSecAttrProtocol as String
private let AttributeAuthenticationType = kSecAttrAuthenticationType as String
private let AttributePort = kSecAttrPort as String

private let SynchronizableAny = kSecAttrSynchronizableAny

/** Search Constants */
private let MatchLimit = kSecMatchLimit as String
private let MatchLimitOne = kSecMatchLimitOne
private let MatchLimitAll = kSecMatchLimitAll

/** Return Type Key Constants */
private let ReturnData = kSecReturnData as String
private let ReturnAttributes = kSecReturnAttributes as String

/** Value Type Key Constants */
private let ValueData = kSecValueData as String

/** Other Constants */
@available(iOS 8.0, OSX 10.10, *)
private let UseOperationPrompt = kSecUseOperationPrompt as String

#if os(iOS)
    @available(iOS, introduced: 8.0, deprecated: 9.0, message: "Use a UseAuthenticationUI instead.")
    private let UseNoAuthenticationUI = kSecUseNoAuthenticationUI as String
#endif

@available(iOS 9.0, OSX 10.11, *)
@available(watchOS, unavailable)
private let UseAuthenticationUI = kSecUseAuthenticationUI as String

@available(iOS 9.0, OSX 10.11, *)
@available(watchOS, unavailable)
private let UseAuthenticationContext = kSecUseAuthenticationContext as String

@available(iOS 9.0, OSX 10.11, *)
@available(watchOS, unavailable)
private let UseAuthenticationUIAllow = kSecUseAuthenticationUIAllow as String

@available(iOS 9.0, OSX 10.11, *)
@available(watchOS, unavailable)
private let UseAuthenticationUIFail = kSecUseAuthenticationUIFail as String

@available(iOS 9.0, OSX 10.11, *)
@available(watchOS, unavailable)
private let UseAuthenticationUISkip = kSecUseAuthenticationUISkip as String

#if os(iOS)
    /** Credential Key Constants */
    private let SharedPassword = kSecSharedPassword as String
#endif

open class Keychain {
    open var itemClass: ItemClass {
        return options.itemClass
    }
    
    open var service: String {
        return options.service
    }
    
    open var accessGroup: String? {
        return options.accessGroup
    }
    
    open var server: URL {
        return options.server
    }
    
    open var protocolType: ProtocolType {
        return options.protocolType
    }
    
    open var authenticationType: AuthenticationType {
        return options.authenticationType
    }
    
    open var accessibility: Accessibility {
        return options.accessibility
    }
    
    @available(iOS 8.0, OSX 10.10, *)
    @available(watchOS, unavailable)
    open var authenticationPolicy: AuthenticationPolicy? {
        return options.authenticationPolicy
    }
    
    open var synchronizable: Bool {
        return options.synchronizable
    }
    
    open var label: String? {
        return options.label
    }
    
    open var comment: String? {
        return options.comment
    }
    
    @available(iOS 8.0, OSX 10.10, *)
    @available(watchOS, unavailable)
    open var authenticationPrompt: String? {
        return options.authenticationPrompt
    }
    
    fileprivate let options: Options
    
    // MARK:
    
    public convenience init() {
        var options = Options()
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            options.service = bundleIdentifier
        }
        self.init(options)
    }
    
    public convenience init(service: String) {
        var options = Options()
        options.service = service
        self.init(options)
    }
    
    public convenience init(accessGroup: String) {
        var options = Options()
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            options.service = bundleIdentifier
        }
        options.accessGroup = accessGroup
        self.init(options)
    }
    
    public convenience init(service: String, accessGroup: String) {
        var options = Options()
        options.service = service
        options.accessGroup = accessGroup
        self.init(options)
    }
    
    public convenience init(server: String, protocolType: ProtocolType) {
        self.init(server: URL(string: server)!, protocolType: protocolType)
    }
    
    public convenience init(server: String, protocolType: ProtocolType, authenticationType: AuthenticationType) {
        self.init(server: URL(string: server)!, protocolType: protocolType, authenticationType: authenticationType)
    }
    
    public convenience init(server: URL, protocolType: ProtocolType) {
        self.init(server: server, protocolType: protocolType, authenticationType: .default)
    }
    
    public convenience init(server: URL, protocolType: ProtocolType, authenticationType: AuthenticationType) {
        var options = Options()
        options.itemClass = .internetPassword
        options.server = server
        options.protocolType = protocolType
        options.authenticationType = authenticationType
        self.init(options)
    }
    
    fileprivate init(_ opts: Options) {
        options = opts
    }
    
    // MARK:
    
    open func accessibility(_ accessibility: Accessibility) -> Keychain {
        var options = self.options
        options.accessibility = accessibility
        return Keychain(options)
    }
    
    @available(iOS 8.0, OSX 10.10, *)
    @available(watchOS, unavailable)
    open func accessibility(_ accessibility: Accessibility, authenticationPolicy: AuthenticationPolicy) -> Keychain {
        var options = self.options
        options.accessibility = accessibility
        options.authenticationPolicy = authenticationPolicy
        return Keychain(options)
    }
    
    open func synchronizable(_ synchronizable: Bool) -> Keychain {
        var options = self.options
        options.synchronizable = synchronizable
        return Keychain(options)
    }
    
    open func label(_ label: String) -> Keychain {
        var options = self.options
        options.label = label
        return Keychain(options)
    }
    
    open func comment(_ comment: String) -> Keychain {
        var options = self.options
        options.comment = comment
        return Keychain(options)
    }
    
    @available(iOS 8.0, OSX 10.10, *)
    @available(watchOS, unavailable)
    open func authenticationPrompt(_ authenticationPrompt: String) -> Keychain {
        var options = self.options
        options.authenticationPrompt = authenticationPrompt
        return Keychain(options)
    }
    
    // MARK:
    
    open func get(_ key: String) throws -> String? {
        return try getString(key)
    }
    
    open func getString(_ key: String) throws -> String? {
        guard let data = try getData(key) else  {
            return nil
        }
        guard let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            throw conversionError(message: "failed to convert data to string")
        }
        return string
    }
    
    open func getData(_ key: String) throws -> Data? {
        var query = options.query()
        
        query[MatchLimit] = MatchLimitOne
        query[ReturnData] = true as AnyObject?
        
        query[AttributeAccount] = key as AnyObject?
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw Status.unexpectedError
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw securityError(status: status)
        }
    }
    
    // MARK:
    
    open func set(_ value: String, key: String) throws {
        guard let data = value.data(using: String.Encoding.utf8, allowLossyConversion: false) else {
            throw conversionError(message: "failed to convert string to data")
        }
        try set(data, key: key)
    }
    
    open func set(_ value: Data, key: String) throws {
        var query = options.query()
        query[AttributeAccount] = key as AnyObject?
        #if os(iOS)
            if #available(iOS 9.0, *) {
                query[UseAuthenticationUI] = UseAuthenticationUIFail
            } else {
                query[UseNoAuthenticationUI] = true
            }
        #elseif os(OSX)
            if #available(OSX 10.11, *) {
                query[UseAuthenticationUI] = UseAuthenticationUIFail
            }
        #endif
        
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            var query = options.query()
            query[AttributeAccount] = key as AnyObject?
            
            let (attributes, error) = options.attributes(key: nil, value: value)
            if let error = error {
                print(error.localizedDescription)
                throw error
            }
            
            #if os(iOS)
                if status == errSecInteractionNotAllowed && floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_8_0) {
                    try remove(key)
                    try set(value, key: key)
                } else {
                    status = SecItemUpdate(query, attributes)
                    if status != errSecSuccess {
                        throw securityError(status: status)
                    }
                }
            #else
                status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
                if status != errSecSuccess {
                    throw securityError(status: status)
                }
            #endif
        case errSecItemNotFound:
            let (attributes, error) = options.attributes(key: key, value: value)
            if let error = error {
                print(error.localizedDescription)
                throw error
            }
            
            status = SecItemAdd(attributes as CFDictionary, nil)
            if status != errSecSuccess {
                throw securityError(status: status)
            }
        default:
            throw securityError(status: status)
        }
    }
    
    open subscript(key: String) -> String? {
        get {
            return (try? get(key)).flatMap { $0 }
        }
        
        set {
            if let value = newValue {
                do {
                    try set(value, key: key)
                } catch {}
            } else {
                do {
                    try remove(key)
                } catch {}
            }
        }
    }
    
    open subscript(string key: String) -> String? {
        get {
            return self[key]
        }
        
        set {
            self[key] = newValue
        }
    }
    
    open subscript(data key: String) -> Data? {
        get {
            return (try? getData(key)).flatMap { $0 }
        }
        
        set {
            if let value = newValue {
                do {
                    try set(value, key: key)
                } catch {}
            } else {
                do {
                    try remove(key)
                } catch {}
            }
        }
    }
    
    // MARK:
    
    open func remove(_ key: String) throws {
        var query = options.query()
        query[AttributeAccount] = key as AnyObject?
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw securityError(status: status)
        }
    }
    
    open func removeAll() throws {
        var query = options.query()
        #if !os(iOS) && !os(watchOS)
            query[MatchLimit] = MatchLimitAll
        #endif
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw securityError(status: status)
        }
    }
    
    // MARK:
    
    open func contains(_ key: String) throws -> Bool {
        var query = options.query()
        query[AttributeAccount] = key as AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw securityError(status: status)
        }
    }
    
    // MARK:
    
    open class func allKeys(_ itemClass: ItemClass) -> [(String, String)] {
        var query = [String: AnyObject]()
        query[Class] = itemClass.rawValue as AnyObject?
        query[AttributeSynchronizable] = SynchronizableAny
        query[MatchLimit] = MatchLimitAll
        query[ReturnAttributes] = true as AnyObject?
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
        case errSecSuccess:
            if let items = result as? [[String: AnyObject]] {
                return prettify(itemClass: itemClass, items: items).map {
                    let key = $0["key"] as! String?
                    switch itemClass {
                    case .genericPassword:
                        let service = $0["service"] as! String?
                        return ((service ?? ""), (key ?? ""))
                    case .internetPassword:
                        let server = $0["server"] as! String?
                        return ((server ?? ""), (key ?? ""))
                    }
                }
            }
        case errSecItemNotFound:
            return []
        default: ()
        }
        
        _ = securityError(status: status)
        return []
    }
    
    open func allKeys() -> [String] {
        return type(of: self).prettify(itemClass: itemClass, items: items()).map { $0["key"] as! String }
    }
    
    open class func allItems(_ itemClass: ItemClass) -> [[String: AnyObject]] {
        var query = [String: AnyObject]()
        query[Class] = itemClass.rawValue as AnyObject?
        query[MatchLimit] = MatchLimitAll
        query[ReturnAttributes] = true as AnyObject?
        #if os(iOS) || os(watchOS)
            query[ReturnData] = true
        #endif
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
        case errSecSuccess:
            if let items = result as? [[String: AnyObject]] {
                return prettify(itemClass: itemClass, items: items)
            }
        case errSecItemNotFound:
            return []
        default: ()
        }
        
        _ = securityError(status: status)
        return []
    }
    
    open func allItems() -> [[String: AnyObject]] {
        return type(of: self).prettify(itemClass: itemClass, items: items())
    }
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public func getSharedPassword(completion: (_ account: String?, _ password: String?, _ error: NSError?) -> () = { account, password, error -> () in }) {
    if let domain = server.host {
    type(of: self).requestSharedWebCredential(domain: domain, account: nil) { (credentials, error) -> () in
    if let credential = credentials.first {
    let account = credential["account"]
    let password = credential["password"]
    completion(account: account, password: password, error: error)
    } else {
    completion(account: nil, password: nil, error: error)
    }
    }
    } else {
    let error = securityError(status: Status.Param.rawValue)
    completion(account: nil, password: nil, error: error)
    }
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public func getSharedPassword(account: String, completion: (_ password: String?, _ error: NSError?) -> () = { password, error -> () in }) {
    if let domain = server.host {
    type(of: self).requestSharedWebCredential(domain: domain, account: account) { (credentials, error) -> () in
    if let credential = credentials.first {
    if let password = credential["password"] {
    completion(password: password, error: error)
    } else {
    completion(password: nil, error: error)
    }
    } else {
    completion(password: nil, error: error)
    }
    }
    } else {
    let error = securityError(status: Status.Param.rawValue)
    completion(password: nil, error: error)
    }
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public func setSharedPassword(password: String, account: String, completion: (_ error: NSError?) -> () = { e -> () in }) {
    setSharedPassword(password as String?, account: account, completion: completion)
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    private func setSharedPassword(password: String?, account: String, completion: (_ error: NSError?) -> () = { e -> () in }) {
    if let domain = server.host {
    SecAddSharedWebCredential(domain, account, password) { error -> () in
    if let error = error {
    completion(error: error.error)
    } else {
    completion(error: nil)
    }
    }
    } else {
    let error = securityError(status: Status.Param.rawValue)
    completion(error: error)
    }
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public func removeSharedPassword(account: String, completion: (_ error: NSError?) -> () = { e -> () in }) {
    setSharedPassword(nil, account: account, completion: completion)
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public class func requestSharedWebCredential(completion: (_ credentials: [[String: String]], _ error: NSError?) -> () = { credentials, error -> () in }) {
    requestSharedWebCredential(domain: nil, account: nil, completion: completion)
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public class func requestSharedWebCredential(domain: String, completion: (_ credentials: [[String: String]], _ error: NSError?) -> () = { credentials, error -> () in }) {
    requestSharedWebCredential(domain: domain, account: nil, completion: completion)
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public class func requestSharedWebCredential(domain: String, account: String, completion: (_ credentials: [[String: String]], _ error: NSError?) -> () = { credentials, error -> () in }) {
    requestSharedWebCredential(domain: Optional(domain), account: Optional(account), completion: completion)
    }
    #endif
    
    #if os(iOS)
    @available(iOS 8.0, *)
    private class func requestSharedWebCredential(domain: String?, account: String?, completion: (_ credentials: [[String: String]], _ error: NSError?) -> ()) {
    SecRequestSharedWebCredential(domain, account) { (credentials, error) -> () in
    var remoteError: NSError?
    if let error = error {
    remoteError = error.error
    if remoteError?.code != Int(errSecItemNotFound) {
    print("error:[\(remoteError!.code)] \(remoteError!.localizedDescription)")
    }
    }
    if let credentials = credentials as? [[String: AnyObject]] {
    let credentials = credentials.map { credentials -> [String: String] in
    var credential = [String: String]()
    if let server = credentials[AttributeServer] as? String {
    credential["server"] = server
    }
    if let account = credentials[AttributeAccount] as? String {
    credential["account"] = account
    }
    if let password = credentials[SharedPassword] as? String {
    credential["password"] = password
    }
    return credential
    }
    completion(credentials: credentials, error: remoteError)
    } else {
    completion(credentials: [], error: remoteError)
    }
    }
    }
    #endif
    
    #if os(iOS)
    /**
    @abstract Returns a randomly generated password.
    @return String password in the form xxx-xxx-xxx-xxx where x is taken from the sets "abcdefghkmnopqrstuvwxy", "ABCDEFGHJKLMNPQRSTUVWXYZ", "3456789" with at least one character from each set being present.
    */
    @available(iOS 8.0, *)
    public class func generatePassword() -> String {
    return SecCreateSharedWebCredentialPassword()! as String
    }
    #endif
    
    // MARK:
    
    fileprivate func items() -> [[String: AnyObject]] {
        var query = options.query()
        query[MatchLimit] = MatchLimitAll
        query[ReturnAttributes] = true as AnyObject?
        #if os(iOS)
            query[ReturnData] = true
        #endif
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        switch status {
        case errSecSuccess:
            if let items = result as? [[String: AnyObject]] {
                return items
            }
        case errSecItemNotFound:
            return []
        default: ()
        }
        
        _ = securityError(status: status)
        return []
    }
    
    fileprivate class func prettify(itemClass: ItemClass, items: [[String: AnyObject]]) -> [[String: AnyObject]] {
        let items = items.map { attributes -> [String: AnyObject] in
            var item = [String: AnyObject]()
            
            item["class"] = itemClass.description as AnyObject?
            
            switch itemClass {
            case .genericPassword:
                if let service = attributes[AttributeService] as? String {
                    item["service"] = service as AnyObject?
                }
                if let accessGroup = attributes[AttributeAccessGroup] as? String {
                    item["accessGroup"] = accessGroup as AnyObject?
                }
            case .internetPassword:
                if let server = attributes[AttributeServer] as? String {
                    item["server"] = server as AnyObject?
                }
                if let proto = attributes[AttributeProtocol] as? String {
                    if let protocolType = ProtocolType(rawValue: proto) {
                        item["protocol"] = protocolType.description as AnyObject?
                    }
                }
                if let auth = attributes[AttributeAuthenticationType] as? String {
                    if let authenticationType = AuthenticationType(rawValue: auth) {
                        item["authenticationType"] = authenticationType.description as AnyObject?
                    }
                }
            }
            
            if let key = attributes[AttributeAccount] as? String {
                item["key"] = key as AnyObject?
            }
            if let data = attributes[ValueData] as? Data {
                if let text = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                    item["value"] = text as AnyObject?
                } else  {
                    item["value"] = data as AnyObject?
                }
            }
            
            if let accessible = attributes[AttributeAccessible] as? String {
                if let accessibility = Accessibility(rawValue: accessible) {
                    item["accessibility"] = accessibility.description as AnyObject?
                }
            }
            if let synchronizable = attributes[AttributeSynchronizable] as? Bool {
                let synchronizableValue = synchronizable ? "true" : "false"
                item["synchronizable"] = synchronizableValue as AnyObject?
            }
            
            return item
        }
        return items
    }
    
    // MARK:
    
    fileprivate class func conversionError(message: String) -> NSError {
        let error = NSError(domain: KeychainAccessErrorDomain, code: Int(Status.conversionError.rawValue), userInfo: [NSLocalizedDescriptionKey: message])
        print("error:[\(error.code)] \(error.localizedDescription)")
        
        return error
    }
    
    fileprivate func conversionError(message: String) -> NSError {
        return type(of: self).conversionError(message: message)
    }
    
    fileprivate class func securityError(status: OSStatus) -> NSError {
        let message = Status(rawValue: status)!.description
        
        let error = NSError(domain: KeychainAccessErrorDomain, code: Int(status), userInfo: [NSLocalizedDescriptionKey: message])
        print("OSStatus error:[\(error.code)] \(error.localizedDescription)")
        
        return error
    }
    
    fileprivate func securityError(status: OSStatus) -> NSError {
        return type(of: self).securityError(status: status)
    }
}

struct Options {
    var itemClass: ItemClass = .genericPassword
    
    var service: String = ""
    var accessGroup: String? = nil
    
    var server: URL!
    var protocolType: ProtocolType!
    var authenticationType: AuthenticationType = .default
    
    var accessibility: Accessibility = .afterFirstUnlock
    var authenticationPolicy: AuthenticationPolicy?
    
    var synchronizable: Bool = false
    
    var label: String?
    var comment: String?
    
    var authenticationPrompt: String?
    
    init() {}
}

extension Keychain : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        let items = allItems()
        if items.isEmpty {
            return "[]"
        }
        var description = "[\n"
        for item in items {
            description += "  "
            description += "\(item)\n"
        }
        description += "]"
        return description
    }
    
    public var debugDescription: String {
        return "\(items())"
    }
}

extension Options {
    
    func query() -> [String: AnyObject] {
        var query = [String: AnyObject]()
        
        query[Class] = itemClass.rawValue as AnyObject?
        query[AttributeSynchronizable] = SynchronizableAny
        
        switch itemClass {
        case .genericPassword:
            query[AttributeService] = service as AnyObject?
            // Access group is not supported on any simulators.
            #if (!arch(i386) && !arch(x86_64)) || (!os(iOS) && !os(watchOS))
                if let accessGroup = self.accessGroup {
                    query[AttributeAccessGroup] = accessGroup as AnyObject?
                }
            #endif
        case .internetPassword:
            query[AttributeServer] = server.host as AnyObject?
            query[AttributePort] = server.port as AnyObject?
            query[AttributeProtocol] = protocolType.rawValue as AnyObject?
            query[AttributeAuthenticationType] = authenticationType.rawValue as AnyObject?
        }
        
        if #available(OSX 10.10, *) {
            if authenticationPrompt != nil {
                query[UseOperationPrompt] = authenticationPrompt as AnyObject?
            }
        }
        
        return query
    }
    
    func attributes(key: String?, value: Data) -> ([String: AnyObject], NSError?) {
        var attributes: [String: AnyObject]
        
        if key != nil {
            attributes = query()
            attributes[AttributeAccount] = key as AnyObject?
        } else {
            attributes = [String: AnyObject]()
        }
        
        attributes[ValueData] = value as AnyObject?
        
        if label != nil {
            attributes[AttributeLabel] = label as AnyObject?
        }
        if comment != nil {
            attributes[AttributeComment] = comment as AnyObject?
        }
        
        if let policy = authenticationPolicy {
            if #available(OSX 10.10, *) {
                var error: Unmanaged<CFError>?
                guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, accessibility.rawValue as CFTypeRef, SecAccessControlCreateFlags(rawValue: CFOptionFlags(policy.rawValue)), &error) else {
                    if let error = error?.takeUnretainedValue() {
                        return (attributes, error.error)
                    }
                    let message = Status.unexpectedError.description
                    return (attributes, NSError(domain: KeychainAccessErrorDomain, code: Int(Status.unexpectedError.rawValue), userInfo: [NSLocalizedDescriptionKey: message]))
                }
                attributes[AttributeAccessControl] = accessControl
            } else {
                print("Unavailable 'Touch ID integration' on OS X versions prior to 10.10.")
            }
        } else {
            attributes[AttributeAccessible] = accessibility.rawValue as AnyObject?
        }
        
        attributes[AttributeSynchronizable] = synchronizable as AnyObject?
        
        return (attributes, nil)
    }
}

// MARK:

extension ItemClass : RawRepresentable, CustomStringConvertible {
    
    public init?(rawValue: String) {
        switch rawValue {
        case String(kSecClassGenericPassword):
            self = .genericPassword
        case String(kSecClassInternetPassword):
            self = .internetPassword
        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .genericPassword:
            return String(kSecClassGenericPassword)
        case .internetPassword:
            return String(kSecClassInternetPassword)
        }
    }
    
    public var description : String {
        switch self {
        case .genericPassword:
            return "GenericPassword"
        case .internetPassword:
            return "InternetPassword"
        }
    }
}

extension ProtocolType : RawRepresentable, CustomStringConvertible {
    
    public init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrProtocolFTP):
            self = .ftp
        case String(kSecAttrProtocolFTPAccount):
            self = .ftpAccount
        case String(kSecAttrProtocolHTTP):
            self = .http
        case String(kSecAttrProtocolIRC):
            self = .irc
        case String(kSecAttrProtocolNNTP):
            self = .nntp
        case String(kSecAttrProtocolPOP3):
            self = .pop3
        case String(kSecAttrProtocolSMTP):
            self = .smtp
        case String(kSecAttrProtocolSOCKS):
            self = .socks
        case String(kSecAttrProtocolIMAP):
            self = .imap
        case String(kSecAttrProtocolLDAP):
            self = .ldap
        case String(kSecAttrProtocolAppleTalk):
            self = .appleTalk
        case String(kSecAttrProtocolAFP):
            self = .afp
        case String(kSecAttrProtocolTelnet):
            self = .telnet
        case String(kSecAttrProtocolSSH):
            self = .ssh
        case String(kSecAttrProtocolFTPS):
            self = .ftps
        case String(kSecAttrProtocolHTTPS):
            self = .https
        case String(kSecAttrProtocolHTTPProxy):
            self = .httpProxy
        case String(kSecAttrProtocolHTTPSProxy):
            self = .httpsProxy
        case String(kSecAttrProtocolFTPProxy):
            self = .ftpProxy
        case String(kSecAttrProtocolSMB):
            self = .smb
        case String(kSecAttrProtocolRTSP):
            self = .rtsp
        case String(kSecAttrProtocolRTSPProxy):
            self = .rtspProxy
        case String(kSecAttrProtocolDAAP):
            self = .daap
        case String(kSecAttrProtocolEPPC):
            self = .eppc
        case String(kSecAttrProtocolIPP):
            self = .ipp
        case String(kSecAttrProtocolNNTPS):
            self = .nntps
        case String(kSecAttrProtocolLDAPS):
            self = .ldaps
        case String(kSecAttrProtocolTelnetS):
            self = .telnetS
        case String(kSecAttrProtocolIMAPS):
            self = .imaps
        case String(kSecAttrProtocolIRCS):
            self = .ircs
        case String(kSecAttrProtocolPOP3S):
            self = .pop3S
        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .ftp:
            return kSecAttrProtocolFTP as String
        case .ftpAccount:
            return kSecAttrProtocolFTPAccount as String
        case .http:
            return kSecAttrProtocolHTTP as String
        case .irc:
            return kSecAttrProtocolIRC as String
        case .nntp:
            return kSecAttrProtocolNNTP as String
        case .pop3:
            return kSecAttrProtocolPOP3 as String
        case .smtp:
            return kSecAttrProtocolSMTP as String
        case .socks:
            return kSecAttrProtocolSOCKS as String
        case .imap:
            return kSecAttrProtocolIMAP as String
        case .ldap:
            return kSecAttrProtocolLDAP as String
        case .appleTalk:
            return kSecAttrProtocolAppleTalk as String
        case .afp:
            return kSecAttrProtocolAFP as String
        case .telnet:
            return kSecAttrProtocolTelnet as String
        case .ssh:
            return kSecAttrProtocolSSH as String
        case .ftps:
            return kSecAttrProtocolFTPS as String
        case .https:
            return kSecAttrProtocolHTTPS as String
        case .httpProxy:
            return kSecAttrProtocolHTTPProxy as String
        case .httpsProxy:
            return kSecAttrProtocolHTTPSProxy as String
        case .ftpProxy:
            return kSecAttrProtocolFTPProxy as String
        case .smb:
            return kSecAttrProtocolSMB as String
        case .rtsp:
            return kSecAttrProtocolRTSP as String
        case .rtspProxy:
            return kSecAttrProtocolRTSPProxy as String
        case .daap:
            return kSecAttrProtocolDAAP as String
        case .eppc:
            return kSecAttrProtocolEPPC as String
        case .ipp:
            return kSecAttrProtocolIPP as String
        case .nntps:
            return kSecAttrProtocolNNTPS as String
        case .ldaps:
            return kSecAttrProtocolLDAPS as String
        case .telnetS:
            return kSecAttrProtocolTelnetS as String
        case .imaps:
            return kSecAttrProtocolIMAPS as String
        case .ircs:
            return kSecAttrProtocolIRCS as String
        case .pop3S:
            return kSecAttrProtocolPOP3S as String
        }
    }
    
    public var description : String {
        switch self {
        case .ftp:
            return "FTP"
        case .ftpAccount:
            return "FTPAccount"
        case .http:
            return "HTTP"
        case .irc:
            return "IRC"
        case .nntp:
            return "NNTP"
        case .pop3:
            return "POP3"
        case .smtp:
            return "SMTP"
        case .socks:
            return "SOCKS"
        case .imap:
            return "IMAP"
        case .ldap:
            return "LDAP"
        case .appleTalk:
            return "AppleTalk"
        case .afp:
            return "AFP"
        case .telnet:
            return "Telnet"
        case .ssh:
            return "SSH"
        case .ftps:
            return "FTPS"
        case .https:
            return "HTTPS"
        case .httpProxy:
            return "HTTPProxy"
        case .httpsProxy:
            return "HTTPSProxy"
        case .ftpProxy:
            return "FTPProxy"
        case .smb:
            return "SMB"
        case .rtsp:
            return "RTSP"
        case .rtspProxy:
            return "RTSPProxy"
        case .daap:
            return "DAAP"
        case .eppc:
            return "EPPC"
        case .ipp:
            return "IPP"
        case .nntps:
            return "NNTPS"
        case .ldaps:
            return "LDAPS"
        case .telnetS:
            return "TelnetS"
        case .imaps:
            return "IMAPS"
        case .ircs:
            return "IRCS"
        case .pop3S:
            return "POP3S"
        }
    }
}

extension AuthenticationType : RawRepresentable, CustomStringConvertible {
    
    public init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrAuthenticationTypeNTLM):
            self = .ntlm
        case String(kSecAttrAuthenticationTypeMSN):
            self = .msn
        case String(kSecAttrAuthenticationTypeDPA):
            self = .dpa
        case String(kSecAttrAuthenticationTypeRPA):
            self = .rpa
        case String(kSecAttrAuthenticationTypeHTTPBasic):
            self = .httpBasic
        case String(kSecAttrAuthenticationTypeHTTPDigest):
            self = .httpDigest
        case String(kSecAttrAuthenticationTypeHTMLForm):
            self = .htmlForm
        case String(kSecAttrAuthenticationTypeDefault):
            self = .`default`
        default:
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .ntlm:
            return kSecAttrAuthenticationTypeNTLM as String
        case .msn:
            return kSecAttrAuthenticationTypeMSN as String
        case .dpa:
            return kSecAttrAuthenticationTypeDPA as String
        case .rpa:
            return kSecAttrAuthenticationTypeRPA as String
        case .httpBasic:
            return kSecAttrAuthenticationTypeHTTPBasic as String
        case .httpDigest:
            return kSecAttrAuthenticationTypeHTTPDigest as String
        case .htmlForm:
            return kSecAttrAuthenticationTypeHTMLForm as String
        default:
            return kSecAttrAuthenticationTypeDefault as String
        }
    }
    
    public var description : String {
        switch self {
        case .ntlm:
            return "NTLM"
        case .msn:
            return "MSN"
        case .dpa:
            return "DPA"
        case .rpa:
            return "RPA"
        case .httpBasic:
            return "HTTPBasic"
        case .httpDigest:
            return "HTTPDigest"
        case .htmlForm:
            return "HTMLForm"
        default:
            return "Default"
        }
    }
}

extension Accessibility : RawRepresentable, CustomStringConvertible {
    
    public init?(rawValue: String) {
        if #available(OSX 10.10, *) {
            switch rawValue {
            case String(kSecAttrAccessibleWhenUnlocked):
                self = .whenUnlocked
            case String(kSecAttrAccessibleAfterFirstUnlock):
                self = .afterFirstUnlock
            case String(kSecAttrAccessibleAlways):
                self = .always
            case String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly):
                self = .whenPasscodeSetThisDeviceOnly
            case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
                self = .whenUnlockedThisDeviceOnly
            case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
                self = .afterFirstUnlockThisDeviceOnly
            case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
                self = .alwaysThisDeviceOnly
            default:
                return nil
            }
        } else {
            switch rawValue {
            case String(kSecAttrAccessibleWhenUnlocked):
                self = .whenUnlocked
            case String(kSecAttrAccessibleAfterFirstUnlock):
                self = .afterFirstUnlock
            case String(kSecAttrAccessibleAlways):
                self = .always
            case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
                self = .whenUnlockedThisDeviceOnly
            case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
                self = .afterFirstUnlockThisDeviceOnly
            case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
                self = .alwaysThisDeviceOnly
            default:
                return nil
            }
        }
    }
    
    public var rawValue: String {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked as String
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock as String
        case .always:
            return kSecAttrAccessibleAlways as String
        case .whenPasscodeSetThisDeviceOnly:
            if #available(OSX 10.10, *) {
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String
            } else {
                fatalError("'Accessibility.WhenPasscodeSetThisDeviceOnly' is not available on this version of OS.")
            }
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        case .alwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly as String
        }
    }
    
    public var description : String {
        switch self {
        case .whenUnlocked:
            return "WhenUnlocked"
        case .afterFirstUnlock:
            return "AfterFirstUnlock"
        case .always:
            return "Always"
        case .whenPasscodeSetThisDeviceOnly:
            return "WhenPasscodeSetThisDeviceOnly"
        case .whenUnlockedThisDeviceOnly:
            return "WhenUnlockedThisDeviceOnly"
        case .afterFirstUnlockThisDeviceOnly:
            return "AfterFirstUnlockThisDeviceOnly"
        case .alwaysThisDeviceOnly:
            return "AlwaysThisDeviceOnly"
        }
    }
}

extension CFError {
    var error: NSError {
        let domain = CFErrorGetDomain(self) as String
        let code = CFErrorGetCode(self)
        let userInfo = CFErrorCopyUserInfo(self) as! [AnyHashable: Any]
        
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}

public enum Status : OSStatus, Error {
    case success
    case unimplemented
    case diskFull
    case io
    case opWr
    case param
    case wrPerm
    case allocate
    case userCanceled
    case badReq
    case internalComponent
    case notAvailable
    case readOnly
    case authFailed
    case noSuchKeychain
    case invalidKeychain
    case duplicateKeychain
    case duplicateCallback
    case invalidCallback
    case duplicateItem
    case itemNotFound
    case bufferTooSmall
    case dataTooLarge
    case noSuchAttr
    case invalidItemRef
    case invalidSearchRef
    case noSuchClass
    case noDefaultKeychain
    case interactionNotAllowed
    case readOnlyAttr
    case wrongSecVersion
    case keySizeNotAllowed
    case noStorageModule
    case noCertificateModule
    case noPolicyModule
    case interactionRequired
    case dataNotAvailable
    case dataNotModifiable
    case createChainFailed
    case invalidPrefsDomain
    case inDarkWake
    case aclNotSimple
    case policyNotFound
    case invalidTrustSetting
    case noAccessForItem
    case invalidOwnerEdit
    case trustNotAvailable
    case unsupportedFormat
    case unknownFormat
    case keyIsSensitive
    case multiplePrivKeys
    case passphraseRequired
    case invalidPasswordRef
    case invalidTrustSettings
    case noTrustSettings
    case pkcs12VerifyFailure
    case invalidCertificate
    case notSigner
    case policyDenied
    case invalidKey
    case decode
    case `internal`
    case unsupportedAlgorithm
    case unsupportedOperation
    case unsupportedPadding
    case itemInvalidKey
    case itemInvalidKeyType
    case itemInvalidValue
    case itemClassMissing
    case itemMatchUnsupported
    case useItemListUnsupported
    case useKeychainUnsupported
    case useKeychainListUnsupported
    case returnDataUnsupported
    case returnAttributesUnsupported
    case returnRefUnsupported
    case returnPersitentRefUnsupported
    case valueRefUnsupported
    case valuePersistentRefUnsupported
    case returnMissingPointer
    case matchLimitUnsupported
    case itemIllegalQuery
    case waitForCallback
    case missingEntitlement
    case upgradePending
    case mpSignatureInvalid
    case otrTooOld
    case otridTooNew
    case serviceNotAvailable
    case insufficientClientID
    case deviceReset
    case deviceFailed
    case appleAddAppACLSubject
    case applePublicKeyIncomplete
    case appleSignatureMismatch
    case appleInvalidKeyStartDate
    case appleInvalidKeyEndDate
    case conversionError
    case appleSSLv2Rollback
    case quotaExceeded
    case fileTooBig
    case invalidDatabaseBlob
    case invalidKeyBlob
    case incompatibleDatabaseBlob
    case incompatibleKeyBlob
    case hostNameMismatch
    case unknownCriticalExtensionFlag
    case noBasicConstraints
    case noBasicConstraintsCA
    case invalidAuthorityKeyID
    case invalidSubjectKeyID
    case invalidKeyUsageForPolicy
    case invalidExtendedKeyUsage
    case invalidIDLinkage
    case pathLengthConstraintExceeded
    case invalidRoot
    case crlExpired
    case crlNotValidYet
    case crlNotFound
    case crlServerDown
    case crlBadURI
    case unknownCertExtension
    case unknownCRLExtension
    case crlNotTrusted
    case crlPolicyFailed
    case idpFailure
    case smimeEmailAddressesNotFound
    case smimeBadExtendedKeyUsage
    case smimeBadKeyUsage
    case smimeKeyUsageNotCritical
    case smimeNoEmailAddress
    case smimeSubjAltNameNotCritical
    case sslBadExtendedKeyUsage
    case ocspBadResponse
    case ocspBadRequest
    case ocspUnavailable
    case ocspStatusUnrecognized
    case endOfData
    case incompleteCertRevocationCheck
    case networkFailure
    case ocspNotTrustedToAnchor
    case recordModified
    case ocspSignatureError
    case ocspNoSigner
    case ocspResponderMalformedReq
    case ocspResponderInternalError
    case ocspResponderTryLater
    case ocspResponderSignatureRequired
    case ocspResponderUnauthorized
    case ocspResponseNonceMismatch
    case codeSigningBadCertChainLength
    case codeSigningNoBasicConstraints
    case codeSigningBadPathLengthConstraint
    case codeSigningNoExtendedKeyUsage
    case codeSigningDevelopment
    case resourceSignBadCertChainLength
    case resourceSignBadExtKeyUsage
    case trustSettingDeny
    case invalidSubjectName
    case unknownQualifiedCertStatement
    case mobileMeRequestQueued
    case mobileMeRequestRedirected
    case mobileMeServerError
    case mobileMeServerNotAvailable
    case mobileMeServerAlreadyExists
    case mobileMeServerServiceErr
    case mobileMeRequestAlreadyPending
    case mobileMeNoRequestPending
    case mobileMeCSRVerifyFailure
    case mobileMeFailedConsistencyCheck
    case notInitialized
    case invalidHandleUsage
    case pvcReferentNotFound
    case functionIntegrityFail
    case internalError
    case memoryError
    case invalidData
    case mdsError
    case invalidPointer
    case selfCheckFailed
    case functionFailed
    case moduleManifestVerifyFailed
    case invalidGUID
    case invalidHandle
    case invalidDBList
    case invalidPassthroughID
    case invalidNetworkAddress
    case crlAlreadySigned
    case invalidNumberOfFields
    case verificationFailure
    case unknownTag
    case invalidSignature
    case invalidName
    case invalidCertificateRef
    case invalidCertificateGroup
    case tagNotFound
    case invalidQuery
    case invalidValue
    case callbackFailed
    case aclDeleteFailed
    case aclReplaceFailed
    case aclAddFailed
    case aclChangeFailed
    case invalidAccessCredentials
    case invalidRecord
    case invalidACL
    case invalidSampleValue
    case incompatibleVersion
    case privilegeNotGranted
    case invalidScope
    case pvcAlreadyConfigured
    case invalidPVC
    case emmLoadFailed
    case emmUnloadFailed
    case addinLoadFailed
    case invalidKeyRef
    case invalidKeyHierarchy
    case addinUnloadFailed
    case libraryReferenceNotFound
    case invalidAddinFunctionTable
    case invalidServiceMask
    case moduleNotLoaded
    case invalidSubServiceID
    case attributeNotInContext
    case moduleManagerInitializeFailed
    case moduleManagerNotFound
    case eventNotificationCallbackNotFound
    case inputLengthError
    case outputLengthError
    case privilegeNotSupported
    case deviceError
    case attachHandleBusy
    case notLoggedIn
    case algorithmMismatch
    case keyUsageIncorrect
    case keyBlobTypeIncorrect
    case keyHeaderInconsistent
    case unsupportedKeyFormat
    case unsupportedKeySize
    case invalidKeyUsageMask
    case unsupportedKeyUsageMask
    case invalidKeyAttributeMask
    case unsupportedKeyAttributeMask
    case invalidKeyLabel
    case unsupportedKeyLabel
    case invalidKeyFormat
    case unsupportedVectorOfBuffers
    case invalidInputVector
    case invalidOutputVector
    case invalidContext
    case invalidAlgorithm
    case invalidAttributeKey
    case missingAttributeKey
    case invalidAttributeInitVector
    case missingAttributeInitVector
    case invalidAttributeSalt
    case missingAttributeSalt
    case invalidAttributePadding
    case missingAttributePadding
    case invalidAttributeRandom
    case missingAttributeRandom
    case invalidAttributeSeed
    case missingAttributeSeed
    case invalidAttributePassphrase
    case missingAttributePassphrase
    case invalidAttributeKeyLength
    case missingAttributeKeyLength
    case invalidAttributeBlockSize
    case missingAttributeBlockSize
    case invalidAttributeOutputSize
    case missingAttributeOutputSize
    case invalidAttributeRounds
    case missingAttributeRounds
    case invalidAlgorithmParms
    case missingAlgorithmParms
    case invalidAttributeLabel
    case missingAttributeLabel
    case invalidAttributeKeyType
    case missingAttributeKeyType
    case invalidAttributeMode
    case missingAttributeMode
    case invalidAttributeEffectiveBits
    case missingAttributeEffectiveBits
    case invalidAttributeStartDate
    case missingAttributeStartDate
    case invalidAttributeEndDate
    case missingAttributeEndDate
    case invalidAttributeVersion
    case missingAttributeVersion
    case invalidAttributePrime
    case missingAttributePrime
    case invalidAttributeBase
    case missingAttributeBase
    case invalidAttributeSubprime
    case missingAttributeSubprime
    case invalidAttributeIterationCount
    case missingAttributeIterationCount
    case invalidAttributeDLDBHandle
    case missingAttributeDLDBHandle
    case invalidAttributeAccessCredentials
    case missingAttributeAccessCredentials
    case invalidAttributePublicKeyFormat
    case missingAttributePublicKeyFormat
    case invalidAttributePrivateKeyFormat
    case missingAttributePrivateKeyFormat
    case invalidAttributeSymmetricKeyFormat
    case missingAttributeSymmetricKeyFormat
    case invalidAttributeWrappedKeyFormat
    case missingAttributeWrappedKeyFormat
    case stagedOperationInProgress
    case stagedOperationNotStarted
    case verifyFailed
    case querySizeUnknown
    case blockSizeMismatch
    case publicKeyInconsistent
    case deviceVerifyFailed
    case invalidLoginName
    case alreadyLoggedIn
    case invalidDigestAlgorithm
    case invalidCRLGroup
    case certificateCannotOperate
    case certificateExpired
    case certificateNotValidYet
    case certificateRevoked
    case certificateSuspended
    case insufficientCredentials
    case invalidAction
    case invalidAuthority
    case verifyActionFailed
    case invalidCertAuthority
    case invaldCRLAuthority
    case invalidCRLEncoding
    case invalidCRLType
    case invalidCRL
    case invalidFormType
    case invalidID
    case invalidIdentifier
    case invalidIndex
    case invalidPolicyIdentifiers
    case invalidTimeString
    case invalidReason
    case invalidRequestInputs
    case invalidResponseVector
    case invalidStopOnPolicy
    case invalidTuple
    case multipleValuesUnsupported
    case notTrusted
    case noDefaultAuthority
    case rejectedForm
    case requestLost
    case requestRejected
    case unsupportedAddressType
    case unsupportedService
    case invalidTupleGroup
    case invalidBaseACLs
    case invalidTupleCredendtials
    case invalidEncoding
    case invalidValidityPeriod
    case invalidRequestor
    case requestDescriptor
    case invalidBundleInfo
    case invalidCRLIndex
    case noFieldValues
    case unsupportedFieldFormat
    case unsupportedIndexInfo
    case unsupportedLocality
    case unsupportedNumAttributes
    case unsupportedNumIndexes
    case unsupportedNumRecordTypes
    case fieldSpecifiedMultiple
    case incompatibleFieldFormat
    case invalidParsingModule
    case databaseLocked
    case datastoreIsOpen
    case missingValue
    case unsupportedQueryLimits
    case unsupportedNumSelectionPreds
    case unsupportedOperator
    case invalidDBLocation
    case invalidAccessRequest
    case invalidIndexInfo
    case invalidNewOwner
    case invalidModifyMode
    case missingRequiredExtension
    case extendedKeyUsageNotCritical
    case timestampMissing
    case timestampInvalid
    case timestampNotTrusted
    case timestampServiceNotAvailable
    case timestampBadAlg
    case timestampBadRequest
    case timestampBadDataFormat
    case timestampTimeNotAvailable
    case timestampUnacceptedPolicy
    case timestampUnacceptedExtension
    case timestampAddInfoNotAvailable
    case timestampSystemFailure
    case signingTimeMissing
    case timestampRejection
    case timestampWaiting
    case timestampRevocationWarning
    case timestampRevocationNotification
    case unexpectedError
}

extension Status : RawRepresentable, CustomStringConvertible {
    
    public init?(rawValue: OSStatus) {
        switch rawValue {
        case 0:
            self = .success
        case -4:
            self = .unimplemented
        case -34:
            self = .diskFull
        case -36:
            self = .io
        case -49:
            self = .opWr
        case -50:
            self = .param
        case -61:
            self = .wrPerm
        case -108:
            self = .allocate
        case -128:
            self = .userCanceled
        case -909:
            self = .badReq
        case -2070:
            self = .internalComponent
        case -25291:
            self = .notAvailable
        case -25292:
            self = .readOnly
        case -25293:
            self = .authFailed
        case -25294:
            self = .noSuchKeychain
        case -25295:
            self = .invalidKeychain
        case -25296:
            self = .duplicateKeychain
        case -25297:
            self = .duplicateCallback
        case -25298:
            self = .invalidCallback
        case -25299:
            self = .duplicateItem
        case -25300:
            self = .itemNotFound
        case -25301:
            self = .bufferTooSmall
        case -25302:
            self = .dataTooLarge
        case -25303:
            self = .noSuchAttr
        case -25304:
            self = .invalidItemRef
        case -25305:
            self = .invalidSearchRef
        case -25306:
            self = .noSuchClass
        case -25307:
            self = .noDefaultKeychain
        case -25308:
            self = .interactionNotAllowed
        case -25309:
            self = .readOnlyAttr
        case -25310:
            self = .wrongSecVersion
        case -25311:
            self = .keySizeNotAllowed
        case -25312:
            self = .noStorageModule
        case -25313:
            self = .noCertificateModule
        case -25314:
            self = .noPolicyModule
        case -25315:
            self = .interactionRequired
        case -25316:
            self = .dataNotAvailable
        case -25317:
            self = .dataNotModifiable
        case -25318:
            self = .createChainFailed
        case -25319:
            self = .invalidPrefsDomain
        case -25320:
            self = .inDarkWake
        case -25240:
            self = .aclNotSimple
        case -25241:
            self = .policyNotFound
        case -25242:
            self = .invalidTrustSetting
        case -25243:
            self = .noAccessForItem
        case -25244:
            self = .invalidOwnerEdit
        case -25245:
            self = .trustNotAvailable
        case -25256:
            self = .unsupportedFormat
        case -25257:
            self = .unknownFormat
        case -25258:
            self = .keyIsSensitive
        case -25259:
            self = .multiplePrivKeys
        case -25260:
            self = .passphraseRequired
        case -25261:
            self = .invalidPasswordRef
        case -25262:
            self = .invalidTrustSettings
        case -25263:
            self = .noTrustSettings
        case -25264:
            self = .pkcs12VerifyFailure
        case -26265:
            self = .invalidCertificate
        case -26267:
            self = .notSigner
        case -26270:
            self = .policyDenied
        case -26274:
            self = .invalidKey
        case -26275:
            self = .decode
        case -26276:
            self = .`internal`
        case -26268:
            self = .unsupportedAlgorithm
        case -26271:
            self = .unsupportedOperation
        case -26273:
            self = .unsupportedPadding
        case -34000:
            self = .itemInvalidKey
        case -34001:
            self = .itemInvalidKeyType
        case -34002:
            self = .itemInvalidValue
        case -34003:
            self = .itemClassMissing
        case -34004:
            self = .itemMatchUnsupported
        case -34005:
            self = .useItemListUnsupported
        case -34006:
            self = .useKeychainUnsupported
        case -34007:
            self = .useKeychainListUnsupported
        case -34008:
            self = .returnDataUnsupported
        case -34009:
            self = .returnAttributesUnsupported
        case -34010:
            self = .returnRefUnsupported
        case -34011:
            self = .returnPersitentRefUnsupported
        case -34012:
            self = .valueRefUnsupported
        case -34013:
            self = .valuePersistentRefUnsupported
        case -34014:
            self = .returnMissingPointer
        case -34015:
            self = .matchLimitUnsupported
        case -34016:
            self = .itemIllegalQuery
        case -34017:
            self = .waitForCallback
        case -34018:
            self = .missingEntitlement
        case -34019:
            self = .upgradePending
        case -25327:
            self = .mpSignatureInvalid
        case -25328:
            self = .otrTooOld
        case -25329:
            self = .otridTooNew
        case -67585:
            self = .serviceNotAvailable
        case -67586:
            self = .insufficientClientID
        case -67587:
            self = .deviceReset
        case -67588:
            self = .deviceFailed
        case -67589:
            self = .appleAddAppACLSubject
        case -67590:
            self = .applePublicKeyIncomplete
        case -67591:
            self = .appleSignatureMismatch
        case -67592:
            self = .appleInvalidKeyStartDate
        case -67593:
            self = .appleInvalidKeyEndDate
        case -67594:
            self = .conversionError
        case -67595:
            self = .appleSSLv2Rollback
        case -67596:
            self = .quotaExceeded
        case -67597:
            self = .fileTooBig
        case -67598:
            self = .invalidDatabaseBlob
        case -67599:
            self = .invalidKeyBlob
        case -67600:
            self = .incompatibleDatabaseBlob
        case -67601:
            self = .incompatibleKeyBlob
        case -67602:
            self = .hostNameMismatch
        case -67603:
            self = .unknownCriticalExtensionFlag
        case -67604:
            self = .noBasicConstraints
        case -67605:
            self = .noBasicConstraintsCA
        case -67606:
            self = .invalidAuthorityKeyID
        case -67607:
            self = .invalidSubjectKeyID
        case -67608:
            self = .invalidKeyUsageForPolicy
        case -67609:
            self = .invalidExtendedKeyUsage
        case -67610:
            self = .invalidIDLinkage
        case -67611:
            self = .pathLengthConstraintExceeded
        case -67612:
            self = .invalidRoot
        case -67613:
            self = .crlExpired
        case -67614:
            self = .crlNotValidYet
        case -67615:
            self = .crlNotFound
        case -67616:
            self = .crlServerDown
        case -67617:
            self = .crlBadURI
        case -67618:
            self = .unknownCertExtension
        case -67619:
            self = .unknownCRLExtension
        case -67620:
            self = .crlNotTrusted
        case -67621:
            self = .crlPolicyFailed
        case -67622:
            self = .idpFailure
        case -67623:
            self = .smimeEmailAddressesNotFound
        case -67624:
            self = .smimeBadExtendedKeyUsage
        case -67625:
            self = .smimeBadKeyUsage
        case -67626:
            self = .smimeKeyUsageNotCritical
        case -67627:
            self = .smimeNoEmailAddress
        case -67628:
            self = .smimeSubjAltNameNotCritical
        case -67629:
            self = .sslBadExtendedKeyUsage
        case -67630:
            self = .ocspBadResponse
        case -67631:
            self = .ocspBadRequest
        case -67632:
            self = .ocspUnavailable
        case -67633:
            self = .ocspStatusUnrecognized
        case -67634:
            self = .endOfData
        case -67635:
            self = .incompleteCertRevocationCheck
        case -67636:
            self = .networkFailure
        case -67637:
            self = .ocspNotTrustedToAnchor
        case -67638:
            self = .recordModified
        case -67639:
            self = .ocspSignatureError
        case -67640:
            self = .ocspNoSigner
        case -67641:
            self = .ocspResponderMalformedReq
        case -67642:
            self = .ocspResponderInternalError
        case -67643:
            self = .ocspResponderTryLater
        case -67644:
            self = .ocspResponderSignatureRequired
        case -67645:
            self = .ocspResponderUnauthorized
        case -67646:
            self = .ocspResponseNonceMismatch
        case -67647:
            self = .codeSigningBadCertChainLength
        case -67648:
            self = .codeSigningNoBasicConstraints
        case -67649:
            self = .codeSigningBadPathLengthConstraint
        case -67650:
            self = .codeSigningNoExtendedKeyUsage
        case -67651:
            self = .codeSigningDevelopment
        case -67652:
            self = .resourceSignBadCertChainLength
        case -67653:
            self = .resourceSignBadExtKeyUsage
        case -67654:
            self = .trustSettingDeny
        case -67655:
            self = .invalidSubjectName
        case -67656:
            self = .unknownQualifiedCertStatement
        case -67657:
            self = .mobileMeRequestQueued
        case -67658:
            self = .mobileMeRequestRedirected
        case -67659:
            self = .mobileMeServerError
        case -67660:
            self = .mobileMeServerNotAvailable
        case -67661:
            self = .mobileMeServerAlreadyExists
        case -67662:
            self = .mobileMeServerServiceErr
        case -67663:
            self = .mobileMeRequestAlreadyPending
        case -67664:
            self = .mobileMeNoRequestPending
        case -67665:
            self = .mobileMeCSRVerifyFailure
        case -67666:
            self = .mobileMeFailedConsistencyCheck
        case -67667:
            self = .notInitialized
        case -67668:
            self = .invalidHandleUsage
        case -67669:
            self = .pvcReferentNotFound
        case -67670:
            self = .functionIntegrityFail
        case -67671:
            self = .internalError
        case -67672:
            self = .memoryError
        case -67673:
            self = .invalidData
        case -67674:
            self = .mdsError
        case -67675:
            self = .invalidPointer
        case -67676:
            self = .selfCheckFailed
        case -67677:
            self = .functionFailed
        case -67678:
            self = .moduleManifestVerifyFailed
        case -67679:
            self = .invalidGUID
        case -67680:
            self = .invalidHandle
        case -67681:
            self = .invalidDBList
        case -67682:
            self = .invalidPassthroughID
        case -67683:
            self = .invalidNetworkAddress
        case -67684:
            self = .crlAlreadySigned
        case -67685:
            self = .invalidNumberOfFields
        case -67686:
            self = .verificationFailure
        case -67687:
            self = .unknownTag
        case -67688:
            self = .invalidSignature
        case -67689:
            self = .invalidName
        case -67690:
            self = .invalidCertificateRef
        case -67691:
            self = .invalidCertificateGroup
        case -67692:
            self = .tagNotFound
        case -67693:
            self = .invalidQuery
        case -67694:
            self = .invalidValue
        case -67695:
            self = .callbackFailed
        case -67696:
            self = .aclDeleteFailed
        case -67697:
            self = .aclReplaceFailed
        case -67698:
            self = .aclAddFailed
        case -67699:
            self = .aclChangeFailed
        case -67700:
            self = .invalidAccessCredentials
        case -67701:
            self = .invalidRecord
        case -67702:
            self = .invalidACL
        case -67703:
            self = .invalidSampleValue
        case -67704:
            self = .incompatibleVersion
        case -67705:
            self = .privilegeNotGranted
        case -67706:
            self = .invalidScope
        case -67707:
            self = .pvcAlreadyConfigured
        case -67708:
            self = .invalidPVC
        case -67709:
            self = .emmLoadFailed
        case -67710:
            self = .emmUnloadFailed
        case -67711:
            self = .addinLoadFailed
        case -67712:
            self = .invalidKeyRef
        case -67713:
            self = .invalidKeyHierarchy
        case -67714:
            self = .addinUnloadFailed
        case -67715:
            self = .libraryReferenceNotFound
        case -67716:
            self = .invalidAddinFunctionTable
        case -67717:
            self = .invalidServiceMask
        case -67718:
            self = .moduleNotLoaded
        case -67719:
            self = .invalidSubServiceID
        case -67720:
            self = .attributeNotInContext
        case -67721:
            self = .moduleManagerInitializeFailed
        case -67722:
            self = .moduleManagerNotFound
        case -67723:
            self = .eventNotificationCallbackNotFound
        case -67724:
            self = .inputLengthError
        case -67725:
            self = .outputLengthError
        case -67726:
            self = .privilegeNotSupported
        case -67727:
            self = .deviceError
        case -67728:
            self = .attachHandleBusy
        case -67729:
            self = .notLoggedIn
        case -67730:
            self = .algorithmMismatch
        case -67731:
            self = .keyUsageIncorrect
        case -67732:
            self = .keyBlobTypeIncorrect
        case -67733:
            self = .keyHeaderInconsistent
        case -67734:
            self = .unsupportedKeyFormat
        case -67735:
            self = .unsupportedKeySize
        case -67736:
            self = .invalidKeyUsageMask
        case -67737:
            self = .unsupportedKeyUsageMask
        case -67738:
            self = .invalidKeyAttributeMask
        case -67739:
            self = .unsupportedKeyAttributeMask
        case -67740:
            self = .invalidKeyLabel
        case -67741:
            self = .unsupportedKeyLabel
        case -67742:
            self = .invalidKeyFormat
        case -67743:
            self = .unsupportedVectorOfBuffers
        case -67744:
            self = .invalidInputVector
        case -67745:
            self = .invalidOutputVector
        case -67746:
            self = .invalidContext
        case -67747:
            self = .invalidAlgorithm
        case -67748:
            self = .invalidAttributeKey
        case -67749:
            self = .missingAttributeKey
        case -67750:
            self = .invalidAttributeInitVector
        case -67751:
            self = .missingAttributeInitVector
        case -67752:
            self = .invalidAttributeSalt
        case -67753:
            self = .missingAttributeSalt
        case -67754:
            self = .invalidAttributePadding
        case -67755:
            self = .missingAttributePadding
        case -67756:
            self = .invalidAttributeRandom
        case -67757:
            self = .missingAttributeRandom
        case -67758:
            self = .invalidAttributeSeed
        case -67759:
            self = .missingAttributeSeed
        case -67760:
            self = .invalidAttributePassphrase
        case -67761:
            self = .missingAttributePassphrase
        case -67762:
            self = .invalidAttributeKeyLength
        case -67763:
            self = .missingAttributeKeyLength
        case -67764:
            self = .invalidAttributeBlockSize
        case -67765:
            self = .missingAttributeBlockSize
        case -67766:
            self = .invalidAttributeOutputSize
        case -67767:
            self = .missingAttributeOutputSize
        case -67768:
            self = .invalidAttributeRounds
        case -67769:
            self = .missingAttributeRounds
        case -67770:
            self = .invalidAlgorithmParms
        case -67771:
            self = .missingAlgorithmParms
        case -67772:
            self = .invalidAttributeLabel
        case -67773:
            self = .missingAttributeLabel
        case -67774:
            self = .invalidAttributeKeyType
        case -67775:
            self = .missingAttributeKeyType
        case -67776:
            self = .invalidAttributeMode
        case -67777:
            self = .missingAttributeMode
        case -67778:
            self = .invalidAttributeEffectiveBits
        case -67779:
            self = .missingAttributeEffectiveBits
        case -67780:
            self = .invalidAttributeStartDate
        case -67781:
            self = .missingAttributeStartDate
        case -67782:
            self = .invalidAttributeEndDate
        case -67783:
            self = .missingAttributeEndDate
        case -67784:
            self = .invalidAttributeVersion
        case -67785:
            self = .missingAttributeVersion
        case -67786:
            self = .invalidAttributePrime
        case -67787:
            self = .missingAttributePrime
        case -67788:
            self = .invalidAttributeBase
        case -67789:
            self = .missingAttributeBase
        case -67790:
            self = .invalidAttributeSubprime
        case -67791:
            self = .missingAttributeSubprime
        case -67792:
            self = .invalidAttributeIterationCount
        case -67793:
            self = .missingAttributeIterationCount
        case -67794:
            self = .invalidAttributeDLDBHandle
        case -67795:
            self = .missingAttributeDLDBHandle
        case -67796:
            self = .invalidAttributeAccessCredentials
        case -67797:
            self = .missingAttributeAccessCredentials
        case -67798:
            self = .invalidAttributePublicKeyFormat
        case -67799:
            self = .missingAttributePublicKeyFormat
        case -67800:
            self = .invalidAttributePrivateKeyFormat
        case -67801:
            self = .missingAttributePrivateKeyFormat
        case -67802:
            self = .invalidAttributeSymmetricKeyFormat
        case -67803:
            self = .missingAttributeSymmetricKeyFormat
        case -67804:
            self = .invalidAttributeWrappedKeyFormat
        case -67805:
            self = .missingAttributeWrappedKeyFormat
        case -67806:
            self = .stagedOperationInProgress
        case -67807:
            self = .stagedOperationNotStarted
        case -67808:
            self = .verifyFailed
        case -67809:
            self = .querySizeUnknown
        case -67810:
            self = .blockSizeMismatch
        case -67811:
            self = .publicKeyInconsistent
        case -67812:
            self = .deviceVerifyFailed
        case -67813:
            self = .invalidLoginName
        case -67814:
            self = .alreadyLoggedIn
        case -67815:
            self = .invalidDigestAlgorithm
        case -67816:
            self = .invalidCRLGroup
        case -67817:
            self = .certificateCannotOperate
        case -67818:
            self = .certificateExpired
        case -67819:
            self = .certificateNotValidYet
        case -67820:
            self = .certificateRevoked
        case -67821:
            self = .certificateSuspended
        case -67822:
            self = .insufficientCredentials
        case -67823:
            self = .invalidAction
        case -67824:
            self = .invalidAuthority
        case -67825:
            self = .verifyActionFailed
        case -67826:
            self = .invalidCertAuthority
        case -67827:
            self = .invaldCRLAuthority
        case -67828:
            self = .invalidCRLEncoding
        case -67829:
            self = .invalidCRLType
        case -67830:
            self = .invalidCRL
        case -67831:
            self = .invalidFormType
        case -67832:
            self = .invalidID
        case -67833:
            self = .invalidIdentifier
        case -67834:
            self = .invalidIndex
        case -67835:
            self = .invalidPolicyIdentifiers
        case -67836:
            self = .invalidTimeString
        case -67837:
            self = .invalidReason
        case -67838:
            self = .invalidRequestInputs
        case -67839:
            self = .invalidResponseVector
        case -67840:
            self = .invalidStopOnPolicy
        case -67841:
            self = .invalidTuple
        case -67842:
            self = .multipleValuesUnsupported
        case -67843:
            self = .notTrusted
        case -67844:
            self = .noDefaultAuthority
        case -67845:
            self = .rejectedForm
        case -67846:
            self = .requestLost
        case -67847:
            self = .requestRejected
        case -67848:
            self = .unsupportedAddressType
        case -67849:
            self = .unsupportedService
        case -67850:
            self = .invalidTupleGroup
        case -67851:
            self = .invalidBaseACLs
        case -67852:
            self = .invalidTupleCredendtials
        case -67853:
            self = .invalidEncoding
        case -67854:
            self = .invalidValidityPeriod
        case -67855:
            self = .invalidRequestor
        case -67856:
            self = .requestDescriptor
        case -67857:
            self = .invalidBundleInfo
        case -67858:
            self = .invalidCRLIndex
        case -67859:
            self = .noFieldValues
        case -67860:
            self = .unsupportedFieldFormat
        case -67861:
            self = .unsupportedIndexInfo
        case -67862:
            self = .unsupportedLocality
        case -67863:
            self = .unsupportedNumAttributes
        case -67864:
            self = .unsupportedNumIndexes
        case -67865:
            self = .unsupportedNumRecordTypes
        case -67866:
            self = .fieldSpecifiedMultiple
        case -67867:
            self = .incompatibleFieldFormat
        case -67868:
            self = .invalidParsingModule
        case -67869:
            self = .databaseLocked
        case -67870:
            self = .datastoreIsOpen
        case -67871:
            self = .missingValue
        case -67872:
            self = .unsupportedQueryLimits
        case -67873:
            self = .unsupportedNumSelectionPreds
        case -67874:
            self = .unsupportedOperator
        case -67875:
            self = .invalidDBLocation
        case -67876:
            self = .invalidAccessRequest
        case -67877:
            self = .invalidIndexInfo
        case -67878:
            self = .invalidNewOwner
        case -67879:
            self = .invalidModifyMode
        case -67880:
            self = .missingRequiredExtension
        case -67881:
            self = .extendedKeyUsageNotCritical
        case -67882:
            self = .timestampMissing
        case -67883:
            self = .timestampInvalid
        case -67884:
            self = .timestampNotTrusted
        case -67885:
            self = .timestampServiceNotAvailable
        case -67886:
            self = .timestampBadAlg
        case -67887:
            self = .timestampBadRequest
        case -67888:
            self = .timestampBadDataFormat
        case -67889:
            self = .timestampTimeNotAvailable
        case -67890:
            self = .timestampUnacceptedPolicy
        case -67891:
            self = .timestampUnacceptedExtension
        case -67892:
            self = .timestampAddInfoNotAvailable
        case -67893:
            self = .timestampSystemFailure
        case -67894:
            self = .signingTimeMissing
        case -67895:
            self = .timestampRejection
        case -67896:
            self = .timestampWaiting
        case -67897:
            self = .timestampRevocationWarning
        case -67898:
            self = .timestampRevocationNotification
        default:
            self = .unexpectedError
        }
    }
    
    public var rawValue: OSStatus {
        switch self {
        case .success:
            return 0
        case .unimplemented:
            return -4
        case .diskFull:
            return -34
        case .io:
            return -36
        case .opWr:
            return -49
        case .param:
            return -50
        case .wrPerm:
            return -61
        case .allocate:
            return -108
        case .userCanceled:
            return -128
        case .badReq:
            return -909
        case .internalComponent:
            return -2070
        case .notAvailable:
            return -25291
        case .readOnly:
            return -25292
        case .authFailed:
            return -25293
        case .noSuchKeychain:
            return -25294
        case .invalidKeychain:
            return -25295
        case .duplicateKeychain:
            return -25296
        case .duplicateCallback:
            return -25297
        case .invalidCallback:
            return -25298
        case .duplicateItem:
            return -25299
        case .itemNotFound:
            return -25300
        case .bufferTooSmall:
            return -25301
        case .dataTooLarge:
            return -25302
        case .noSuchAttr:
            return -25303
        case .invalidItemRef:
            return -25304
        case .invalidSearchRef:
            return -25305
        case .noSuchClass:
            return -25306
        case .noDefaultKeychain:
            return -25307
        case .interactionNotAllowed:
            return -25308
        case .readOnlyAttr:
            return -25309
        case .wrongSecVersion:
            return -25310
        case .keySizeNotAllowed:
            return -25311
        case .noStorageModule:
            return -25312
        case .noCertificateModule:
            return -25313
        case .noPolicyModule:
            return -25314
        case .interactionRequired:
            return -25315
        case .dataNotAvailable:
            return -25316
        case .dataNotModifiable:
            return -25317
        case .createChainFailed:
            return -25318
        case .invalidPrefsDomain:
            return -25319
        case .inDarkWake:
            return -25320
        case .aclNotSimple:
            return -25240
        case .policyNotFound:
            return -25241
        case .invalidTrustSetting:
            return -25242
        case .noAccessForItem:
            return -25243
        case .invalidOwnerEdit:
            return -25244
        case .trustNotAvailable:
            return -25245
        case .unsupportedFormat:
            return -25256
        case .unknownFormat:
            return -25257
        case .keyIsSensitive:
            return -25258
        case .multiplePrivKeys:
            return -25259
        case .passphraseRequired:
            return -25260
        case .invalidPasswordRef:
            return -25261
        case .invalidTrustSettings:
            return -25262
        case .noTrustSettings:
            return -25263
        case .pkcs12VerifyFailure:
            return -25264
        case .invalidCertificate:
            return -26265
        case .notSigner:
            return -26267
        case .policyDenied:
            return -26270
        case .invalidKey:
            return -26274
        case .decode:
            return -26275
        case .`internal`:
            return -26276
        case .unsupportedAlgorithm:
            return -26268
        case .unsupportedOperation:
            return -26271
        case .unsupportedPadding:
            return -26273
        case .itemInvalidKey:
            return -34000
        case .itemInvalidKeyType:
            return -34001
        case .itemInvalidValue:
            return -34002
        case .itemClassMissing:
            return -34003
        case .itemMatchUnsupported:
            return -34004
        case .useItemListUnsupported:
            return -34005
        case .useKeychainUnsupported:
            return -34006
        case .useKeychainListUnsupported:
            return -34007
        case .returnDataUnsupported:
            return -34008
        case .returnAttributesUnsupported:
            return -34009
        case .returnRefUnsupported:
            return -34010
        case .returnPersitentRefUnsupported:
            return -34011
        case .valueRefUnsupported:
            return -34012
        case .valuePersistentRefUnsupported:
            return -34013
        case .returnMissingPointer:
            return -34014
        case .matchLimitUnsupported:
            return -34015
        case .itemIllegalQuery:
            return -34016
        case .waitForCallback:
            return -34017
        case .missingEntitlement:
            return -34018
        case .upgradePending:
            return -34019
        case .mpSignatureInvalid:
            return -25327
        case .otrTooOld:
            return -25328
        case .otridTooNew:
            return -25329
        case .serviceNotAvailable:
            return -67585
        case .insufficientClientID:
            return -67586
        case .deviceReset:
            return -67587
        case .deviceFailed:
            return -67588
        case .appleAddAppACLSubject:
            return -67589
        case .applePublicKeyIncomplete:
            return -67590
        case .appleSignatureMismatch:
            return -67591
        case .appleInvalidKeyStartDate:
            return -67592
        case .appleInvalidKeyEndDate:
            return -67593
        case .conversionError:
            return -67594
        case .appleSSLv2Rollback:
            return -67595
        case .quotaExceeded:
            return -67596
        case .fileTooBig:
            return -67597
        case .invalidDatabaseBlob:
            return -67598
        case .invalidKeyBlob:
            return -67599
        case .incompatibleDatabaseBlob:
            return -67600
        case .incompatibleKeyBlob:
            return -67601
        case .hostNameMismatch:
            return -67602
        case .unknownCriticalExtensionFlag:
            return -67603
        case .noBasicConstraints:
            return -67604
        case .noBasicConstraintsCA:
            return -67605
        case .invalidAuthorityKeyID:
            return -67606
        case .invalidSubjectKeyID:
            return -67607
        case .invalidKeyUsageForPolicy:
            return -67608
        case .invalidExtendedKeyUsage:
            return -67609
        case .invalidIDLinkage:
            return -67610
        case .pathLengthConstraintExceeded:
            return -67611
        case .invalidRoot:
            return -67612
        case .crlExpired:
            return -67613
        case .crlNotValidYet:
            return -67614
        case .crlNotFound:
            return -67615
        case .crlServerDown:
            return -67616
        case .crlBadURI:
            return -67617
        case .unknownCertExtension:
            return -67618
        case .unknownCRLExtension:
            return -67619
        case .crlNotTrusted:
            return -67620
        case .crlPolicyFailed:
            return -67621
        case .idpFailure:
            return -67622
        case .smimeEmailAddressesNotFound:
            return -67623
        case .smimeBadExtendedKeyUsage:
            return -67624
        case .smimeBadKeyUsage:
            return -67625
        case .smimeKeyUsageNotCritical:
            return -67626
        case .smimeNoEmailAddress:
            return -67627
        case .smimeSubjAltNameNotCritical:
            return -67628
        case .sslBadExtendedKeyUsage:
            return -67629
        case .ocspBadResponse:
            return -67630
        case .ocspBadRequest:
            return -67631
        case .ocspUnavailable:
            return -67632
        case .ocspStatusUnrecognized:
            return -67633
        case .endOfData:
            return -67634
        case .incompleteCertRevocationCheck:
            return -67635
        case .networkFailure:
            return -67636
        case .ocspNotTrustedToAnchor:
            return -67637
        case .recordModified:
            return -67638
        case .ocspSignatureError:
            return -67639
        case .ocspNoSigner:
            return -67640
        case .ocspResponderMalformedReq:
            return -67641
        case .ocspResponderInternalError:
            return -67642
        case .ocspResponderTryLater:
            return -67643
        case .ocspResponderSignatureRequired:
            return -67644
        case .ocspResponderUnauthorized:
            return -67645
        case .ocspResponseNonceMismatch:
            return -67646
        case .codeSigningBadCertChainLength:
            return -67647
        case .codeSigningNoBasicConstraints:
            return -67648
        case .codeSigningBadPathLengthConstraint:
            return -67649
        case .codeSigningNoExtendedKeyUsage:
            return -67650
        case .codeSigningDevelopment:
            return -67651
        case .resourceSignBadCertChainLength:
            return -67652
        case .resourceSignBadExtKeyUsage:
            return -67653
        case .trustSettingDeny:
            return -67654
        case .invalidSubjectName:
            return -67655
        case .unknownQualifiedCertStatement:
            return -67656
        case .mobileMeRequestQueued:
            return -67657
        case .mobileMeRequestRedirected:
            return -67658
        case .mobileMeServerError:
            return -67659
        case .mobileMeServerNotAvailable:
            return -67660
        case .mobileMeServerAlreadyExists:
            return -67661
        case .mobileMeServerServiceErr:
            return -67662
        case .mobileMeRequestAlreadyPending:
            return -67663
        case .mobileMeNoRequestPending:
            return -67664
        case .mobileMeCSRVerifyFailure:
            return -67665
        case .mobileMeFailedConsistencyCheck:
            return -67666
        case .notInitialized:
            return -67667
        case .invalidHandleUsage:
            return -67668
        case .pvcReferentNotFound:
            return -67669
        case .functionIntegrityFail:
            return -67670
        case .internalError:
            return -67671
        case .memoryError:
            return -67672
        case .invalidData:
            return -67673
        case .mdsError:
            return -67674
        case .invalidPointer:
            return -67675
        case .selfCheckFailed:
            return -67676
        case .functionFailed:
            return -67677
        case .moduleManifestVerifyFailed:
            return -67678
        case .invalidGUID:
            return -67679
        case .invalidHandle:
            return -67680
        case .invalidDBList:
            return -67681
        case .invalidPassthroughID:
            return -67682
        case .invalidNetworkAddress:
            return -67683
        case .crlAlreadySigned:
            return -67684
        case .invalidNumberOfFields:
            return -67685
        case .verificationFailure:
            return -67686
        case .unknownTag:
            return -67687
        case .invalidSignature:
            return -67688
        case .invalidName:
            return -67689
        case .invalidCertificateRef:
            return -67690
        case .invalidCertificateGroup:
            return -67691
        case .tagNotFound:
            return -67692
        case .invalidQuery:
            return -67693
        case .invalidValue:
            return -67694
        case .callbackFailed:
            return -67695
        case .aclDeleteFailed:
            return -67696
        case .aclReplaceFailed:
            return -67697
        case .aclAddFailed:
            return -67698
        case .aclChangeFailed:
            return -67699
        case .invalidAccessCredentials:
            return -67700
        case .invalidRecord:
            return -67701
        case .invalidACL:
            return -67702
        case .invalidSampleValue:
            return -67703
        case .incompatibleVersion:
            return -67704
        case .privilegeNotGranted:
            return -67705
        case .invalidScope:
            return -67706
        case .pvcAlreadyConfigured:
            return -67707
        case .invalidPVC:
            return -67708
        case .emmLoadFailed:
            return -67709
        case .emmUnloadFailed:
            return -67710
        case .addinLoadFailed:
            return -67711
        case .invalidKeyRef:
            return -67712
        case .invalidKeyHierarchy:
            return -67713
        case .addinUnloadFailed:
            return -67714
        case .libraryReferenceNotFound:
            return -67715
        case .invalidAddinFunctionTable:
            return -67716
        case .invalidServiceMask:
            return -67717
        case .moduleNotLoaded:
            return -67718
        case .invalidSubServiceID:
            return -67719
        case .attributeNotInContext:
            return -67720
        case .moduleManagerInitializeFailed:
            return -67721
        case .moduleManagerNotFound:
            return -67722
        case .eventNotificationCallbackNotFound:
            return -67723
        case .inputLengthError:
            return -67724
        case .outputLengthError:
            return -67725
        case .privilegeNotSupported:
            return -67726
        case .deviceError:
            return -67727
        case .attachHandleBusy:
            return -67728
        case .notLoggedIn:
            return -67729
        case .algorithmMismatch:
            return -67730
        case .keyUsageIncorrect:
            return -67731
        case .keyBlobTypeIncorrect:
            return -67732
        case .keyHeaderInconsistent:
            return -67733
        case .unsupportedKeyFormat:
            return -67734
        case .unsupportedKeySize:
            return -67735
        case .invalidKeyUsageMask:
            return -67736
        case .unsupportedKeyUsageMask:
            return -67737
        case .invalidKeyAttributeMask:
            return -67738
        case .unsupportedKeyAttributeMask:
            return -67739
        case .invalidKeyLabel:
            return -67740
        case .unsupportedKeyLabel:
            return -67741
        case .invalidKeyFormat:
            return -67742
        case .unsupportedVectorOfBuffers:
            return -67743
        case .invalidInputVector:
            return -67744
        case .invalidOutputVector:
            return -67745
        case .invalidContext:
            return -67746
        case .invalidAlgorithm:
            return -67747
        case .invalidAttributeKey:
            return -67748
        case .missingAttributeKey:
            return -67749
        case .invalidAttributeInitVector:
            return -67750
        case .missingAttributeInitVector:
            return -67751
        case .invalidAttributeSalt:
            return -67752
        case .missingAttributeSalt:
            return -67753
        case .invalidAttributePadding:
            return -67754
        case .missingAttributePadding:
            return -67755
        case .invalidAttributeRandom:
            return -67756
        case .missingAttributeRandom:
            return -67757
        case .invalidAttributeSeed:
            return -67758
        case .missingAttributeSeed:
            return -67759
        case .invalidAttributePassphrase:
            return -67760
        case .missingAttributePassphrase:
            return -67761
        case .invalidAttributeKeyLength:
            return -67762
        case .missingAttributeKeyLength:
            return -67763
        case .invalidAttributeBlockSize:
            return -67764
        case .missingAttributeBlockSize:
            return -67765
        case .invalidAttributeOutputSize:
            return -67766
        case .missingAttributeOutputSize:
            return -67767
        case .invalidAttributeRounds:
            return -67768
        case .missingAttributeRounds:
            return -67769
        case .invalidAlgorithmParms:
            return -67770
        case .missingAlgorithmParms:
            return -67771
        case .invalidAttributeLabel:
            return -67772
        case .missingAttributeLabel:
            return -67773
        case .invalidAttributeKeyType:
            return -67774
        case .missingAttributeKeyType:
            return -67775
        case .invalidAttributeMode:
            return -67776
        case .missingAttributeMode:
            return -67777
        case .invalidAttributeEffectiveBits:
            return -67778
        case .missingAttributeEffectiveBits:
            return -67779
        case .invalidAttributeStartDate:
            return -67780
        case .missingAttributeStartDate:
            return -67781
        case .invalidAttributeEndDate:
            return -67782
        case .missingAttributeEndDate:
            return -67783
        case .invalidAttributeVersion:
            return -67784
        case .missingAttributeVersion:
            return -67785
        case .invalidAttributePrime:
            return -67786
        case .missingAttributePrime:
            return -67787
        case .invalidAttributeBase:
            return -67788
        case .missingAttributeBase:
            return -67789
        case .invalidAttributeSubprime:
            return -67790
        case .missingAttributeSubprime:
            return -67791
        case .invalidAttributeIterationCount:
            return -67792
        case .missingAttributeIterationCount:
            return -67793
        case .invalidAttributeDLDBHandle:
            return -67794
        case .missingAttributeDLDBHandle:
            return -67795
        case .invalidAttributeAccessCredentials:
            return -67796
        case .missingAttributeAccessCredentials:
            return -67797
        case .invalidAttributePublicKeyFormat:
            return -67798
        case .missingAttributePublicKeyFormat:
            return -67799
        case .invalidAttributePrivateKeyFormat:
            return -67800
        case .missingAttributePrivateKeyFormat:
            return -67801
        case .invalidAttributeSymmetricKeyFormat:
            return -67802
        case .missingAttributeSymmetricKeyFormat:
            return -67803
        case .invalidAttributeWrappedKeyFormat:
            return -67804
        case .missingAttributeWrappedKeyFormat:
            return -67805
        case .stagedOperationInProgress:
            return -67806
        case .stagedOperationNotStarted:
            return -67807
        case .verifyFailed:
            return -67808
        case .querySizeUnknown:
            return -67809
        case .blockSizeMismatch:
            return -67810
        case .publicKeyInconsistent:
            return -67811
        case .deviceVerifyFailed:
            return -67812
        case .invalidLoginName:
            return -67813
        case .alreadyLoggedIn:
            return -67814
        case .invalidDigestAlgorithm:
            return -67815
        case .invalidCRLGroup:
            return -67816
        case .certificateCannotOperate:
            return -67817
        case .certificateExpired:
            return -67818
        case .certificateNotValidYet:
            return -67819
        case .certificateRevoked:
            return -67820
        case .certificateSuspended:
            return -67821
        case .insufficientCredentials:
            return -67822
        case .invalidAction:
            return -67823
        case .invalidAuthority:
            return -67824
        case .verifyActionFailed:
            return -67825
        case .invalidCertAuthority:
            return -67826
        case .invaldCRLAuthority:
            return -67827
        case .invalidCRLEncoding:
            return -67828
        case .invalidCRLType:
            return -67829
        case .invalidCRL:
            return -67830
        case .invalidFormType:
            return -67831
        case .invalidID:
            return -67832
        case .invalidIdentifier:
            return -67833
        case .invalidIndex:
            return -67834
        case .invalidPolicyIdentifiers:
            return -67835
        case .invalidTimeString:
            return -67836
        case .invalidReason:
            return -67837
        case .invalidRequestInputs:
            return -67838
        case .invalidResponseVector:
            return -67839
        case .invalidStopOnPolicy:
            return -67840
        case .invalidTuple:
            return -67841
        case .multipleValuesUnsupported:
            return -67842
        case .notTrusted:
            return -67843
        case .noDefaultAuthority:
            return -67844
        case .rejectedForm:
            return -67845
        case .requestLost:
            return -67846
        case .requestRejected:
            return -67847
        case .unsupportedAddressType:
            return -67848
        case .unsupportedService:
            return -67849
        case .invalidTupleGroup:
            return -67850
        case .invalidBaseACLs:
            return -67851
        case .invalidTupleCredendtials:
            return -67852
        case .invalidEncoding:
            return -67853
        case .invalidValidityPeriod:
            return -67854
        case .invalidRequestor:
            return -67855
        case .requestDescriptor:
            return -67856
        case .invalidBundleInfo:
            return -67857
        case .invalidCRLIndex:
            return -67858
        case .noFieldValues:
            return -67859
        case .unsupportedFieldFormat:
            return -67860
        case .unsupportedIndexInfo:
            return -67861
        case .unsupportedLocality:
            return -67862
        case .unsupportedNumAttributes:
            return -67863
        case .unsupportedNumIndexes:
            return -67864
        case .unsupportedNumRecordTypes:
            return -67865
        case .fieldSpecifiedMultiple:
            return -67866
        case .incompatibleFieldFormat:
            return -67867
        case .invalidParsingModule:
            return -67868
        case .databaseLocked:
            return -67869
        case .datastoreIsOpen:
            return -67870
        case .missingValue:
            return -67871
        case .unsupportedQueryLimits:
            return -67872
        case .unsupportedNumSelectionPreds:
            return -67873
        case .unsupportedOperator:
            return -67874
        case .invalidDBLocation:
            return -67875
        case .invalidAccessRequest:
            return -67876
        case .invalidIndexInfo:
            return -67877
        case .invalidNewOwner:
            return -67878
        case .invalidModifyMode:
            return -67879
        case .missingRequiredExtension:
            return -67880
        case .extendedKeyUsageNotCritical:
            return -67881
        case .timestampMissing:
            return -67882
        case .timestampInvalid:
            return -67883
        case .timestampNotTrusted:
            return -67884
        case .timestampServiceNotAvailable:
            return -67885
        case .timestampBadAlg:
            return -67886
        case .timestampBadRequest:
            return -67887
        case .timestampBadDataFormat:
            return -67888
        case .timestampTimeNotAvailable:
            return -67889
        case .timestampUnacceptedPolicy:
            return -67890
        case .timestampUnacceptedExtension:
            return -67891
        case .timestampAddInfoNotAvailable:
            return -67892
        case .timestampSystemFailure:
            return -67893
        case .signingTimeMissing:
            return -67894
        case .timestampRejection:
            return -67895
        case .timestampWaiting:
            return -67896
        case .timestampRevocationWarning:
            return -67897
        case .timestampRevocationNotification:
            return -67898
        default:
            return -99999
        }
    }
    
    public var description : String {
        switch self {
        case .success:
            return "No error."
        case .unimplemented:
            return "Function or operation not implemented."
        case .diskFull:
            return "The disk is full."
        case .io:
            return "I/O error (bummers)"
        case .opWr:
            return "file already open with with write permission"
        case .param:
            return "One or more parameters passed to a function were not valid."
        case .wrPerm:
            return "write permissions error"
        case .allocate:
            return "Failed to allocate memory."
        case .userCanceled:
            return "User canceled the operation."
        case .badReq:
            return "Bad parameter or invalid state for operation."
        case .internalComponent:
            return ""
        case .notAvailable:
            return "No keychain is available. You may need to restart your computer."
        case .readOnly:
            return "This keychain cannot be modified."
        case .authFailed:
            return "The user name or passphrase you entered is not correct."
        case .noSuchKeychain:
            return "The specified keychain could not be found."
        case .invalidKeychain:
            return "The specified keychain is not a valid keychain file."
        case .duplicateKeychain:
            return "A keychain with the same name already exists."
        case .duplicateCallback:
            return "The specified callback function is already installed."
        case .invalidCallback:
            return "The specified callback function is not valid."
        case .duplicateItem:
            return "The specified item already exists in the keychain."
        case .itemNotFound:
            return "The specified item could not be found in the keychain."
        case .bufferTooSmall:
            return "There is not enough memory available to use the specified item."
        case .dataTooLarge:
            return "This item contains information which is too large or in a format that cannot be displayed."
        case .noSuchAttr:
            return "The specified attribute does not exist."
        case .invalidItemRef:
            return "The specified item is no longer valid. It may have been deleted from the keychain."
        case .invalidSearchRef:
            return "Unable to search the current keychain."
        case .noSuchClass:
            return "The specified item does not appear to be a valid keychain item."
        case .noDefaultKeychain:
            return "A default keychain could not be found."
        case .interactionNotAllowed:
            return "User interaction is not allowed."
        case .readOnlyAttr:
            return "The specified attribute could not be modified."
        case .wrongSecVersion:
            return "This keychain was created by a different version of the system software and cannot be opened."
        case .keySizeNotAllowed:
            return "This item specifies a key size which is too large."
        case .noStorageModule:
            return "A required component (data storage module) could not be loaded. You may need to restart your computer."
        case .noCertificateModule:
            return "A required component (certificate module) could not be loaded. You may need to restart your computer."
        case .noPolicyModule:
            return "A required component (policy module) could not be loaded. You may need to restart your computer."
        case .interactionRequired:
            return "User interaction is required, but is currently not allowed."
        case .dataNotAvailable:
            return "The contents of this item cannot be retrieved."
        case .dataNotModifiable:
            return "The contents of this item cannot be modified."
        case .createChainFailed:
            return "One or more certificates required to validate this certificate cannot be found."
        case .invalidPrefsDomain:
            return "The specified preferences domain is not valid."
        case .inDarkWake:
            return "In dark wake, no UI possible"
        case .aclNotSimple:
            return "The specified access control list is not in standard (simple) form."
        case .policyNotFound:
            return "The specified policy cannot be found."
        case .invalidTrustSetting:
            return "The specified trust setting is invalid."
        case .noAccessForItem:
            return "The specified item has no access control."
        case .invalidOwnerEdit:
            return "Invalid attempt to change the owner of this item."
        case .trustNotAvailable:
            return "No trust results are available."
        case .unsupportedFormat:
            return "Import/Export format unsupported."
        case .unknownFormat:
            return "Unknown format in import."
        case .keyIsSensitive:
            return "Key material must be wrapped for export."
        case .multiplePrivKeys:
            return "An attempt was made to import multiple private keys."
        case .passphraseRequired:
            return "Passphrase is required for import/export."
        case .invalidPasswordRef:
            return "The password reference was invalid."
        case .invalidTrustSettings:
            return "The Trust Settings Record was corrupted."
        case .noTrustSettings:
            return "No Trust Settings were found."
        case .pkcs12VerifyFailure:
            return "MAC verification failed during PKCS12 import (wrong password?)"
        case .invalidCertificate:
            return "This certificate could not be decoded."
        case .notSigner:
            return "A certificate was not signed by its proposed parent."
        case .policyDenied:
            return "The certificate chain was not trusted due to a policy not accepting it."
        case .invalidKey:
            return "The provided key material was not valid."
        case .decode:
            return "Unable to decode the provided data."
        case .`internal`:
            return "An internal error occured in the Security framework."
        case .unsupportedAlgorithm:
            return "An unsupported algorithm was encountered."
        case .unsupportedOperation:
            return "The operation you requested is not supported by this key."
        case .unsupportedPadding:
            return "The padding you requested is not supported."
        case .itemInvalidKey:
            return "A string key in dictionary is not one of the supported keys."
        case .itemInvalidKeyType:
            return "A key in a dictionary is neither a CFStringRef nor a CFNumberRef."
        case .itemInvalidValue:
            return "A value in a dictionary is an invalid (or unsupported) CF type."
        case .itemClassMissing:
            return "No kSecItemClass key was specified in a dictionary."
        case .itemMatchUnsupported:
            return "The caller passed one or more kSecMatch keys to a function which does not support matches."
        case .useItemListUnsupported:
            return "The caller passed in a kSecUseItemList key to a function which does not support it."
        case .useKeychainUnsupported:
            return "The caller passed in a kSecUseKeychain key to a function which does not support it."
        case .useKeychainListUnsupported:
            return "The caller passed in a kSecUseKeychainList key to a function which does not support it."
        case .returnDataUnsupported:
            return "The caller passed in a kSecReturnData key to a function which does not support it."
        case .returnAttributesUnsupported:
            return "The caller passed in a kSecReturnAttributes key to a function which does not support it."
        case .returnRefUnsupported:
            return "The caller passed in a kSecReturnRef key to a function which does not support it."
        case .returnPersitentRefUnsupported:
            return "The caller passed in a kSecReturnPersistentRef key to a function which does not support it."
        case .valueRefUnsupported:
            return "The caller passed in a kSecValueRef key to a function which does not support it."
        case .valuePersistentRefUnsupported:
            return "The caller passed in a kSecValuePersistentRef key to a function which does not support it."
        case .returnMissingPointer:
            return "The caller passed asked for something to be returned but did not pass in a result pointer."
        case .matchLimitUnsupported:
            return "The caller passed in a kSecMatchLimit key to a call which does not support limits."
        case .itemIllegalQuery:
            return "The caller passed in a query which contained too many keys."
        case .waitForCallback:
            return "This operation is incomplete, until the callback is invoked (not an error)."
        case .missingEntitlement:
            return "Internal error when a required entitlement isn't present, client has neither application-identifier nor keychain-access-groups entitlements."
        case .upgradePending:
            return "Error returned if keychain database needs a schema migration but the device is locked, clients should wait for a device unlock notification and retry the command."
        case .mpSignatureInvalid:
            return "Signature invalid on MP message"
        case .otrTooOld:
            return "Message is too old to use"
        case .otridTooNew:
            return "Key ID is too new to use! Message from the future?"
        case .serviceNotAvailable:
            return "The required service is not available."
        case .insufficientClientID:
            return "The client ID is not correct."
        case .deviceReset:
            return "A device reset has occurred."
        case .deviceFailed:
            return "A device failure has occurred."
        case .appleAddAppACLSubject:
            return "Adding an application ACL subject failed."
        case .applePublicKeyIncomplete:
            return "The public key is incomplete."
        case .appleSignatureMismatch:
            return "A signature mismatch has occurred."
        case .appleInvalidKeyStartDate:
            return "The specified key has an invalid start date."
        case .appleInvalidKeyEndDate:
            return "The specified key has an invalid end date."
        case .conversionError:
            return "A conversion error has occurred."
        case .appleSSLv2Rollback:
            return "A SSLv2 rollback error has occurred."
        case .quotaExceeded:
            return "The quota was exceeded."
        case .fileTooBig:
            return "The file is too big."
        case .invalidDatabaseBlob:
            return "The specified database has an invalid blob."
        case .invalidKeyBlob:
            return "The specified database has an invalid key blob."
        case .incompatibleDatabaseBlob:
            return "The specified database has an incompatible blob."
        case .incompatibleKeyBlob:
            return "The specified database has an incompatible key blob."
        case .hostNameMismatch:
            return "A host name mismatch has occurred."
        case .unknownCriticalExtensionFlag:
            return "There is an unknown critical extension flag."
        case .noBasicConstraints:
            return "No basic constraints were found."
        case .noBasicConstraintsCA:
            return "No basic CA constraints were found."
        case .invalidAuthorityKeyID:
            return "The authority key ID is not valid."
        case .invalidSubjectKeyID:
            return "The subject key ID is not valid."
        case .invalidKeyUsageForPolicy:
            return "The key usage is not valid for the specified policy."
        case .invalidExtendedKeyUsage:
            return "The extended key usage is not valid."
        case .invalidIDLinkage:
            return "The ID linkage is not valid."
        case .pathLengthConstraintExceeded:
            return "The path length constraint was exceeded."
        case .invalidRoot:
            return "The root or anchor certificate is not valid."
        case .crlExpired:
            return "The CRL has expired."
        case .crlNotValidYet:
            return "The CRL is not yet valid."
        case .crlNotFound:
            return "The CRL was not found."
        case .crlServerDown:
            return "The CRL server is down."
        case .crlBadURI:
            return "The CRL has a bad Uniform Resource Identifier."
        case .unknownCertExtension:
            return "An unknown certificate extension was encountered."
        case .unknownCRLExtension:
            return "An unknown CRL extension was encountered."
        case .crlNotTrusted:
            return "The CRL is not trusted."
        case .crlPolicyFailed:
            return "The CRL policy failed."
        case .idpFailure:
            return "The issuing distribution point was not valid."
        case .smimeEmailAddressesNotFound:
            return "An email address mismatch was encountered."
        case .smimeBadExtendedKeyUsage:
            return "The appropriate extended key usage for SMIME was not found."
        case .smimeBadKeyUsage:
            return "The key usage is not compatible with SMIME."
        case .smimeKeyUsageNotCritical:
            return "The key usage extension is not marked as critical."
        case .smimeNoEmailAddress:
            return "No email address was found in the certificate."
        case .smimeSubjAltNameNotCritical:
            return "The subject alternative name extension is not marked as critical."
        case .sslBadExtendedKeyUsage:
            return "The appropriate extended key usage for SSL was not found."
        case .ocspBadResponse:
            return "The OCSP response was incorrect or could not be parsed."
        case .ocspBadRequest:
            return "The OCSP request was incorrect or could not be parsed."
        case .ocspUnavailable:
            return "OCSP service is unavailable."
        case .ocspStatusUnrecognized:
            return "The OCSP server did not recognize this certificate."
        case .endOfData:
            return "An end-of-data was detected."
        case .incompleteCertRevocationCheck:
            return "An incomplete certificate revocation check occurred."
        case .networkFailure:
            return "A network failure occurred."
        case .ocspNotTrustedToAnchor:
            return "The OCSP response was not trusted to a root or anchor certificate."
        case .recordModified:
            return "The record was modified."
        case .ocspSignatureError:
            return "The OCSP response had an invalid signature."
        case .ocspNoSigner:
            return "The OCSP response had no signer."
        case .ocspResponderMalformedReq:
            return "The OCSP responder was given a malformed request."
        case .ocspResponderInternalError:
            return "The OCSP responder encountered an internal error."
        case .ocspResponderTryLater:
            return "The OCSP responder is busy, try again later."
        case .ocspResponderSignatureRequired:
            return "The OCSP responder requires a signature."
        case .ocspResponderUnauthorized:
            return "The OCSP responder rejected this request as unauthorized."
        case .ocspResponseNonceMismatch:
            return "The OCSP response nonce did not match the request."
        case .codeSigningBadCertChainLength:
            return "Code signing encountered an incorrect certificate chain length."
        case .codeSigningNoBasicConstraints:
            return "Code signing found no basic constraints."
        case .codeSigningBadPathLengthConstraint:
            return "Code signing encountered an incorrect path length constraint."
        case .codeSigningNoExtendedKeyUsage:
            return "Code signing found no extended key usage."
        case .codeSigningDevelopment:
            return "Code signing indicated use of a development-only certificate."
        case .resourceSignBadCertChainLength:
            return "Resource signing has encountered an incorrect certificate chain length."
        case .resourceSignBadExtKeyUsage:
            return "Resource signing has encountered an error in the extended key usage."
        case .trustSettingDeny:
            return "The trust setting for this policy was set to Deny."
        case .invalidSubjectName:
            return "An invalid certificate subject name was encountered."
        case .unknownQualifiedCertStatement:
            return "An unknown qualified certificate statement was encountered."
        case .mobileMeRequestQueued:
            return "The MobileMe request will be sent during the next connection."
        case .mobileMeRequestRedirected:
            return "The MobileMe request was redirected."
        case .mobileMeServerError:
            return "A MobileMe server error occurred."
        case .mobileMeServerNotAvailable:
            return "The MobileMe server is not available."
        case .mobileMeServerAlreadyExists:
            return "The MobileMe server reported that the item already exists."
        case .mobileMeServerServiceErr:
            return "A MobileMe service error has occurred."
        case .mobileMeRequestAlreadyPending:
            return "A MobileMe request is already pending."
        case .mobileMeNoRequestPending:
            return "MobileMe has no request pending."
        case .mobileMeCSRVerifyFailure:
            return "A MobileMe CSR verification failure has occurred."
        case .mobileMeFailedConsistencyCheck:
            return "MobileMe has found a failed consistency check."
        case .notInitialized:
            return "A function was called without initializing CSSM."
        case .invalidHandleUsage:
            return "The CSSM handle does not match with the service type."
        case .pvcReferentNotFound:
            return "A reference to the calling module was not found in the list of authorized callers."
        case .functionIntegrityFail:
            return "A function address was not within the verified module."
        case .internalError:
            return "An internal error has occurred."
        case .memoryError:
            return "A memory error has occurred."
        case .invalidData:
            return "Invalid data was encountered."
        case .mdsError:
            return "A Module Directory Service error has occurred."
        case .invalidPointer:
            return "An invalid pointer was encountered."
        case .selfCheckFailed:
            return "Self-check has failed."
        case .functionFailed:
            return "A function has failed."
        case .moduleManifestVerifyFailed:
            return "A module manifest verification failure has occurred."
        case .invalidGUID:
            return "An invalid GUID was encountered."
        case .invalidHandle:
            return "An invalid handle was encountered."
        case .invalidDBList:
            return "An invalid DB list was encountered."
        case .invalidPassthroughID:
            return "An invalid passthrough ID was encountered."
        case .invalidNetworkAddress:
            return "An invalid network address was encountered."
        case .crlAlreadySigned:
            return "The certificate revocation list is already signed."
        case .invalidNumberOfFields:
            return "An invalid number of fields were encountered."
        case .verificationFailure:
            return "A verification failure occurred."
        case .unknownTag:
            return "An unknown tag was encountered."
        case .invalidSignature:
            return "An invalid signature was encountered."
        case .invalidName:
            return "An invalid name was encountered."
        case .invalidCertificateRef:
            return "An invalid certificate reference was encountered."
        case .invalidCertificateGroup:
            return "An invalid certificate group was encountered."
        case .tagNotFound:
            return "The specified tag was not found."
        case .invalidQuery:
            return "The specified query was not valid."
        case .invalidValue:
            return "An invalid value was detected."
        case .callbackFailed:
            return "A callback has failed."
        case .aclDeleteFailed:
            return "An ACL delete operation has failed."
        case .aclReplaceFailed:
            return "An ACL replace operation has failed."
        case .aclAddFailed:
            return "An ACL add operation has failed."
        case .aclChangeFailed:
            return "An ACL change operation has failed."
        case .invalidAccessCredentials:
            return "Invalid access credentials were encountered."
        case .invalidRecord:
            return "An invalid record was encountered."
        case .invalidACL:
            return "An invalid ACL was encountered."
        case .invalidSampleValue:
            return "An invalid sample value was encountered."
        case .incompatibleVersion:
            return "An incompatible version was encountered."
        case .privilegeNotGranted:
            return "The privilege was not granted."
        case .invalidScope:
            return "An invalid scope was encountered."
        case .pvcAlreadyConfigured:
            return "The PVC is already configured."
        case .invalidPVC:
            return "An invalid PVC was encountered."
        case .emmLoadFailed:
            return "The EMM load has failed."
        case .emmUnloadFailed:
            return "The EMM unload has failed."
        case .addinLoadFailed:
            return "The add-in load operation has failed."
        case .invalidKeyRef:
            return "An invalid key was encountered."
        case .invalidKeyHierarchy:
            return "An invalid key hierarchy was encountered."
        case .addinUnloadFailed:
            return "The add-in unload operation has failed."
        case .libraryReferenceNotFound:
            return "A library reference was not found."
        case .invalidAddinFunctionTable:
            return "An invalid add-in function table was encountered."
        case .invalidServiceMask:
            return "An invalid service mask was encountered."
        case .moduleNotLoaded:
            return "A module was not loaded."
        case .invalidSubServiceID:
            return "An invalid subservice ID was encountered."
        case .attributeNotInContext:
            return "An attribute was not in the context."
        case .moduleManagerInitializeFailed:
            return "A module failed to initialize."
        case .moduleManagerNotFound:
            return "A module was not found."
        case .eventNotificationCallbackNotFound:
            return "An event notification callback was not found."
        case .inputLengthError:
            return "An input length error was encountered."
        case .outputLengthError:
            return "An output length error was encountered."
        case .privilegeNotSupported:
            return "The privilege is not supported."
        case .deviceError:
            return "A device error was encountered."
        case .attachHandleBusy:
            return "The CSP handle was busy."
        case .notLoggedIn:
            return "You are not logged in."
        case .algorithmMismatch:
            return "An algorithm mismatch was encountered."
        case .keyUsageIncorrect:
            return "The key usage is incorrect."
        case .keyBlobTypeIncorrect:
            return "The key blob type is incorrect."
        case .keyHeaderInconsistent:
            return "The key header is inconsistent."
        case .unsupportedKeyFormat:
            return "The key header format is not supported."
        case .unsupportedKeySize:
            return "The key size is not supported."
        case .invalidKeyUsageMask:
            return "The key usage mask is not valid."
        case .unsupportedKeyUsageMask:
            return "The key usage mask is not supported."
        case .invalidKeyAttributeMask:
            return "The key attribute mask is not valid."
        case .unsupportedKeyAttributeMask:
            return "The key attribute mask is not supported."
        case .invalidKeyLabel:
            return "The key label is not valid."
        case .unsupportedKeyLabel:
            return "The key label is not supported."
        case .invalidKeyFormat:
            return "The key format is not valid."
        case .unsupportedVectorOfBuffers:
            return "The vector of buffers is not supported."
        case .invalidInputVector:
            return "The input vector is not valid."
        case .invalidOutputVector:
            return "The output vector is not valid."
        case .invalidContext:
            return "An invalid context was encountered."
        case .invalidAlgorithm:
            return "An invalid algorithm was encountered."
        case .invalidAttributeKey:
            return "A key attribute was not valid."
        case .missingAttributeKey:
            return "A key attribute was missing."
        case .invalidAttributeInitVector:
            return "An init vector attribute was not valid."
        case .missingAttributeInitVector:
            return "An init vector attribute was missing."
        case .invalidAttributeSalt:
            return "A salt attribute was not valid."
        case .missingAttributeSalt:
            return "A salt attribute was missing."
        case .invalidAttributePadding:
            return "A padding attribute was not valid."
        case .missingAttributePadding:
            return "A padding attribute was missing."
        case .invalidAttributeRandom:
            return "A random number attribute was not valid."
        case .missingAttributeRandom:
            return "A random number attribute was missing."
        case .invalidAttributeSeed:
            return "A seed attribute was not valid."
        case .missingAttributeSeed:
            return "A seed attribute was missing."
        case .invalidAttributePassphrase:
            return "A passphrase attribute was not valid."
        case .missingAttributePassphrase:
            return "A passphrase attribute was missing."
        case .invalidAttributeKeyLength:
            return "A key length attribute was not valid."
        case .missingAttributeKeyLength:
            return "A key length attribute was missing."
        case .invalidAttributeBlockSize:
            return "A block size attribute was not valid."
        case .missingAttributeBlockSize:
            return "A block size attribute was missing."
        case .invalidAttributeOutputSize:
            return "An output size attribute was not valid."
        case .missingAttributeOutputSize:
            return "An output size attribute was missing."
        case .invalidAttributeRounds:
            return "The number of rounds attribute was not valid."
        case .missingAttributeRounds:
            return "The number of rounds attribute was missing."
        case .invalidAlgorithmParms:
            return "An algorithm parameters attribute was not valid."
        case .missingAlgorithmParms:
            return "An algorithm parameters attribute was missing."
        case .invalidAttributeLabel:
            return "A label attribute was not valid."
        case .missingAttributeLabel:
            return "A label attribute was missing."
        case .invalidAttributeKeyType:
            return "A key type attribute was not valid."
        case .missingAttributeKeyType:
            return "A key type attribute was missing."
        case .invalidAttributeMode:
            return "A mode attribute was not valid."
        case .missingAttributeMode:
            return "A mode attribute was missing."
        case .invalidAttributeEffectiveBits:
            return "An effective bits attribute was not valid."
        case .missingAttributeEffectiveBits:
            return "An effective bits attribute was missing."
        case .invalidAttributeStartDate:
            return "A start date attribute was not valid."
        case .missingAttributeStartDate:
            return "A start date attribute was missing."
        case .invalidAttributeEndDate:
            return "An end date attribute was not valid."
        case .missingAttributeEndDate:
            return "An end date attribute was missing."
        case .invalidAttributeVersion:
            return "A version attribute was not valid."
        case .missingAttributeVersion:
            return "A version attribute was missing."
        case .invalidAttributePrime:
            return "A prime attribute was not valid."
        case .missingAttributePrime:
            return "A prime attribute was missing."
        case .invalidAttributeBase:
            return "A base attribute was not valid."
        case .missingAttributeBase:
            return "A base attribute was missing."
        case .invalidAttributeSubprime:
            return "A subprime attribute was not valid."
        case .missingAttributeSubprime:
            return "A subprime attribute was missing."
        case .invalidAttributeIterationCount:
            return "An iteration count attribute was not valid."
        case .missingAttributeIterationCount:
            return "An iteration count attribute was missing."
        case .invalidAttributeDLDBHandle:
            return "A database handle attribute was not valid."
        case .missingAttributeDLDBHandle:
            return "A database handle attribute was missing."
        case .invalidAttributeAccessCredentials:
            return "An access credentials attribute was not valid."
        case .missingAttributeAccessCredentials:
            return "An access credentials attribute was missing."
        case .invalidAttributePublicKeyFormat:
            return "A public key format attribute was not valid."
        case .missingAttributePublicKeyFormat:
            return "A public key format attribute was missing."
        case .invalidAttributePrivateKeyFormat:
            return "A private key format attribute was not valid."
        case .missingAttributePrivateKeyFormat:
            return "A private key format attribute was missing."
        case .invalidAttributeSymmetricKeyFormat:
            return "A symmetric key format attribute was not valid."
        case .missingAttributeSymmetricKeyFormat:
            return "A symmetric key format attribute was missing."
        case .invalidAttributeWrappedKeyFormat:
            return "A wrapped key format attribute was not valid."
        case .missingAttributeWrappedKeyFormat:
            return "A wrapped key format attribute was missing."
        case .stagedOperationInProgress:
            return "A staged operation is in progress."
        case .stagedOperationNotStarted:
            return "A staged operation was not started."
        case .verifyFailed:
            return "A cryptographic verification failure has occurred."
        case .querySizeUnknown:
            return "The query size is unknown."
        case .blockSizeMismatch:
            return "A block size mismatch occurred."
        case .publicKeyInconsistent:
            return "The public key was inconsistent."
        case .deviceVerifyFailed:
            return "A device verification failure has occurred."
        case .invalidLoginName:
            return "An invalid login name was detected."
        case .alreadyLoggedIn:
            return "The user is already logged in."
        case .invalidDigestAlgorithm:
            return "An invalid digest algorithm was detected."
        case .invalidCRLGroup:
            return "An invalid CRL group was detected."
        case .certificateCannotOperate:
            return "The certificate cannot operate."
        case .certificateExpired:
            return "An expired certificate was detected."
        case .certificateNotValidYet:
            return "The certificate is not yet valid."
        case .certificateRevoked:
            return "The certificate was revoked."
        case .certificateSuspended:
            return "The certificate was suspended."
        case .insufficientCredentials:
            return "Insufficient credentials were detected."
        case .invalidAction:
            return "The action was not valid."
        case .invalidAuthority:
            return "The authority was not valid."
        case .verifyActionFailed:
            return "A verify action has failed."
        case .invalidCertAuthority:
            return "The certificate authority was not valid."
        case .invaldCRLAuthority:
            return "The CRL authority was not valid."
        case .invalidCRLEncoding:
            return "The CRL encoding was not valid."
        case .invalidCRLType:
            return "The CRL type was not valid."
        case .invalidCRL:
            return "The CRL was not valid."
        case .invalidFormType:
            return "The form type was not valid."
        case .invalidID:
            return "The ID was not valid."
        case .invalidIdentifier:
            return "The identifier was not valid."
        case .invalidIndex:
            return "The index was not valid."
        case .invalidPolicyIdentifiers:
            return "The policy identifiers are not valid."
        case .invalidTimeString:
            return "The time specified was not valid."
        case .invalidReason:
            return "The trust policy reason was not valid."
        case .invalidRequestInputs:
            return "The request inputs are not valid."
        case .invalidResponseVector:
            return "The response vector was not valid."
        case .invalidStopOnPolicy:
            return "The stop-on policy was not valid."
        case .invalidTuple:
            return "The tuple was not valid."
        case .multipleValuesUnsupported:
            return "Multiple values are not supported."
        case .notTrusted:
            return "The trust policy was not trusted."
        case .noDefaultAuthority:
            return "No default authority was detected."
        case .rejectedForm:
            return "The trust policy had a rejected form."
        case .requestLost:
            return "The request was lost."
        case .requestRejected:
            return "The request was rejected."
        case .unsupportedAddressType:
            return "The address type is not supported."
        case .unsupportedService:
            return "The service is not supported."
        case .invalidTupleGroup:
            return "The tuple group was not valid."
        case .invalidBaseACLs:
            return "The base ACLs are not valid."
        case .invalidTupleCredendtials:
            return "The tuple credentials are not valid."
        case .invalidEncoding:
            return "The encoding was not valid."
        case .invalidValidityPeriod:
            return "The validity period was not valid."
        case .invalidRequestor:
            return "The requestor was not valid."
        case .requestDescriptor:
            return "The request descriptor was not valid."
        case .invalidBundleInfo:
            return "The bundle information was not valid."
        case .invalidCRLIndex:
            return "The CRL index was not valid."
        case .noFieldValues:
            return "No field values were detected."
        case .unsupportedFieldFormat:
            return "The field format is not supported."
        case .unsupportedIndexInfo:
            return "The index information is not supported."
        case .unsupportedLocality:
            return "The locality is not supported."
        case .unsupportedNumAttributes:
            return "The number of attributes is not supported."
        case .unsupportedNumIndexes:
            return "The number of indexes is not supported."
        case .unsupportedNumRecordTypes:
            return "The number of record types is not supported."
        case .fieldSpecifiedMultiple:
            return "Too many fields were specified."
        case .incompatibleFieldFormat:
            return "The field format was incompatible."
        case .invalidParsingModule:
            return "The parsing module was not valid."
        case .databaseLocked:
            return "The database is locked."
        case .datastoreIsOpen:
            return "The data store is open."
        case .missingValue:
            return "A missing value was detected."
        case .unsupportedQueryLimits:
            return "The query limits are not supported."
        case .unsupportedNumSelectionPreds:
            return "The number of selection predicates is not supported."
        case .unsupportedOperator:
            return "The operator is not supported."
        case .invalidDBLocation:
            return "The database location is not valid."
        case .invalidAccessRequest:
            return "The access request is not valid."
        case .invalidIndexInfo:
            return "The index information is not valid."
        case .invalidNewOwner:
            return "The new owner is not valid."
        case .invalidModifyMode:
            return "The modify mode is not valid."
        case .missingRequiredExtension:
            return "A required certificate extension is missing."
        case .extendedKeyUsageNotCritical:
            return "The extended key usage extension was not marked critical."
        case .timestampMissing:
            return "A timestamp was expected but was not found."
        case .timestampInvalid:
            return "The timestamp was not valid."
        case .timestampNotTrusted:
            return "The timestamp was not trusted."
        case .timestampServiceNotAvailable:
            return "The timestamp service is not available."
        case .timestampBadAlg:
            return "An unrecognized or unsupported Algorithm Identifier in timestamp."
        case .timestampBadRequest:
            return "The timestamp transaction is not permitted or supported."
        case .timestampBadDataFormat:
            return "The timestamp data submitted has the wrong format."
        case .timestampTimeNotAvailable:
            return "The time source for the Timestamp Authority is not available."
        case .timestampUnacceptedPolicy:
            return "The requested policy is not supported by the Timestamp Authority."
        case .timestampUnacceptedExtension:
            return "The requested extension is not supported by the Timestamp Authority."
        case .timestampAddInfoNotAvailable:
            return "The additional information requested is not available."
        case .timestampSystemFailure:
            return "The timestamp request cannot be handled due to system failure."
        case .signingTimeMissing:
            return "A signing time was expected but was not found."
        case .timestampRejection:
            return "A timestamp transaction was rejected."
        case .timestampWaiting:
            return "A timestamp transaction is waiting."
        case .timestampRevocationWarning:
            return "A timestamp authority revocation warning was issued."
        case .timestampRevocationNotification:
            return "A timestamp authority revocation notification was issued."
        default:
            return "Unexpected error has occurred."
        }
    }
}
