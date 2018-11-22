//
//  CookiesHelper.swift
//  Poq.iOS
//
//  Created by Nikolay Dzhulay on 21/01/2017.
//
//

import Foundation
import PoqNetworking
import PoqUtilities

open class CookiesHelper {
    
    /// For some clients, we may need show that their checkout on web opened inside of app
    /// One of the ways is set cookies. We will take specific MB value and do it.
    public static func injectClientSpecificCookies() {
        
        let clientSpecificCookies = AppSettings.sharedInstance.cleintCookies.components(separatedBy: ";")
        var cookies = [PoqAccountCookie]()
        
        for cookieString: String in clientSpecificCookies {
            let components: [String] = cookieString.components(separatedBy: "=")
            guard components.count == 2 else {
                Log.error("We must have only one = in cookie string, cookieString = \(cookieString)")
                continue
            }
            let cookie = PoqAccountCookie()
            cookie.name = components[0]
            cookie.value = components[1]
            cookies.append(cookie)
        }
        
        injectCookies(cookies: cookies)
    }
    
    public static func injectCookies(cookies cookiesOrNil: [PoqAccountCookie]?) {
        
        guard let cookies = cookiesOrNil, cookies.count > 0 else {
            return
        }
        
        // we may have 2 different domain to set cookies
        let clientDomain = AppSettings.sharedInstance.clientDomain
        let clientCookieDomain = AppSettings.sharedInstance.clientCookieDomain
        
        var domains: [String] = [clientDomain]
        
        if clientDomain != clientCookieDomain && clientCookieDomain.count > 0 {
            domains.append(clientCookieDomain)
        }
       
        // Set cookie values for the user
        for cookie in cookies {
            if let cookieName = cookie.name {
                // Explicitly remove cookie to guarantee that it's gonna be overridden
                removeCookie(forName: cookieName)
            }
            
            // We're receiving the domain in the cookie. No need to set it for the domains in MB.
            if let domainInCookie = cookie.domain, !domainInCookie.isEmpty {
                injectCookie(cookie: cookie, for: domainInCookie)
                continue
            }
            
            for domain in domains {
                injectCookie(cookie: cookie, for: domain)
            }
        }
    }
    
    static func injectCookie(cookie: PoqAccountCookie, for domain: String) {
        guard let name = cookie.name, let value = cookie.value else {
            Log.error("No name or value in cookie. Not going to set it.")
            return
        }
        
        var expiryDate: Date?
        if let cookieExpiryDate = cookie.expireDate {
            expiryDate = ISO8601DateFormatter().date(from: cookieExpiryDate)
        }
        
        let httpOnly = cookie.httpOnly
        let secure = cookie.secure
        
        var cookieProperties: [HTTPCookiePropertyKey: Any] = [
            HTTPCookiePropertyKey.name: name,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.comment: cookie.comment ?? "",
            HTTPCookiePropertyKey.commentURL: cookie.commentUrl ?? "",
            HTTPCookiePropertyKey.originURL: domain,
            HTTPCookiePropertyKey.domain: domain,
            HTTPCookiePropertyKey.path: cookie.path ?? "/",
            HTTPCookiePropertyKey.expires: expiryDate ?? NSDate(timeIntervalSinceNow: 1432233446145.0/1000.0)
        ]
        
        if let cookiePort = cookie.port {
            cookieProperties[HTTPCookiePropertyKey.port] = cookiePort
        }
        
        // Set httpOnly and secure only if it is true
        if httpOnly == true {
            cookieProperties[HTTPCookiePropertyKey.httpOnly] = httpOnly
        }
        
        if secure == true {
            cookieProperties[HTTPCookiePropertyKey.secure] = secure
        }
        
        if let httpCookie = HTTPCookie(properties: cookieProperties) {
            HTTPCookieStorage.shared.setCookie(httpCookie)
        }
    }

    public static func clearCookies() {
        
        let multipleCookieNames = AppSettings.sharedInstance.checkoutCookiesToSkipDeleting.components(separatedBy: "|")
        
        let cookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieStorage.cookies {
            
            for cookie in cookies {
                
                if multipleCookieNames.count == 0 {
                    cookieStorage.deleteCookie(cookie)
                } else {
                    
                    for cookieNameToSkip in multipleCookieNames {
                        if !cookie.name.contains(cookieNameToSkip) {
                            Log.debug("Cookie to be deleted: \(cookie.name)")
                            cookieStorage.deleteCookie(cookie)
                        } else {
                            
                            Log.verbose("Cookie to be skipped: \(cookie.name)")
                        }
                    }
                }
            }
        }
    }
    
    public  static func removeCookie(forName name: String) {
        let cookieJar = HTTPCookieStorage.shared.cookies ?? []
        for storedCookie in cookieJar {
            if storedCookie.name == name {
                HTTPCookieStorage.shared.deleteCookie(storedCookie)
            }
        }
    }
}

// https://stackoverflow.com/a/41697557/1381708
// Allow to set httpOnly = true
// printing httpCookie.isHTTPOnly, returns true
extension HTTPCookiePropertyKey {
    
    static let httpOnly = HTTPCookiePropertyKey("HttpOnly")
}
