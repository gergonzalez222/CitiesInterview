//
//  UalaCitiesInterviewUITests.swift
//  UalaCitiesInterviewUITests
//
//  Created by Martin German Gonzalez Moran on 26/05/2025.
//

import XCTest

final class UalaCitiesInterviewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("UI-TESTING")
        app.launch()
    }
    
    func testShowCitiesList() {
        let list = app.collectionViews["CityListView_ID"]

        XCTAssertTrue(list.exists)

        XCTAssertEqual(list.cells.count, 3)
    }

    func testShowFavorites() {
        let favoritesButton = app.buttons["ShowFavoritesButton_ID"]
        
        XCTAssertTrue(favoritesButton.exists)
        
        favoritesButton.tap()
    }
    
    func testToggleFavorite() {
        let list = app.collectionViews["CityListView_ID"]
        
        XCTAssertTrue(list.exists)

        XCTAssertEqual(list.cells.count, 3)
        
        let favoritesButton = app.buttons["ShowFavoritesButton_ID"]
        
        XCTAssertTrue(favoritesButton.exists)
        
        favoritesButton.tap()
        
        let firstRow = list.cells.element(boundBy: 0)
        
        let toggleFavoriteButton = firstRow.buttons["ToggleFavoriteButton_ID"]
        
        XCTAssertTrue(toggleFavoriteButton.exists)
        
        toggleFavoriteButton.tap()
        
        XCTAssertEqual(list.cells.count, 2)
    }
    
    func testSeachInCityList() {
        let list = app.collectionViews["CityListView_ID"]
        
        XCTAssertTrue(list.exists)

        XCTAssertEqual(list.cells.count, 3)
        
        let searchField = app.searchFields.firstMatch
        
        XCTAssertTrue(searchField.exists)
        
        searchField.tap()
        searchField.typeText("B")
        
        XCTAssertEqual(list.cells.count, 1)
        
        let cell = list.cells.element(boundBy: 0)
        XCTAssertTrue(cell.staticTexts["Buenos Aires AR"].exists)
    }
}
