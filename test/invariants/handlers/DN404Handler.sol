// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {MockSF404} from "../../utils/mocks/MockSF404.sol";
import {SF404Mirror} from "../../../src/SF404Mirror.sol";

contract SF404Handler is Test {
    uint256 private constant _WAD = 1000000000000000000;
    uint256 private constant START_SLOT =
        0x0000000000000000000000000000000000000000000000a20d6e21d0e5255308;
    uint8 internal constant _ADDRESS_DATA_SKIP_NFT_FLAG = 1 << 1;

    MockSF404 SF404;
    SF404Mirror mirror;

    address user0 = vm.addr(uint256(keccak256("User0")));
    address user1 = vm.addr(uint256(keccak256("User1")));
    address user2 = vm.addr(uint256(keccak256("User2")));
    address user3 = vm.addr(uint256(keccak256("User3")));
    address user4 = vm.addr(uint256(keccak256("User4")));
    address user5 = vm.addr(uint256(keccak256("User5")));

    address[6] actors;

    mapping(address => uint256) public nftsOwned;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    constructor(MockSF404 _SF404) {
        SF404 = _SF404;
        mirror = SF404Mirror(payable(SF404.mirrorERC721()));

        actors[0] = user0;
        actors[1] = user1;
        actors[2] = user2;
        actors[3] = user3;
        actors[4] = user4;
        actors[5] = user5;

        vm.prank(user0);
        SF404.approve(user0, type(uint256).max);

        vm.prank(user1);
        SF404.approve(user1, type(uint256).max);

        vm.prank(user2);
        SF404.approve(user2, type(uint256).max);

        vm.prank(user3);
        SF404.approve(user3, type(uint256).max);

        vm.prank(user4);
        SF404.approve(user4, type(uint256).max);

        vm.prank(user5);
        SF404.approve(user5, type(uint256).max);
    }

    function randomAddress(uint256 seed) private view returns (address) {
        return actors[bound(seed, 0, actors.length - 1)];
    }

    function approve(uint256 ownerIndexSeed, uint256 spenderIndexSeed, uint256 amount) external {
        address owner = randomAddress(ownerIndexSeed);
        address spender = randomAddress(spenderIndexSeed);

        if (owner == spender) return;

        vm.startPrank(owner);
        SF404.approve(spender, amount);
    }

    function transfer(uint256 fromIndexSeed, uint256 toIndexSeed, uint256 amount) external {
        address from = randomAddress(fromIndexSeed);
        address to = randomAddress(toIndexSeed);
        amount = bound(amount, 0, SF404.balanceOf(from));
        vm.startPrank(from);

        uint256 fromPreBalance = SF404.balanceOf(from);
        uint256 toPreBalance = SF404.balanceOf(to);

        SF404.transfer(to, amount);

        uint256 fromNFTPreOwned = nftsOwned[from];

        nftsOwned[from] -= _zeroFloorSub(fromNFTPreOwned, (fromPreBalance - amount) / _WAD);
        if (!SF404.getSkipNFT(to)) {
            if (from == to) toPreBalance -= amount;
            nftsOwned[to] += _zeroFloorSub((toPreBalance + amount) / _WAD, nftsOwned[to]);
        }
    }

    function transferFrom(
        uint256 senderIndexSeed,
        uint256 fromIndexSeed,
        uint256 toIndexSeed,
        uint256 amount
    ) external {
        address sender = randomAddress(senderIndexSeed);
        address from = randomAddress(fromIndexSeed);
        address to = randomAddress(toIndexSeed);
        amount = bound(amount, 0, SF404.balanceOf(from));
        vm.startPrank(sender);

        uint256 fromPreBalance = SF404.balanceOf(from);
        uint256 toPreBalance = SF404.balanceOf(to);

        if (SF404.allowance(from, sender) < amount) {
            sender = from;
            vm.startPrank(sender);
        }

        SF404.transferFrom(from, to, amount);

        uint256 fromNFTPreOwned = nftsOwned[from];

        nftsOwned[from] -= _zeroFloorSub(fromNFTPreOwned, (fromPreBalance - amount) / _WAD);
        if (!SF404.getSkipNFT(to)) {
            if (from == to) toPreBalance -= amount;
            nftsOwned[to] += _zeroFloorSub((toPreBalance + amount) / _WAD, nftsOwned[to]);
        }
    }

    function mint(uint256 toIndexSeed, uint256 amount) external {
        address to = randomAddress(toIndexSeed);
        amount = bound(amount, 0, 100e18);

        uint256 toPreBalance = SF404.balanceOf(to);

        SF404.mint(to, amount);

        if (!SF404.getSkipNFT(to)) {
            nftsOwned[to] = (toPreBalance + amount) / _WAD;
        }
    }

    function burn(uint256 fromIndexSeed, uint256 amount) external {
        address from = randomAddress(fromIndexSeed);
        vm.startPrank(from);
        amount = bound(amount, 0, SF404.balanceOf(from));

        uint256 fromPreBalance = SF404.balanceOf(from);

        SF404.burn(from, amount);

        nftsOwned[from] -= _zeroFloorSub(nftsOwned[from], (fromPreBalance - amount) / _WAD);
    }

    function setSkipNFT(uint256 actorIndexSeed, bool status) external {
        vm.startPrank(randomAddress(actorIndexSeed));
        SF404.setSkipNFT(status);
    }

    function approveNFT(uint256 ownerIndexSeed, uint256 spenderIndexSeed, uint256 id) external {
        address owner = randomAddress(ownerIndexSeed);
        address spender = randomAddress(spenderIndexSeed);

        if (mirror.ownerAt(id) != address(0)) return;
        if (mirror.ownerAt(id) != owner) {
            owner = mirror.ownerAt(id);
        }

        vm.startPrank(owner);
        mirror.approve(spender, id);
    }

    function setApprovalForAll(uint256 ownerIndexSeed, uint256 spenderIndexSeed, uint256 id)
        external
    {
        address owner = randomAddress(ownerIndexSeed);
        address spender = randomAddress(spenderIndexSeed);

        if (mirror.ownerAt(id) != address(0)) return;
        if (mirror.ownerAt(id) != owner) {
            owner = mirror.ownerAt(id);
        }

        vm.startPrank(owner);
        mirror.approve(spender, id);
    }

    function transferFromNFT(
        uint256 senderIndexSeed,
        uint256 fromIndexSeed,
        uint256 toIndexSeed,
        uint32 id
    ) external {
        address sender = randomAddress(senderIndexSeed);
        address from = randomAddress(fromIndexSeed);
        address to = randomAddress(toIndexSeed);

        if (mirror.ownerAt(id) == address(0)) return;
        if (mirror.getApproved(id) != sender || mirror.isApprovedForAll(from, sender)) {
            sender = from;
        }
        if (mirror.ownerAt(id) != from) {
            from = mirror.ownerAt(id);
            sender = from;
        }

        vm.startPrank(sender);

        mirror.transferFrom(from, to, id);

        --nftsOwned[from];
        ++nftsOwned[to];
    }

    function _zeroFloorSub(uint256 x, uint256 y) private pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }
}
