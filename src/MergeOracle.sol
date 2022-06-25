// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

IMergeOracle constant ADDRESS = IMergeOracle(address(0));

interface IMergeOracle {
    /// Returns the earliest block on which we know the merge was already active.
    function mergeBlock() external view returns (uint256);

    /// Returns the timestamp of the recorded block.
    function mergeTimestamp() external view returns (uint256);
}

contract MergeOracle is IMergeOracle {
    uint256 public immutable override mergeBlock = block.number;
    uint256 public immutable override mergeTimestamp = block.timestamp;
}

/// How to use this?
///
/// The `oracle` address is pre-calculated, but the account will be empty until the
/// merge takes place.
///
/// If you are interested to check if the merge took place, it is enough to check if the
/// oracle address has code in it. This can be achieved by `require(ADDRESS.code.length != 0);`.
///
/// If you also need to know what (a potential) merge block is, the oracle needs to be called
/// and ensured that a non-zero value is returned: `require(ADDRESS.mergeBlock() != 0);`
contract DidWeMergeYet {
    /// The merge is not here yet.
    error No();

    /// Merge already recorded.
    error AlreadyTrigerred();

    bytes32 private constant SALT = bytes32("The Merge called Paris");
    IMergeOracle public immutable oracle;

    constructor() {
        //oracle = MergeOracle(calculateCreate(address(this), 1));
        oracle = MergeOracle(calculateCreate2(address(this), keccak256(type(MergeOracle).creationCode), SALT));
        // Ensure we arrived at the correct value.
        // assert(oracle == ADDRESS);
    }

    function trigger() external returns (IMergeOracle _oracle) {
        // Based on EIP-4399 and the Beacon Chain specs, the mixHash field should be greater than 2**64.
        if (block.difficulty <= type(uint64).max) {
            revert No();
        }

        if (address(oracle).code.length != 0) {
            revert AlreadyTrigerred();
        }

        //_oracle = new MergeOracle();
        _oracle = new MergeOracle{salt: SALT}();
        assert(_oracle == oracle);
    }

    function calculateCreate(address from, uint256 nonce) private pure returns (address) {
        assert(nonce <= 127);
        bytes memory data =
            bytes.concat(hex"d694", bytes20(uint160(from)), nonce == 0 ? bytes1(hex"80") : bytes1(uint8(nonce)));
        return address(uint160(uint256(keccak256(data)))); // Take the lower 160-bits
    }

    function calculateCreate2(address creator, bytes32 codehash, bytes32 salt) private pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), creator, salt, codehash)))));
    }
}
