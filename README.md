# SwCD

[![CI Status](http://img.shields.io/travis/Airin/SwCD.svg?style=flat)](https://travis-ci.org/xxxAIRINxxx/SwCD)
[![Version](https://img.shields.io/cocoapods/v/SwCD.svg?style=flat)](http://cocoadocs.org/docsets/SwCD)
[![License](https://img.shields.io/cocoapods/l/SwCD.svg?style=flat)](http://cocoadocs.org/docsets/SwCD)
[![Platform](https://img.shields.io/cocoapods/p/SwCD.svg?style=flat)](http://cocoadocs.org/docsets/SwCD)

Lightweight CoreData library written in Swift.

## Use CoreData In Swift

please see.

http://jamesonquave.com/blog/core-data-in-swift-tutorial-part-1/

```

Because of the way Swift modules work, we need to make one modification to the core data model.
In the field “Class” under the data model inspector for our entity, LogItem,
we need to specify the project name as a prefix to the class name.
So instead of just specifying “LogItem” as the class,
it needs to say “MyLog.LogItem”, assuming your app is called “MyLog”.

```

## Usage

### Setup

```swift

// DataModel is your dataModel (DataModel.xcdatamodeld)
SwCD.setup("DataModel", dbRootDirPath: nil, dbDirName: nil, dbName: nil)


```

### Create Entity

```swift

// Item is NSManagedObject Subclass
let entity = SwCD.createEntity(Item.self)

```

### Insert Entity

```swift

SwCD.insert(TestItem.self, entities: [entity], completion: { success, error in
  // after call saveWithBlockAndWait function
  if success == true {
      // do something
  } else {
      printlin(error)
  }
})

```

### Find

```swift

let predicate = NSPredicate(format: "name == %@", argumentArray: ["test"])
// Item is NSManagedObject Subclass
// results is [Item]
let results = SwCD.find(Item.self, predicate: predicate, sortDescriptors: nil, fetchLimit: nil)

```

### FindAll

```swift

// Item is NSManagedObject Subclass
// results is [Item]
let results = SwCD.all(Item.self, sortDescriptors: nil)

```

### FindFirst

```swift

// Item is NSManagedObject Subclass
// results is Item?
let result = SwCD.findFirst(Item.self, attribute: "identifier == %@", values: ["1"])

```

### Uodate

```swift

// Item is NSManagedObject Subclass
// entity is Item?
var entity = SwCD.findFirst(Item.self, attribute: "identifier == %@", values: ["1"])
entity.name = "after"

SwCD.update(Item.self, entities: [entity], completion: nil)

```

### Delete

```swift

// Item is NSManagedObject Subclass
// entity is Item?
var entity = SwCD.findFirst(Item.self, attribute: "identifier == %@", values: ["1"])

SwCD.delete(Item.self, entities: [entity], completion: nil)

```

### DeleteAll

```swift

// Item is NSManagedObject Subclass
SwCD.deleteAll(Item.self, completion: nil)

```

## Requirements

* iOS 8.0+
* Swift lang (1.2)
* ARC

## Installation

ARNAlert is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "SwCD"

## License

SwCD is available under the MIT license. See the LICENSE file for more info.
