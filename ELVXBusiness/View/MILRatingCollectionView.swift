/*
 Licensed Materials - Property of IBM
 © Copyright IBM Corporation 2015. All Rights Reserved.
 */

import UIKit
import QuartzCore

extension String {
    func toInt() -> Int? {
        if let intValue = Int(self) {
            return intValue
        }
        return nil
    }
}


//numberRange: NSRange

/**

 MARK: Constants

 */
extension MILRatingCollectionView {

    /**

     MARK: API

     */
    open class Constants {

        /** Set this to strictly use a range of integers */
//        var numberRange: NSRange? {
//            get { return _parent?._numberRange }
//            set { _parent?._numberRange = newValue }
//        }

        var numbers: [Int]? {
            get { return _parent?._numbers }
            set { _parent?._numbers = newValue ?? [0]}
        }

        var selectedIndex: Int? {
            get { return _parent?._selectedIndex }
            set { _parent?._selectedIndex = newValue }
        }

        var selectedIndexPath: IndexPath? {
            get { return IndexPath(item: selectedIndex ?? 0, section: 0) }
            set { selectedIndex = newValue?.item ?? 0 }
        }


        // MARK: Scrollable View
        /**

         number of cells visible at a time in the view

         even values will show one less cell than selected on startup, due to the view being centered on an initial value

         **NOTE** if you set this value too high and scrolling issues begin to occur, increase the **minCellWidthInPixels** property

         */
        fileprivate var _numCellsVisible: Int = 6
        var numCellsVisible: Int {
            get { if _numCellsVisible % 2 == 0 { return _numCellsVisible - 1 } else { return _numCellsVisible } }
            set { _numCellsVisible = newValue; update() }
        }

        static let DefaultLowerRangeInt: Int = 1
        static let DefaultUpperRangeInt: Int = 11


        // MARK: Color
        var circleBackgroundColor = UIColor(red: 218.0/255.0, green: 87.0/255.0, blue: 68.0/255.0, alpha: 1.0) { didSet {  _parent?.adjustCircleColor() } }

        var backgroundColor = UIColor.lightGray { didSet { _parent?.adjustBackgroundColor() } }


        // MARK: Sizing
        var circleDiameterToViewHeightRatio = CGFloat(0.6) { didSet { update() } }

        var minCellWidthInPixels = CGFloat(45.0) { didSet { update() } }


        // MARK: Fonts (font, size, color)
        var font = "Helvetica" { didSet { update() } }

        var fontSize: CGFloat = 60 { didSet { update() } }

        var normalFontColor = UIColor(red: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1.0) { didSet { update() } }

        var highlightedFontColor = UIColor.white { didSet { update() } }

        /** change this to affect how small / large the fonts become when highlighted and un-highlighted */
        var fontHighlightedAnimationScalingTransform = CGFloat(1.1) { didSet { update() } }


        // MARK: Animations
        var circleAnimated = true
        var fontAnimated = true { didSet { update() } }

        var circleAnimationDuration = TimeInterval(0.8)
        var fontAnimationDuration = TimeInterval(0.8)

        /**

         END API

         */

        // MARK: Don't Touch (please)
        static let ErrorString = "An error has occurred within the MILRatingCollectionView."
        var fontUnHighlightedAnimationScalingTransform: CGFloat { return (1 / fontHighlightedAnimationScalingTransform) }

        init(parent: MILRatingCollectionView!) { _parent = parent }

        fileprivate weak var _parent: MILRatingCollectionView?
        fileprivate func update() {  _parent?.layoutSubviews() }

    }

}


/**

 Reusable UIScrollView that acts as a horizontal scrolling number picker

 **REFERENCES**

 1. http://www.widecodes.com/7iHmeXqqeU/add-snapto-position-in-a-uitableview-or-uiscrollview.html

 */
public final class MILRatingCollectionView: UIView {

    public var constants: MILRatingCollectionView.Constants! {
        didSet { layoutSubviews() }
    }

    fileprivate var _circularView: UIView!

//    fileprivate var _numberRange: NSRange! = NSMakeRange(
//        MILRatingCollectionView.Constants.DefaultLowerRangeInt,
//        MILRatingCollectionView.Constants.DefaultUpperRangeInt
//        ) {
//        didSet { layoutSubviews() }
//    }

    fileprivate var _numbers: [Int] = [0] {
        didSet { layoutSubviews() }
    }

    fileprivate var _scrollView: UIScrollView!

    fileprivate var _leftCompensationViews: [RatingCollectionViewCell] = []
    fileprivate var _innerCellViews: [RatingCollectionViewCell] = []
    fileprivate var _rightCompensationViews: [RatingCollectionViewCell] = []

