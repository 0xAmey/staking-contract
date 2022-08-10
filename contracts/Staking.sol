// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*----------------------------------*/
/*             Errors               */
/*----------------------------------*/

error Staking__NoRewardsAccumalated();

// The formula for calculating the rewards, here no of tokens staked is constant between time interval a and b,
// where time a is when token is staked and time b is the withdraw time, L(t) is the total tokens staked
// Rewards = Reward Rate * tokens staked * (Summation of 1/L(t) from time a till time b - summation of 1/L(t) from time 0 to time a-1)
// here the first part of the equation let's call it s is computed and stored globally for all users
// the second part of the equation is stored per user depeding on the time when they staked the tokens i.e a-1

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
    uint256 private lastCall;

    //summation of reward rate / total supply staked (s)
    uint256 public rewardsPerTokenStored;

    //stores rewardsPerToken when the address first interacts with contract p[user]
    mapping(address => uint256) public rewardsPerTokenPaid;

    //storing the amount of rewards belonging to a certain address
    mapping(address => uint256) rewards;

    //total number of tokens staked in the contract L(t)
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

    //calculating summation of R * 1/L(t) (see top for math)
    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return 0;
        }
        return
            //scaling upto 1e18 for calculations
            rewardsPerTokenStored +
            ((rewardRate * (block.timestamp - lastCall) * 1e18) / totalStaked);
    }

    // translating over the equation (top) into code
    function earned(address account) public view returns (uint256) {
        return
            //scaling down 1e18 because we had earlier multiplied by 1e18 for calculations
            ((userBalance[account] * (rewardPerToken() - rewardsPerTokenPaid[account])) / 1e18) +
            rewards[account];
    }

    // everytime a user calls stake, withdraw or getReward the rewards need to be re-calculated and variables updated,
    // to do that this modifier will be attached to all those functions
    modifier updateReward(address account) {
        rewardsPerTokenStored = rewardPerToken();
        lastCall = block.timestamp;
        rewards[account] = earned(account);
        //update the token rewards paid to user
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

        // reverts if the rewards accumalated are zero
        if (rewards[msg.sender] == 0) {
            revert Staking__NoRewardsAccumalated();
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

    function getLastCall() public view returns (uint256) {
        return lastCall;
    }
}
