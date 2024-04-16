// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../src/SF404.sol";

contract MockSF404 is SF404 {
    string private _name;

    string private _symbol;

    string private _baseURI;

    bool addToBurnedPool;

    bool useDirectTransfersIfPossible;

    bool givePermit2DefaultInfiniteAllowance;

    bool useExistsLookup;

    function setNameAndSymbol(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function setBaseURI(string memory baseURI_) public {
        _baseURI = baseURI_;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function _tokenURI(uint256 id) internal view virtual override returns (string memory) {
        return string(abi.encodePacked(_baseURI, id));
    }

    function registerAndResolveAlias(address target) public returns (uint32) {
        return _registerAndResolveAlias(_addressData(target), target);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function mintNext(address to, uint256 amount) public {
        _mintNext(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }

    function initializeSF404(
        uint256 initialTokenSupply,
        address initialSupplyOwner,
        address mirrorNFTContract
    ) public {
        _initializeSF404(initialTokenSupply, initialSupplyOwner, mirrorNFTContract);
    }

    function getAddressDataInitialized(address target) public view returns (bool) {
        return _getSF404Storage().addressData[target].flags & _ADDRESS_DATA_INITIALIZED_FLAG != 0;
    }

    function setAux(address target, uint88 value) public {
        _setAux(target, value);
    }

    function getAux(address target) public view returns (uint88) {
        return _getAux(target);
    }

    function getNextTokenId() public view returns (uint32) {
        return _getSF404Storage().nextTokenId;
    }

    function _addToBurnedPool(uint256, uint256) internal view virtual override returns (bool) {
        return addToBurnedPool;
    }

    function setAddToBurnedPool(bool value) public {
        addToBurnedPool = value;
    }

    function setNumAliases(uint32 value) public {
        _getSF404Storage().numAliases = value;
    }

    function tokensOf(address owner) public view returns (uint256[] memory result) {
        result = _tokensOfWithChecks(owner);
    }

    function _tokensOfWithChecks(address owner) internal view returns (uint256[] memory result) {
        SF404Storage storage $ = _getSF404Storage();
        uint256 n = $.addressData[owner].ownedLength;
        result = new uint256[](n);
        for (uint256 i; i < n; ++i) {
            uint256 id = _get($.owned[owner], i);
            result[i] = id;
            // Check invariants.
            require(_ownerAt(id) == owner);
            require(_get($.oo, _ownedIndex(id)) == i);
        }
    }

    function randomTokenOf(address owner, uint256 seed) public view returns (uint256) {
        SF404Storage storage $ = _getSF404Storage();
        uint256 n = $.addressData[owner].ownedLength;
        return _get($.owned[owner], seed % n);
    }

    function setGivePermit2DefaultInfiniteAllowance(bool value) public {
        givePermit2DefaultInfiniteAllowance = value;
    }

    function _givePermit2DefaultInfiniteAllowance() internal view virtual override returns (bool) {
        return givePermit2DefaultInfiniteAllowance;
    }

    function setUseDirectTransfersIfPossible(bool value) public {
        useDirectTransfersIfPossible = value;
    }

    function _useDirectTransfersIfPossible() internal view virtual override returns (bool) {
        return useDirectTransfersIfPossible;
    }

    function setUseExistsLookup(bool value) public {
        useExistsLookup = value;
    }

    function _useExistsLookup() internal view virtual override returns (bool) {
        return useExistsLookup;
    }

    function ownedIds(address owner, uint256 start, uint256 end)
        public
        view
        returns (uint256[] memory)
    {
        return _ownedIds(owner, start, end);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        SF404._transfer(_brutalized(from), _brutalized(to), amount);
    }

    function _transferFromNFT(address from, address to, uint256 id, address msgSender)
        internal
        virtual
        override
    {
        SF404._transferFromNFT(_brutalized(from), _brutalized(to), id, _brutalized(msgSender));
    }

    function _brutalized(address a) internal pure returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := or(0xf348aeebbad597df99cf9f4f0000000000000000000000000000000000000000, a)
        }
    }

    function _afterNFTTransfer(address from, address to, uint256 id) internal virtual override {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, from)
            mstore(0x20, to)
            mstore(0x10, id)
        }
    }
}
