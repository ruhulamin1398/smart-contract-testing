// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import{Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetWorkingConfig {
        address priceFeed;
    }
    uint8 DECIMALS = 8;
    int256 INITIAL_ANSWER = 2000e8;

    NetWorkingConfig private s_activeNetwork;

    constructor() {
        if (block.chainid == 11155111) {
            s_activeNetwork = getSepoliaETHConfig();
        } else {
            s_activeNetwork = createOrGetAnviConfig();
        }
    }

    function getSepoliaETHConfig()
        public
        pure
        returns (NetWorkingConfig memory)
    {
        NetWorkingConfig memory sepoliaPriceFeed = NetWorkingConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaPriceFeed;
    }

    function createOrGetAnviConfig()
        public
    
        returns (NetWorkingConfig memory)
    {
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS,INITIAL_ANSWER);
        vm.stopBroadcast();
        NetWorkingConfig memory anvilPriceFeed = NetWorkingConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilPriceFeed;
    }

    function getPriceFeed() public view returns (address) {
        return s_activeNetwork.priceFeed;
    }
}
