// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../src/SF404.sol";
import "../../../src/SF404Mirror.sol";

contract MockSF404OnlyERC20 is SF404 {
    constructor() {
        address mirror = address(new SF404Mirror(msg.sender));
        _initializeSF404(0, address(this), mirror);
    }

    function name() public view virtual override returns (string memory) {
        return "name";
    }

    function symbol() public view virtual override returns (string memory) {
        return "SYMBOL";
    }

    function _tokenURI(uint256) internal view virtual override returns (string memory) {
        return "";
    }

    function _addressData(address a) internal virtual override returns (AddressData storage d) {
        d = SF404._addressData(a);
        d.flags |= _ADDRESS_DATA_SKIP_NFT_FLAG;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}
