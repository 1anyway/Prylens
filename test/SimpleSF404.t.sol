// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./utils/SoladyTest.sol";
import {SimpleSF404, SF404Mirror} from "../src/example/SimpleSF404.sol";

contract SimpleSF404Test is SoladyTest {
    SimpleSF404 dn;
    address alice = address(111);

    function setUp() public {
        vm.prank(alice);
        dn = new SimpleSF404("SF404", "DN", 1000, address(this));
    }

    function testMint() public {
        vm.prank(dn.owner());
        dn.mint(alice, 100);
        assertEq(dn.totalSupply(), 1100);
    }

    function testName() public {
        assertEq(dn.name(), "SF404");
    }

    function testSymbol() public {
        assertEq(dn.symbol(), "DN");
    }

    function testSetBaseURI() public {
        vm.prank(alice);
        dn.setBaseURI("https://example.com/");
        assertEq(SF404Mirror(payable(dn.mirrorERC721())).tokenURI(1), "https://example.com/1");
    }

    function testWithdraw() public {
        vm.deal(address(dn), 1 ether);
        assertEq(address(dn).balance, 1 ether);
        vm.prank(alice);
        dn.withdraw();
        assertEq(address(dn).balance, 0);
        assertEq(alice.balance, 1 ether);
    }
}
