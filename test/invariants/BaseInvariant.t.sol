// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {SF404} from "../../src/SF404.sol";
import {SF404Mirror} from "../../src/SF404Mirror.sol";
import {MockSF404} from "../utils/mocks/MockSF404.sol";
import {SF404Handler} from "./handlers/SF404Handler.sol";

// forgefmt: disable-start
/**************************************************************************************************************************************/
/*** Invariant Tests                                                                                                                ***/
/***************************************************************************************************************************************

    * NFT total supply * WAD must always be less than or equal to the ERC20 total supply
    * NFT balance of a user * WAD must be less than or equal to the ERC20 balance of that user
    * NFT balance of all users summed up must be equal to the NFT total supply
    * ERC20 balance of all users summed up must be equal to the ERC20 total supply
    * Mirror contract known to the base and the base contract known to the mirror never change after initialization

/**************************************************************************************************************************************/
/*** Vault Invariants                                                                                                               ***/
/**************************************************************************************************************************************/
// forgefmt: disable-end
contract BaseInvariantTest is Test {
    address user0 = vm.addr(uint256(keccak256("User0")));
    address user1 = vm.addr(uint256(keccak256("User1")));
    address user2 = vm.addr(uint256(keccak256("User2")));
    address user3 = vm.addr(uint256(keccak256("User3")));
    address user4 = vm.addr(uint256(keccak256("User4")));
    address user5 = vm.addr(uint256(keccak256("User5")));
    uint256 private constant _WAD = 1000000000000000000;

    MockSF404 SF404;
    SF404Mirror SF404Mirror;
    SF404Handler SF404Handler;

    function setUp() external virtual {
        SF404 = new MockSF404();
        SF404Mirror = new SF404Mirror(address(this));
        SF404.initializeSF404(0, address(0), address(SF404Mirror));

        SF404Handler = new SF404Handler(SF404);

        vm.label(address(SF404), "SF404");
        vm.label(address(SF404Mirror), "SF404Mirror");
        vm.label(address(SF404Handler), "SF404Handler");

        // target handlers
        targetContract(address(SF404Handler));
    }

    function invariantTotalReflectionIsValid() external {
        assertLe(
            SF404Mirror.totalSupply() * _WAD,
            SF404.totalSupply(),
            "NFT total supply * wad is greater than ERC20 total supply"
        );
    }

    function invariantUserReflectionIsValid() external {
        assertLe(
            SF404Mirror.balanceOf(user0) * _WAD,
            SF404.balanceOf(user0),
            "NFT balanceOf user 0 * wad is greater its ERC20 balanceOf"
        );
        assertLe(
            SF404Mirror.balanceOf(user1) * _WAD,
            SF404.balanceOf(user1),
            "NFT balanceOf user 1 * wad is greater its ERC20 balanceOf"
        );
        assertLe(
            SF404Mirror.balanceOf(user2) * _WAD,
            SF404.balanceOf(user2),
            "NFT balanceOf user 2 * wad is greater its ERC20 balanceOf"
        );
        assertLe(
            SF404Mirror.balanceOf(user3) * _WAD,
            SF404.balanceOf(user3),
            "NFT balanceOf user 3 * wad is greater its ERC20 balanceOf"
        );
        assertLe(
            SF404Mirror.balanceOf(user4) * _WAD,
            SF404.balanceOf(user4),
            "NFT balanceOf user 4 * wad is greater its ERC20 balanceOf"
        );
        assertLe(
            SF404Mirror.balanceOf(user5) * _WAD,
            SF404.balanceOf(user5),
            "NFT balanceOf user 5 * wad is greater its ERC20 balanceOf"
        );
    }

    function invariantMirror721BalanceSum() external {
        uint256 total = SF404Handler.nftsOwned(user0) + SF404Handler.nftsOwned(user1)
            + SF404Handler.nftsOwned(user2) + SF404Handler.nftsOwned(user3)
            + SF404Handler.nftsOwned(user4) + SF404Handler.nftsOwned(user5);
        assertEq(total, SF404Mirror.totalSupply(), "all users nfts owned exceed nft total supply");
    }

    function invariantSF404BalanceSum() external {
        uint256 total = SF404.balanceOf(user0) + SF404.balanceOf(user1) + SF404.balanceOf(user2)
            + SF404.balanceOf(user3) + SF404.balanceOf(user4) + SF404.balanceOf(user5);
        assertEq(SF404.totalSupply(), total, "all users erc20 balance exceed erc20 total supply");
    }

    function invariantMirrorAndBaseRemainImmutable() external {
        assertEq(
            SF404.mirrorERC721(), address(SF404Mirror), "mirror 721 changed after initialization"
        );
        assertEq(SF404Mirror.baseERC20(), address(SF404), "base erc20 changed after initialization");
    }
}
