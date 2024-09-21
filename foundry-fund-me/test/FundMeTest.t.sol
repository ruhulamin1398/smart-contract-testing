// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import  {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

    }
    function testMinimumDollerIsFive() view public {  
        assertEq(fundMe.MINIMUM_USD(), 5e18);
         
    }
    function testOwner() view public {
        assertEq(fundMe.i_owner(),address(this));
    }
    function testPriceFeedVersionIsAccurate() view public {
        uint256  version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);

    }
     
     
}