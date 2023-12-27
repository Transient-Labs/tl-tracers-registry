// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {OwnableAccessControl} from "tl-sol-tools/access/OwnableAccessControl.sol";

contract Mock721OwnableAccessControl is OwnableAccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor(address initOwner, address[] memory admins) OwnableAccessControl() {
        _transferOwnership(initOwner);
        _setRole(ADMIN_ROLE, admins, true);
    }
}
