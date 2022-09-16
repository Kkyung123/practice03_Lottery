// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery{
	uint currenttime;
	uint16 lotteryNum;
	uint received_msg_value;
	bool claimis;
	bool drawis;
	address[] public members; //참여자
	address[] public winners; //당첨자
	
	mapping(address => uint16) public nums;
	mapping(address => uint) public balance; //wksdor

	//struct member
	//{
	//	uint value; //로또에 참여한 번호
	//	address addr; 
	//	uint balances; // 잔액
	//}

	constructor(){
		currenttime = block.timestamp;
		lotteryNum = 3;
		received_msg_value = 0;
		claimis = false;
		drawis = false;
	}
	
	//로또 참여
	function buy(uint16 _value) public payable{
		require(msg.value == 0.1 ether);
		if(claimis){
			currenttime = block.timestamp;
			drawis = false;
			claimis = false;
			members = new address[](0);
			winners = new address[](0);
		}

		//require(claimis == false);
		require(currenttime + 24 hours > block.timestamp);
		require(nums[msg.sender] != _value + 1);
		nums[msg.sender] = _value + 1;
		received_msg_value += msg.value;
		members.push(msg.sender);
	}

	//번호 확인해서 당첨자 구분
	function draw() public {
		require(claimis == false);
		require(currenttime + 24 hours <= block.timestamp);

		for (uint i=0; i < members.length; ++i) {
			address buyer = members[i];
			if (nums[buyer] - 1 == winningNumber()){
				winners.push(buyer);
			}
		}

		if(winners.length > 0){
			uint reward = received_msg_value / winners.length;
			for (uint i=0; i<winners.length; ++i){
				address buyer = winners[i];
				balance[buyer] += reward;
			}
		}

		drawis = true;
	}

	//맞출 경우 reward 전송
	function claim() public {
		require(drawis == true);
		claimis = true;

		uint amount = balance[msg.sender];
		balance[msg.sender] = 0;
		payable(msg.sender).call{value: amount}("");
	}
	
	//lotteryNum으로 당첨자 결정
	function winningNumber() public view returns(uint16){
		return lotteryNum;
	}
	
}	





