// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    // some list of addresses
    // Allow someone in the list to claim ERC-20 tokens

    error MerkelAirdrop__InvalidProof();
    error MerkelAirdrop__AlreadyClaimed();

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    event Claimed(address account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkelProof) external {
        if (s_hasClaimed[account]) {
            revert MerkelAirdrop__AlreadyClaimed();
        }
        // calculate using account and the amount, the hash -> leaf node
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkelProof, i_merkleRoot, leaf)) {
            revert MerkelAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claimed(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMerkelRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
