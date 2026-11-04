import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // The window would otherwise take PRODUCT_NAME, skribble_storybook.
    self.title = "Skribble Storybook"
    // The storybook's narrowest tested layout is a 360-pixel phone. Below
    // that the toolbar and page sections stop fitting.
    self.contentMinSize = NSSize(width: 360, height: 480)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
