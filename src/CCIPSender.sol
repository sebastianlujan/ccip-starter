// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice CCIPSender contract, unsafe to use
/// @dev not for production use
contract CCIPSender is Ownable {

    address link;
    IRouterClient private _routerClient;
    IERC20 private _linkToken;

    // @notice Contructor initializes the contract with the router address
    // @param _router address of the router contract
    // @param _link address of the LINK token
    constructor(address _link, address _router) Ownable(msg.sender) {
        _linkToken = IERC20(_link);
        _routerClient = IRouterClient(_router);
    }


    // @notice Sends data to receiver on the destination chain
    // @param receiver address of the receiver
    // @param destinationChainSelector , the selector for the destination chain
    // @param text data to send
    function send(
        address receiver,
        uint64 destinationChainSelector,
        string calldata text
    ) external onlyOwner {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage(
            {
                receiver: abi.encode(receiver), 
                data: abi.encode(text),
                tokenAmounts: new Client.EVMTokenAmount[](0),
                extraArgs: "",
                feeToken: address(_linkToken)
            }
        );
        // sends a message to the destination chain and returns a message ID
        _routerClient.ccipSend(destinationChainSelector, message);
    }
}