    fileprivate var _cellViews: [RatingCollectionViewCell] {
        return _leftCompensationViews + _innerCellViews + _rightCompensationViews
    }
    
    fileprivate var _currentlyHighlightedCellIndex: Int = 0

    fileprivate var _dummyOverlayView: UIView!


    var nilConstants: Bool { return self.constants == nil }

    override init(frame: CGRect) {

        super.init(frame: frame)
        if nilConstants { self.constants = MILRatingCollectionView.Constants(parent: self) }

    }

    public required init(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)!
        if nilConstants { self.constants = MILRatingCollectionView.Constants(parent: self) }

    }

}


/**

 MARK: Convenience

 * Sizes

 * Property Change Handlers

 */
private extension MILRatingCollectionView {

    // MARK: Overall
    var _size: CGSize { return self.frame.size }


    // MARK: Scroll View
    var _scrollViewFrame: CGRect {

        return CGRect(
            origin: CGPoint.zero,
            size: _size
        )

    }

    var centeredX: CGFloat { return self.center.x + _scrollView.contentOffset.x }

    var newCellIndex: Int {
        return Int(
            floor(
                // this "10.0" helps alleviate flooring inaccuracies and results in more-robust responsiveness
                (self.centeredX - _cellWidth/2 + CGFloat(10.0)) / _cellWidth
            )
        )
    }


    // MARK: Dummy View
    var _dummyViewFrame: CGRect {

        return CGRect(
            x: 0.0,
            y: 0.0,
            width: _size.width,
            height: _size.height
        )

    }

    func adjustBackgroundColor() {

        if self._dummyOverlayView != nil {
            _dummyOverlayView.backgroundColor = self.constants.backgroundColor
        }

    }


    // MARK: Circle View
    var _circleViewFrame: CGRect {

        return CGRect(
            x: _size.width/2,
            y: _size.height/2,
            width: self._circularView.frame.width,
            height: self._circularView.frame.height
        )

    }

    var _circleViewDiameter: CGFloat { return _size.height * constants.circleDiameterToViewHeightRatio }

    func adjustCircleColor() {

        if self._circularView != nil {
            _circularView.backgroundColor = self.constants.circleBackgroundColor
        }

    }


    // MARK: Cells
    var _cellWidth: CGFloat {

        return max(
            frame.size.width/CGFloat(constants.numCellsVisible),
            self.constants.minCellWidthInPixels
        )

    }

    var _selectedIndex: Int? {

        get {

            let cellView: RatingCollectionViewCell? = _cellViews[_currentlyHighlightedCellIndex]
            return cellView?._numberLabel.text?.toInt()

        }

        set {

            /** declares the new type, "isPresentTuple" */
            typealias isPresentTuple = (isPresent: Bool, scrollLocation: CGPoint)

            let isIndexPresentTuple: isPresentTuple = isIndexPresent(newValue!)

            if isIndexPresentTuple.isPresent {
                scrollToNewScrollLocation(isIndexPresentTuple.scrollLocation)
            }

        }

    }

}


/**

 MARK: Setup

 rotation, range-setting, constants-changing --> **layoutSubviews()**

 */
extension MILRatingCollectionView {

    override public func layoutSubviews() { didMoveToSuperview() }

    // effectively an init + animation on display
    override public func didMoveToSuperview() {

        cleanExistingViews()
        createDummyOverlayView()
        createCircularView()
        addCircularViewToDummyOverlayView()
        configureScrollViewExcludingContentSize()
        configureScrollViewContentSizeAndPopulateScrollView()
        configureInitialScrollViewHighlightedIndex()
        animateCircleToCenter()

    }

    fileprivate func cleanExistingViews() {

        for view in self.subviews {
            view.removeFromSuperview()
        }

        _leftCompensationViews = []
        _rightCompensationViews = []
        _innerCellViews = []

    }

    fileprivate func createDummyOverlayView() {

        _dummyOverlayView = UIView(frame: _dummyViewFrame)
        _dummyOverlayView.backgroundColor = UIColor.white
        _dummyOverlayView.isUserInteractionEnabled = false

        self.addSubview(_dummyOverlayView)
        self.sendSubview(toBack: _dummyOverlayView)

    }

    fileprivate func createCircularView() {

        let temporaryCircularViewFrame = CGRect(
            x: -_circleViewDiameter/2,
            y: -_circleViewDiameter/2,
            width: _circleViewDiameter,
            height: _circleViewDiameter
        )

        _circularView = UIView(frame: temporaryCircularViewFrame)
        _circularView.layer.cornerRadius = _circleViewDiameter/2.0
        _circularView.backgroundColor = constants.circleBackgroundColor

    }

