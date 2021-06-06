//
//  Created by Tom Baranes on 24/04/16.
//  Copyright © 2016 Tom Baranes. All rights reserved.
//

import UIKit

// MARK: - Size

extension UIScreen {

    @objc public class var size: CGSize {
        return CGSize(width: width, height: height)
    }

    @objc public class var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }

    @objc public class var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }

}
