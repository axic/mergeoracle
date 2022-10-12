// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "solmate/tokens/ERC721.sol";

/// Error when calling unwrap without owning the 1/1 WMOT token.
error NotMotter();

/// Wraps the Merge Oracle Triggerer with a rich metadata format
contract WMOT is ERC721("Wrapped Merge Oracle Triggerer", "WMOT") {
    /// Address of the original Merge Oracle Trigger or `DidWeMergeYet` contract.
    ERC721 public constant MOT = ERC721(0xc86E1A7a4AA5A9B17f6997a59B311835fc95e975);
    /// Returns the deployer or the WMOT contract.
    /// The contract is permissionless.
    /// This function exists purely for interoperability with NFT marketplaces.
    address public immutable owner = msg.sender;

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

    function tokenURI(uint256 id) public pure override returns (string memory) {
        require(id == 1);
        // TODO Reject ids?
        // TODO come up with the ipfs hash
        return "";
    }
}
