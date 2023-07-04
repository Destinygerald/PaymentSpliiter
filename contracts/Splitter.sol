//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Splitter{

	event PaymentMethodCreated(
		address creator,
		uint id,
		address payable[] payees,
		uint[] payRatio
	);

	event AddedPayee(
		uint id,
		address payable payee,
		uint payRatio
	);

	event RemovedPayee(
		uint id,
		address payee
	);

	event PaymentMade(
		uint id,
		uint amount
	);
	

	struct Payment {
		address creator;
		uint id;
		address payable[] payees;
		uint[] payRatio;
	}

	Payment[] payments;

	mapping (uint => uint[]) balances;
	

	function  createPaymentMethod
	(
		address payable[] memory _payees, 
		uint[] memory _payRatio
	) 
		external 
		returns (uint)
	{	
		require(_payees.length <= 20,"20 is the Maximum number of payees");
		require(_payees.length == _payRatio.length,"Unbalanced");
		uint _id = payments.length;

		payments.push(Payment({
			creator: msg.sender,
			id: _id,
			payees: _payees,
			payRatio: _payRatio
			}));

		emit PaymentMethodCreated(msg.sender, _id, _payees, _payRatio);
		return _id;
	}

	function addPayee
	(
		uint _id, 
		address payable _payee, 
		uint _payRatio
	)
		external
	{
		require(_id <= payments.length, "Invalid ID");		
		Payment storage _payment = payments[_id];
		require(_payment.payees.length < 20, "Exceeds limit");

		_payment.payees.push(_payee);
		_payment.payRatio.push(_payRatio);

		emit AddedPayee(_id, _payee, _payRatio);
	} 

	function removePayee
	(
		uint _id,
		address payee
	)
		external
	{
		require(_id <= payments.length, "Invalid ID");
		
		Payment memory _payment_ = payments[_id];
		Payment storage _payment = payments[_id];	

		uint len = _payment.payees.length;
		uint payeeIndex;
		for(uint i = 0; i < len; i++){
			if(_payment.payees[i] == payee){
				payeeIndex = i;
				// break;
			}
			//revert("Invalid address");
		}

		for(uint i = 0; i < len - 1; i++){
			if(i < payeeIndex){
				_payment.payees[i] = _payment_.payees[i];
			}
			else{	
				_payment.payees.pop();

				_payment.payees[i] = _payment_.payees[i + 1];
			}
		}

		for(uint i = 0; i < len - 1; i++){
			if(i < payeeIndex){
				_payment.payRatio[i] = _payment_.payRatio[i];
			}
			else{	
				_payment.payRatio.pop();

				_payment.payRatio[i] = _payment_.payRatio[i + 1];
			}
		}

		emit RemovedPayee(_id, payee);

	}
	
	
	function makePayment
	(
		uint _id
	)
		external
		payable
	{
		require(_id <= payments.length, "Invalid ID");
		require(msg.value > 0, "Send some ether");

		Payment memory _payment = payments[_id];
		//require(msg.sender == _payment.creator, "Not creator");

		uint ratioTotal;

		for(uint i = 0; i < _payment.payRatio.length; i++){
			ratioTotal += _payment.payRatio[i];
		}

		for(uint i = 0; i < _payment.payees.length; i++){
			uint _amount = msg.value * _payment.payRatio[i] / ratioTotal;
			_payment.payees[i].transfer(_amount);
		}

		emit PaymentMade(_id, msg.value);
	}

	
	function getPaymentMethod(uint _id)
		external
		view
		returns(Payment memory)
	{
		return payments[_id];
	}
	
	function getPayeeNumber(uint _id)
		external
		view
		returns(uint)
	{
		return payments[_id].payees.length;
	}

	// function getPayeeBalances(uint _id)
	// 	external
	// 	returns(uint)
	// {

	// 	Payment memory _payment = payments[_id];
	// 	for(uint i = 0; i < _payment.payees.length; i++){
	// 		balances[_id].push(_payment.payees[i].balance);
	// 	}

	// 	uint[] memory balance = balances[_id];
	// 	return balance[0];
	// }
	
}