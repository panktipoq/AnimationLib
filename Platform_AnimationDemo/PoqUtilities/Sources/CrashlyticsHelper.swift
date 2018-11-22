//
//  CrashlyticsHelper.swift
//  Poq.iOS.Platform
//
//  Created by Joshua White on 18/05/2017.
//
//

import Crashlytics
import Fabric

public final class CrashlyticsHelper {
    
    public class func log(_ message: String, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        CLSLogv("%@:%@:%@ :: %@", getVaList([file, function, line, message]))
    }
    
    public class func logNavigation(to viewController: UIViewController) {
        let name = String(describing: type(of: viewController))
        CLSLogv("Navigate to: %@", getVaList([name]))
    }
    
    public class func start() {
        Fabric.with([Crashlytics.sharedInstance()])
    }
    
    public class func crash() {
        Crashlytics.sharedInstance().crash()
    }
}

