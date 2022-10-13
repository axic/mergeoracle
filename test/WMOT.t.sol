pragma solidity 0.8.14;

import "forge-std/Test.sol";

import "src/WMOT.sol";

address constant MINTER = 0xB578405Df1F9D4dFdD46a0BD152D518d4c5Fe0aC;
ERC721 constant mot = ERC721(0xc86E1A7a4AA5A9B17f6997a59B311835fc95e975);

contract WMOTTest is Test {
    WMOT public wmot;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));
        wmot = new WMOT();
    }

    // Fork test
    function testWrap() public {
        assertEq(wmot.balanceOf(MINTER), 0);
        vm.startPrank(MINTER);
        mot.approve({spender: address(wmot), id: 1});
        wmot.wrap();
        vm.stopPrank();

        assertEq(mot.ownerOf(1), address(wmot));
        assertEq(mot.balanceOf(address(wmot)), 1);
        assertEq(wmot.balanceOf(MINTER), 1);
        assertEq(wmot.ownerOf(1), MINTER);
    }

    function testUnWrap() public {
        testWrap();
        vm.prank(MINTER);
        wmot.unwrap();

        assertEq(mot.ownerOf(1), MINTER);
        assertEq(mot.balanceOf(MINTER), 1);
        assertEq(mot.balanceOf(address(wmot)), 0);
        assertEq(wmot.balanceOf(MINTER), 0);
    }

    function testUnWrapWrongSender() public {
        testWrap();
        vm.prank(address(0xdead));
        vm.expectRevert(NotMotter.selector);
        wmot.unwrap();
    }

    function testWrapWrongSender() public {
        vm.prank(address(0xdead));
        vm.expectRevert();
        wmot.wrap();
    }

    function testTokenUri() public view {
        wmot.tokenURI(1);
    }

    function testTokenUriRevert() public {
        vm.expectRevert();
        wmot.tokenURI(0);
        vm.expectRevert();
        wmot.tokenURI(2);
    }
}
