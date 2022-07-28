// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IERC20.sol';
import "@openzeppelin/contracts/utils/math/Math.sol";

contract AutomatedMarketMaker {
    IERC20 public immutable token1;
    IERC20 public immutable token2;

    uint public reserve1;
    uint public reserve2;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token1, address _token2){
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    function mint(address _to, uint _amount) private{
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function burn(address _from, uint _amount) private{
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function swap(address _tokenIn, uint _amountIn) external returns(uint amountOut){
        require(
            _tokenIn == address(token1) ||
            _tokenIn == address(token2),
            "Invalid tokenIn inside swap"
        );
        require(_amountIn >0, "_amountIn is 0");

        bool isToken1 = _tokenIn == address(token1);
        (IERC20 tokenIn, IERC20 tokenOut, uint reserverIn, uint reserveOut) = isToken1 ? (token1, token2, reserve1, reserve2) : (token2, token1, reserve2, reserve1);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        uint amountInWithFee = (_amountIn*997)/1000;
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        tokenOut.Transfer(msg.sender, amountOut);

        _update(
            token1.balanceOf(address(this)),
            token2.balanceOf(address(this))
        );
    }

    function _update(uint _reserve1, uint _reserve2) internal{
        reserve1 = _reserve1;
        reserve2 = _reserve2;
    }
    function addLiquidity(uint _amount1, uint _amount2) external returns(uint shares){
        //pull in token1 and token2
        token1.transferFrom(msg.sender, address(this), _amount1);
        token2.transferFrom(msg.sender, address(this), _amount2);

        //dy/dx = y/x
        if(reserve1 >0 || reserve2 >0){
            require(reserve1 * _amount2 == reserve2 * _amount1, "dy/dx != y/x");
        }   
        if(totalSupply == 0){
            shares = sqrt(_amount1 * _amount2)
        } else {
            share = _min(
                (_amount1 * totalSupply) / reserve1,
                (_amount2 * totalSupply) / reserve2,
            )
        }
        require(shares > 0, "share is = 0");
        _mint(msg.sender, shares)

        _update(
            token1.balanceOf(address(this));
            token2.balanceOf(address(this));
        );
    }

    function _min(uint x, uint y) private pure returns (uint){
        return x<=y ? x : y;
    }

    function removeLiquidity() external{
        
    }
}