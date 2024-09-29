// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A Raffle contract
 * @author Ruhul Amin
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {
    /** Errors  */
    error Raffile_SendMoreToEnterRaffle();
    error Ruffle_TransferFailed();
    error Raffle_RaffleNotOpen();

    /** Type Declarations */

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /** State Variables */

    uint16 constant REQUEST_CONFIRMATION = 3;
    uint32 constant NUMBER_WORDS = 1;

    uint256 private immutable i_enterenceFee;
    // @dev duration of the lottery in seconds
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subsrciptionId;
    uint32 private immutable i_callBackLimit;
    uint256 private s_lastTimeStamp;

    address payable[] private s_players;
    address payable s_winner;

    RaffleState private s_raffleState;
    //** Events */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 enterenceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callBackLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_enterenceFee = enterenceFee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subsrciptionId = subscriptionId;
        i_callBackLimit = callBackLimit;

        s_lastTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        if (msg.value < i_enterenceFee) {
            revert Raffile_SendMoreToEnterRaffle();
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle_RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    // 1. Get a Random Number
    // 2. use Random number to pic Winner
    // 3. Be automatically called
    function pickWinner() public {
        // check enought time spend
        if (block.timestamp - s_lastTimeStamp > i_interval) {
            revert();
        }
        s_raffleState = RaffleState.CALCULATING;


        // get random number form chainlink v2.5
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subsrciptionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_callBackLimit,
                numWords: NUMBER_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

// CEI Checks, Effects, Interations Patten
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {


        // Checks 


        // Effects (Internal Contract States)

        uint256 indexofWoner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexofWoner];
        s_winner = recentWinner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        emit WinnerPicked(s_winner);


        // Interations  (External contract Interaction )
        (bool success, ) = recentWinner.call{value: address(this).balance}("");

        if (!success) {
            revert Ruffle_TransferFailed();
        }
    }

    /** Getter Funcions  */
}
