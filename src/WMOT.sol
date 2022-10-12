// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "solmate/tokens/ERC721.sol";

import "./Base64.sol";

/// Error when calling unwrap without owning the 1/1 WMOT token.
error NotMotter();

/// Invalid token id.
error InvalidTokenId();

/// Wraps the Merge Oracle Triggerer with a rich metadata format
contract WMOT is ERC721("Wrapped Merge Oracle Triggerer", "WMOT") {
    /// Address of the original Merge Oracle Trigger or `DidWeMergeYet` contract.
    ERC721 public constant MOT = ERC721(0xc86E1A7a4AA5A9B17f6997a59B311835fc95e975);

    /// Address of the Merge Oracle.
    address public constant Oracle = 0xD6a6f0D7f08c2D31455a210546F85DdfF1D9030a;

    /// Returns the deployer or the WMOT contract.
    /// The contract is permissionless.
    /// This function exists purely for interoperability with NFT marketplaces.
    address public immutable owner = msg.sender;

    constructor() {
        assert(Oracle == MOT.oracle());
    }

    function wrap() external {
        if (MOT.ownerOf(1) != msg.sender) revert NotMotter();

        MOT.transferFrom({from: msg.sender, to: address(this), id: 1});
        _mint({to: msg.sender, id: 1});
    }

    function unwrap() external {
        if (ownerOf(1) != msg.sender) revert NotMotter();

        _burn(1);
        MOT.transferFrom(address(this), msg.sender, 1);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        if (id != 1) revert InvalidTokenId();
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            "{",
                            '"name":"Wrapped Merge Oracle Triggerer",',
                            '"description":"The 1/1 NFT minted on the merge block that deployed the merge oracle. The merge oracle is a contract that can only be deployed after the merge has happened. The 1/1 NFT was minted to the address that triggered the deploy.",',
                            '"image": "',
                            MOT.tokenURI(1),
                            '",',
                            '"attributes": [',
                            '{ "trait_type": "mergeBlock", "value": ',
                            Oracle.mergeBlock(),
                            " },",
                            '{ "trait_type": "mergeTimestamp", "value": ',
                            Oracle.mergeTimestamp(),
                            " },",
                            '{ "trait_type": "MergeOracle", "value": "0xD6a6f0D7f08c2D31455a210546F85DdfF1D9030a" }',
                            "]",
                            "}"
                        )
                    )
                )
            )
        );
    }
}
