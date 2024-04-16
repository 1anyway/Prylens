// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {SimpleSF404} from "../src/example/SimpleSF404.sol";
import "forge-std/Script.sol";

contract SimpleSF404Script is Script {
    uint256 private constant _WAD = 1000000000000000000;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // SimpleSF404 constructor args -- name, symbol, initialSupply, owner
        // CHANGE THESE VALUES TO SUIT YOUR NEEDS
        string memory name = "SF404";
        string memory symbol = "DN";
        uint96 initialSupply = 1000;
        address owner = address(this);

        new SimpleSF404(name, symbol, uint96(initialSupply * _WAD), owner);
        vm.stopBroadcast();
    }
}
