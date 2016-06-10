import Quick
import Nimble
import UIKit_PivotalSpecHelperStubs
@testable import StreamCenter

class ModalMenuViewSpec : QuickSpec {
    override func spec() {
        var subject : ModalMenuView!

        beforeEach {
            let size : CGSize = CGSizeMake(50, 100)
            let frame : CGRect = CGRectMake(50, 50, 50, 50)
            let options : [String : [MenuOption]] = [
                "this-that-option" : [
                MenuOption.init(
                    enabledTitle: "title",
                    disabledTitle: "disabled-title",
                    enabled: true,
                    parameters: nil,
                    onClick: {_ in }),
                ]
            ]
            subject = ModalMenuView.init(frame: frame, options: options, size: size)
        }

        it("should add a subview for each menu option") {
            expect(subject.subviews.count).to(equal(2));
            expect(subject.subviews[0]).to(beAKindOf(UILabel))
            expect(subject.subviews[1]).to(beAKindOf(MenuItemView))

            let label = subject.subviews[0] as! UILabel
            expect(label.text).to(equal("this-that-option"))

            let menuItem = subject.subviews[1] as! MenuItemView
            expect(menuItem.option.enabledTitle).to(equal("title"))
            expect(menuItem.option.disabledTitle).to(equal("disabled-title"))
            expect(menuItem.option.isEnabled).to(beTrue())
        }
    }
}
