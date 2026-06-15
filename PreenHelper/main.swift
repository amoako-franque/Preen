import Foundation

let delegate = HelperDelegate()
let listener = NSXPCListener(machServiceName: PreenConstants.helperMachServiceName)
listener.delegate = delegate
listener.resume()
RunLoop.main.run()