    fileprivate func addCircularViewToDummyOverlayView() {
        _dummyOverlayView.addSubview(self._circularView)
    }

    /** sets userInteractionEnabled to 'false' initially, see the method 'configureInitialScrollViewHighlightedIndex()' in 'initView()'  */
    fileprivate func configureScrollViewExcludingContentSize() {

        _scrollView = UIScrollView(frame: _scrollViewFrame)

        _scrollView.delegate = self
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.isUserInteractionEnabled = false

        self.addSubview(_scrollView)

    }

    fileprivate func configureScrollViewContentSizeAndPopulateScrollView() {

        let compensationCountLeftRight = Int(
            floor(
                CGFloat(self.constants.numCellsVisible) / 2.0
            )
        )

        let totalItemsCount = self._numbers.count + 2 * compensationCountLeftRight

        // content size
        _scrollView.contentSize = CGSize(
            width: CGFloat(totalItemsCount) * _cellWidth,
            height: self.frame.height
        )

        // populating scrollview
        var runningXOffset: CGFloat = 0.0
        var newViewToAdd: RatingCollectionViewCell!

        // generate indices to insert as text
        var indicesToDrawAsText: [Int] = []
        var rangeIndex = 0

        for i in _numbers {

            indicesToDrawAsText.insert(i, at: rangeIndex)
            rangeIndex += 1

        }

        // populate left empty views, then middle, then right empty views
        for index in 0 ..< totalItemsCount {

            let newViewFrame = newScrollViewChildViewFrameWithXOffset(runningXOffset)
            newViewToAdd = RatingCollectionViewCell(frame: newViewFrame, parent: self)

            switch index {

            case 0 ..< compensationCountLeftRight:

                _leftCompensationViews.insert(newViewToAdd, at: index)

            case compensationCountLeftRight ..< (totalItemsCount-compensationCountLeftRight):

                let innerIndexingCompensation = index - compensationCountLeftRight
                newViewToAdd._numberLabel.text = "\(indicesToDrawAsText[innerIndexingCompensation])"
                _innerCellViews.insert(newViewToAdd, at: innerIndexingCompensation)

            case (totalItemsCount-compensationCountLeftRight) ..< totalItemsCount:

                let rightIndexingCompensation = index - (totalItemsCount - compensationCountLeftRight)
                _rightCompensationViews.insert(newViewToAdd, at: rightIndexingCompensation)

            default:
                print(Constants.ErrorString)

            }

            runningXOffset += _cellWidth

        }

        // add these newly generated views to the scrollview
        for cellView in _cellViews {
            _scrollView.addSubview(cellView)
        }

    }

    fileprivate func newScrollViewChildViewFrameWithXOffset(_ xOffset: CGFloat) -> CGRect {

        return CGRect(
            x: xOffset,
            y: 0.0,
            width: _cellWidth,
            height: self.frame.height
        )

    }

    fileprivate func configureInitialScrollViewHighlightedIndex() {

        _currentlyHighlightedCellIndex = 0
        _innerCellViews[_currentlyHighlightedCellIndex].setAsHighlightedCell()
        _currentlyHighlightedCellIndex = _leftCompensationViews.count
        
    }

    fileprivate func animateCircleToCenter() {

        let moveCircleToCenter: () -> () = {
            self._circularView.center = self._dummyOverlayView.center
        }

        if self.constants.circleAnimated {

            UIView.animate(withDuration: self.constants.circleAnimationDuration, animations: moveCircleToCenter, completion: {
                (completed: Bool) in self._scrollView.isUserInteractionEnabled = true
            }) 

        } else {

            UIView.animate(withDuration: 0.0, animations: moveCircleToCenter, completion: {
                (completed: Bool) in self._scrollView.isUserInteractionEnabled = true
            }) 

        }

    }

}


/**

 MARK: Checking Current State

 */
extension MILRatingCollectionView {

    fileprivate func isIndexPresent(_ index: Int) -> (isPresent: Bool, scrollLocation: CGPoint) {

        var returnTuple: (isPresent: Bool, scrollLocation: CGPoint) = (isPresent: false, scrollLocation: CGPoint.zero)

        /**

         in Swift 2.0, the syntax would be

         for (index, viewCell) in array.enumerate()

         whereas in Swift 1.2

         for (index, viewCell) in enumerate(array)

         in this case, we'll stick to an "index," but the desire for some syntactic sugar was there. :)

         */
        for i in 0 ..< _innerCellViews.count {

            let ratingCollectionViewCell = _innerCellViews[i]

            let label = ratingCollectionViewCell._numberLabel

            if label != nil {

                if let numberValue = label?.text?.toInt() {

                    if index == numberValue {

                        returnTuple.isPresent = true
                        returnTuple.scrollLocation = CGPoint(
                            x: CGFloat(i + _leftCompensationViews.count) * _cellWidth + 0.5 * _cellWidth - _scrollView.center.x,
                            y: 0.0
                        )

                    }

                }

            }

        }

        return returnTuple

    }

}


