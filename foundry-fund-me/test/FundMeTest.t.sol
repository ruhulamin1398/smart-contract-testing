// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import  {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    
    function setUp() external {
        fundMe = new FundMe("0x694AA1769357215DE4FAC081bf1f309aDC325306");

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