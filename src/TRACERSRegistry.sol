// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {ERC165} from "openzeppelin/utils/introspection/ERC165.sol";
import {OwnableAccessControl} from "tl-sol-tools/access/OwnableAccessControl.sol";
import {ITRACERSRegistry} from "src/ITRACERSRegistry.sol";

/// @title TRACERSRegistry
/// @notice Registry for TRACE Registered agents
/// @author transientlabs.xyz
/// @custom:version 3.0.0
contract TRACERSRegistry is OwnableAccessControl, ERC165, ITRACERSRegistry {
    /*//////////////////////////////////////////////////////////////////////////
                                State Variables
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(address => RegisteredAgent) private _registeredAgents; // registered agent address -> registered agent (global so should not use `numberOfStories`)
    mapping(address => mapping(address => RegisteredAgent)) private _registeredAgentOverrides; // nft contract -> registered agent address -> registered agent (not global so can use `numberOfStories` or `isPermanent`)

    /*//////////////////////////////////////////////////////////////////////////
                                Custom Errors
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev not creator or admin for nft contract
    error NotCreatorOrAdmin();

    /*//////////////////////////////////////////////////////////////////////////
                                Constructor
    //////////////////////////////////////////////////////////////////////////*/

    constructor() OwnableAccessControl() {}

    /*//////////////////////////////////////////////////////////////////////////
                                Registered Agent Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ITRACERSRegistry
    function setRegisteredAgent(address registeredAgentAddress, RegisteredAgent memory registeredAgent)
        external
        onlyOwner
    {
        // set `registeredAgent.numberOfStories` to 0
        registeredAgent.numberOfStories = 0;
        // set registered agent
        _registeredAgents[registeredAgentAddress] = registeredAgent;
        emit RegisteredAgentUpdate(msg.sender, registeredAgentAddress, registeredAgent);
    }

    /// @inheritdoc ITRACERSRegistry
    function setRegisteredAgentOverride(
        address nftContract,
        address registeredAgentAddress,
        RegisteredAgent calldata registeredAgent
    ) external {
        // restrict access to creator or admin
        OwnableAccessControl c = OwnableAccessControl(nftContract);
        if (c.owner() != msg.sender && !c.hasRole(ADMIN_ROLE, msg.sender)) revert NotCreatorOrAdmin();

        //set registered agent
        _registeredAgentOverrides[nftContract][registeredAgentAddress] = registeredAgent;
        emit RegisteredAgentOverrideUpdate(msg.sender, nftContract, registeredAgentAddress, registeredAgent);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                External Functions
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ITRACERSRegistry
    function isRegisteredAgent(address registeredAgentAddress) external returns (bool, string memory) {
        RegisteredAgent storage registeredAgent = _registeredAgents[registeredAgentAddress];
        RegisteredAgent storage registeredAgentOverride = _registeredAgentOverrides[msg.sender][registeredAgentAddress];

        if (registeredAgentOverride.isPermanent) {
            return (true, registeredAgentOverride.name);
        } else if (registeredAgentOverride.numberOfStories > 0) {
            registeredAgentOverride.numberOfStories--;
            return (true, registeredAgentOverride.name);
        } else if (registeredAgent.isPermanent) {
            return (true, registeredAgent.name);
        } else {
            return (false, "");
        }
    }

    /// @inheritdoc ITRACERSRegistry
    function getRegisteredAgent(address nftContract, address registeredAgentAddress)
        external
        view
        returns (RegisteredAgent memory registeredAgent)
    {
        RegisteredAgent storage registeredAgentGlobal = _registeredAgents[registeredAgentAddress];
        RegisteredAgent storage registeredAgentOverride = _registeredAgentOverrides[nftContract][registeredAgentAddress];

        if (registeredAgentOverride.isPermanent || registeredAgentOverride.numberOfStories > 0) {
            registeredAgent = registeredAgentOverride;
        } else {
            registeredAgent = registeredAgentGlobal;
        }
        return registeredAgent;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    ERC165
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return ERC165.supportsInterface(interfaceId) || interfaceId == type(ITRACERSRegistry).interfaceId;
    }
}
