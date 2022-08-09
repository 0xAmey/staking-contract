// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*----------------------------------*/
/*             Errors               */
/*----------------------------------*/

error Staking__NoRewardsYet();

contract Staking {
    /*----------------------------------*/
    /*      Variables and Mappings      */
    /*----------------------------------*/

    // declaring the staking and rewards token
    IERC20 private rewardsToken;
    IERC20 private stakingToken;

    //declaring the rate at which the rewards will be given out (per second)
    uint256 public rewardRate = 100;

    //keeping track of when was the last time contract was called
    uint256 public lastCall;

    //summation of reward rate / total supply staked (see last for math)
    uint256 public rewardsPerTokenStored;

    //stores rewardsPerToken when the address first interacts with contract
    mapping(address => uint256) public rewardsPerTokenPaid;

    //storing the amount of rewards belonging to a certain address (see last for math)
    mapping(address => uint256) rewards;

    //total number of tokens staked in the contract
    uint256 public totalStaked;

    //number of tokens staked per user
    mapping(address => uint256) private userBalance;

    /*----------------------------------*/
    /*            Constructor           */
    /*----------------------------------*/

    //initializing the addrssess of staking token and reward tokens
    constructor(address _stakingToken, address _rewardsToken) {
        // typecasting the address to become ERC-20 tokens or getting the token by inputting the addres
        //(or smth like that, not completely sure but it always works)
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    /*----------------------------------*/
    /*            Functions             */
    /*----------------------------------*/

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return 0;
        }
        return
            rewardsPerTokenStored +
            ((rewardRate * (block.timestamp - lastCall) * 1e18) / totalStaked);
    }

    function earned(address account) public view returns (uint256) {
        return
            ((userBalance[account] * (rewardPerToken() - rewardsPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    // everytime a user calls stake, withdraw or getReward the rewards need to be re-calculated,
    // to do that this modifier will be attached to all those functions
    modifier updateReward(address account) {
        rewardsPerTokenStored = rewardPerToken();
        lastCall = block.timestamp;

        rewards[account] = earned(account);
        rewardsPerTokenPaid[account] = rewardsPerTokenStored;
        _;
    }

    // stake tokens in contract
    function stake(uint256 amount) external updateReward(msg.sender) {
        totalStaked += amount;
        userBalance[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    // withdraw funds
    function withdraw(uint256 amount) external updateReward(msg.sender) {
        totalStaked -= amount;
        userBalance[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }

    // withdraw the accumalated rewards
    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);

        if (rewards[msg.sender] == 0) {
            revert Staking__NoRewardsYet();
        }
    }

    /*----------------------------------*/
    /*          Getter functions        */
    /*----------------------------------*/

    function getStakingTokenAddress() public view returns (address) {
        return address(stakingToken);
    }

    function getRewardsTokenAddress() public view returns (address) {
        return address(rewardsToken);
    }
}
