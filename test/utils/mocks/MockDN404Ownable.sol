// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./MockSF404.sol";
import {Ownable} from "solady/auth/Ownable.sol";

contract MockSF404Ownable is MockSF404, Ownable {
    constructor() {
        _initializeOwner(msg.sender);
    }
}