/**

 MARK: UIScrollViewDelegate

 */
extension MILRatingCollectionView: UIScrollViewDelegate {

    /**

     Method that recognizes center cell and highlights it while leaving other cells normal

     :param: scrollView (should be self)

     */
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // done to prevent recalculating / potential errors
        let newCellIndex = self.newCellIndex

        let shouldHighlightAnotherCell = (_currentlyHighlightedCellIndex != newCellIndex)
        let outOfBoundsScrollingLeft = (newCellIndex < 0)
        let outOfBoundsScrollingRight = (newCellIndex > _cellViews.count-1)

        if shouldHighlightAnotherCell && !outOfBoundsScrollingLeft && !outOfBoundsScrollingRight {

            _cellViews[_currentlyHighlightedCellIndex].setAsNormalCell()
            _cellViews[newCellIndex].setAsHighlightedCell()
            _currentlyHighlightedCellIndex = newCellIndex

        }

    }

    /**

     Reference [1]

     Adjusts scrolling to end exactly on an item

     */
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        var targetCellViewIndex = floor(targetContentOffset.pointee.x / _cellWidth)

        if ((targetContentOffset.pointee.x - floor(targetContentOffset.pointee.x / _cellWidth) * _cellWidth) > _cellWidth) {
            targetCellViewIndex += 1
        }

        targetContentOffset.pointee.x = targetCellViewIndex * _cellWidth

    }

    /**

     called when the currently selected index is programmatically set

     */
    fileprivate func scrollToNewScrollLocation(_ newLocation: CGPoint) {

        // overcompensate in scrolling to deal with floor / round inaccuracies
        let compensationAmount = CGFloat(2.0)

        let isScrollingRight = (newLocation.x > _scrollView.contentOffset.x)

        let newContentOffset = CGPoint(
            x: isScrollingRight ? (newLocation.x + compensationAmount) : (newLocation.x - compensationAmount),
            y: 0.0
        )

        _scrollView.setContentOffset(newContentOffset, animated: true)

    }

}


/**

 RatingCollectionViewCell consisting of a number label that varies in size if it is the most centered cell

 NOTE: If changing constants below, don't forget to use "digit.0" to avoid CGFloat / Int calculation issues

 */
extension MILRatingCollectionView {

    fileprivate final class RatingCollectionViewCell: UIView {

        var _parentConstants: MILRatingCollectionView.Constants!

        var _numberLabel: UILabel!

        var unHighlightedFontName: String { return "\(_parentConstants.font)-Medium" }
        var highlightedFontName: String { return "\(_parentConstants.font)-Bold" }

        required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

        init(frame: CGRect, parent: MILRatingCollectionView) {

            super.init(frame: frame)

            _parentConstants = parent.constants
            initCell()

        }

        func initCell() {

            _numberLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: self.frame.size))
            _numberLabel.textAlignment = NSTextAlignment.center

            self.addSubview(_numberLabel)
            self.setAsNormalCell()

        }

        /**

         Method to increase number size and animate with a popping effect

         */
        func setAsHighlightedCell() {

            let setAsHighlightedAnimation: () -> () = {

                let label = self._numberLabel
                label?.textColor = self._parentConstants.highlightedFontColor
                label?.font = UIFont(name: "\(self.highlightedFontName)", size: self._parentConstants.fontSize)
                label?.transform = (label?.transform.scaledBy(x: self._parentConstants.fontHighlightedAnimationScalingTransform, y: self._parentConstants.fontHighlightedAnimationScalingTransform))!
            }

            UIView.animate(withDuration: _parentConstants.fontAnimationDuration, animations: setAsHighlightedAnimation)

        }

        /**

         Returns cells back to their original state and smaller size.

         */
        func setAsNormalCell() {

            let setAsUnHighlightedAnimation: () -> () = {

                let label = self._numberLabel

                label?.textColor = self._parentConstants.normalFontColor
                label?.font = UIFont(name: "\(self.unHighlightedFontName)", size: self._parentConstants.fontSize)
                label?.transform = (label?.transform.scaledBy(x: self._parentConstants.fontUnHighlightedAnimationScalingTransform, y: self._parentConstants.fontUnHighlightedAnimationScalingTransform))!

            }

            UIView.animate(withDuration: _parentConstants.fontAnimationDuration, animations: setAsUnHighlightedAnimation)
            
        }
        
    }
    
}
