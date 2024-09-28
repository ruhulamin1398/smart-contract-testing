// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("user");
    uint256 constant INITIAL_BALANCE = 5 ether;
    uint256 constant FUND_AMOUNT = 1 ether;

    FundMe public fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollerIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundNotEnoughETH() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.fund();
    }

    modifier amountFund() {
        vm.deal(USER, INITIAL_BALANCE);
        vm.prank(USER);
        fundMe.fund{value: FUND_AMOUNT}();
        _;
    }

    function testFundAddresShouldAdded() public amountFund {
        assertEq(USER, fundMe.getFounder(0));
    }

    function testFundAmountShouldAdded() public amountFund {
        assertEq(FUND_AMOUNT, fundMe.getAddressToAmountFunded(USER));
    }

    function testOwnerCanWithdraw() public amountFund {
        vm.prank(msg.sender);
        uint256 OwnerAmount = msg.sender.balance;
        console.log(OwnerAmount);
        fundMe.withdraw();

        assertEq(FUND_AMOUNT+OwnerAmount, (msg.sender.balance));
    }

    function testOtherCanNotWithdraw() public amountFund {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }
}
