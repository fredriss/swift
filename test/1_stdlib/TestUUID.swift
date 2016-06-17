// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
//
// RUN: mkdir -p %t
// RUN: %target-build-swift %s -o %t/a.out -Ounchecked
//
// RUN: %target-run %t/a.out
// REQUIRES: executable_test
// REQUIRES: objc_interop

import Foundation

#if FOUNDATION_XCTEST
import XCTest
class TestUUIDSuper : XCTestCase { }
#else
import StdlibUnittest
class TestUUIDSuper { }
#endif


class TestUUID : TestUUIDSuper {
    func test_NS_Equality() {
        let uuidA = NSUUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
        let uuidB = NSUUID(uuidString: "e621e1f8-c36c-495a-93fc-0c247a3e6e5f")
        let uuidC = NSUUID(uuidBytes: [0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f])
        let uuidD = NSUUID()
        
        expectEqual(uuidA, uuidB, "String case must not matter.")
        expectEqual(uuidA, uuidC, "A UUID initialized with a string must be equal to the same UUID initialized with its UnsafePointer<UInt8> equivalent representation.")
        expectNotEqual(uuidC, uuidD, "Two different UUIDs must not be equal.")
    }
    
    func test_Equality() {
        let uuidA = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
        let uuidB = UUID(uuidString: "e621e1f8-c36c-495a-93fc-0c247a3e6e5f")
        let uuidC = UUID(uuid: uuid_t(0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f))
        let uuidD = UUID()
        
        expectEqual(uuidA, uuidB, "String case must not matter.")
        expectEqual(uuidA, uuidC, "A UUID initialized with a string must be equal to the same UUID initialized with its UnsafePointer<UInt8> equivalent representation.")
        expectNotEqual(uuidC, uuidD, "Two different UUIDs must not be equal.")
    }
    
    func test_NS_InvalidUUID() {
        let uuid = NSUUID(uuidString: "Invalid UUID")
        expectEmpty(uuid, "The convenience initializer `init?(uuidString string:)` must return nil for an invalid UUID string.")
    }
    
    func test_InvalidUUID() {
        let uuid = UUID(uuidString: "Invalid UUID")
        expectEmpty(uuid, "The convenience initializer `init?(uuidString string:)` must return nil for an invalid UUID string.")
    }
    
    func test_NS_uuidString() {
        let uuid = NSUUID(uuidBytes: [0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f])
        expectEqual(uuid.uuidString, "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
    }
    
    func test_uuidString() {
        let uuid = UUID(uuid: uuid_t(0xe6,0x21,0xe1,0xf8,0xc3,0x6c,0x49,0x5a,0x93,0xfc,0x0c,0x24,0x7a,0x3e,0x6e,0x5f))
        expectEqual(uuid.uuidString, "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")
    }
    
    func test_description() {
        let uuid = UUID()
        expectEqual(uuid.description, uuid.uuidString, "The description must be the same as the uuidString.")
    }

    func test_roundTrips() {
        let ref = NSUUID()
        let valFromRef = ref as UUID
        var bytes: [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let valFromBytes = bytes.withUnsafeMutableBufferPointer { buffer -> UUID in
            ref.getBytes(buffer.baseAddress)
            return UUID(uuid: UnsafePointer<uuid_t>(buffer.baseAddress!).pointee)
        }
        let valFromStr = UUID(uuidString: ref.uuidString)
        expectEqual(ref.uuidString, valFromRef.uuidString)
        expectEqual(ref.uuidString, valFromBytes.uuidString)
        expectNotEmpty(valFromStr)
        expectEqual(ref.uuidString, valFromStr!.uuidString)
    }
    
    func test_hash() {
        let ref = NSUUID()
        let val = UUID(uuidString: ref.uuidString)!
        expectEqual(ref.hashValue, val.hashValue, "Hashes of references and values should be identical")
    }
}

#if !FOUNDATION_XCTEST
var UUIDTests = TestSuite("TestUUID")
UUIDTests.test("test_NS_Equality") { TestUUID().test_NS_Equality() }
UUIDTests.test("test_Equality") { TestUUID().test_Equality() }
UUIDTests.test("test_NS_InvalidUUID") { TestUUID().test_NS_InvalidUUID() }
UUIDTests.test("test_InvalidUUID") { TestUUID().test_InvalidUUID() }
UUIDTests.test("test_NS_uuidString") { TestUUID().test_NS_uuidString() }
UUIDTests.test("test_uuidString") { TestUUID().test_uuidString() }
UUIDTests.test("test_description") { TestUUID().test_description() }
UUIDTests.test("test_roundTrips") { TestUUID().test_roundTrips() }
UUIDTests.test("test_hash") { TestUUID().test_hash() }
runAllTests()
#endif

