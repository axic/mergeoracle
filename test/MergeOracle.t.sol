// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {DidWeMergeYet, IMergeOracle} from "../src/MergeOracle.sol";

interface Cheat {
    function difficulty(uint256) external;
}

contract MergeOracleTest is Test {
    DidWeMergeYet dwmy;

    function setUp() public {
        vm.prank(0xC3Fd1C7d2eF0bFeccAc029e5498D2dFFee39790b);
        dwmy = new DidWeMergeYet();
        assertEq(address(dwmy), 0xc86E1A7a4AA5A9B17f6997a59B311835fc95e975);
    }

    function testTriggerFail() public {
        Cheat(address(vm)).difficulty(14161651193727183); // block 14981244
        vm.expectRevert(0x6f726dda);
        dwmy.trigger();
    }

    function testTriggerSuccess() public {
        assertEq(dwmy.balanceOf(address(this)), 0);

        // Set difficulty within range of PREVRANDAO
        Cheat(address(vm)).difficulty(uint256(type(uint64).max) + 1);
        address expectedOracle = 0xD6a6f0D7f08c2D31455a210546F85DdfF1D9030a;
        assertTrue(expectedOracle.code.length == 0);
        assertEq(address(dwmy.trigger()), expectedOracle);
        assertTrue(expectedOracle.code.length != 0);
        assertTrue(IMergeOracle(expectedOracle).mergeBlock() != 0);
        assertEq(IMergeOracle(expectedOracle).mergeTimestamp(), block.timestamp);

        assertEq(dwmy.balanceOf(address(this)), 1);
    }

    function testNFT() public {
        assertEq(dwmy.name(), "Merge Oracle Triggerer");
        assertEq(dwmy.symbol(), "MOT");
        assertEq(dwmy.tokenURI(1), "ipfs://QmcnZk7CrAeS2NcY62FUcoH9knbTS1HK8mdYbshwF1S8kh");
    }
}
