// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IERC20.sol';

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
    function addLiquidity() external{
        
    }

    function removeLiquidity() external{
        
    }
}