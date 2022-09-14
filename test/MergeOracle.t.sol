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
        // Set difficulty within range of PREVRANDAO
        Cheat(address(vm)).difficulty(uint256(type(uint64).max) + 1);
        address expectedOracle = 0x4a60eB1D95B4C6523148a1CbF2F183286b1BB95C;
        assertTrue(expectedOracle.code.length == 0);
        assertEq(address(dwmy.trigger()), expectedOracle);
        assertTrue(expectedOracle.code.length != 0);
        assertTrue(IMergeOracle(expectedOracle).mergeBlock() != 0);
        assertEq(IMergeOracle(expectedOracle).mergeTimestamp(), block.timestamp);
    }
}
