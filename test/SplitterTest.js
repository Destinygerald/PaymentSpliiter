const Splitter = artifacts.require("Splitter");
const Web3 = require('web3')
const web3 = new Web3("http://127.0.0.1:9545/");

contract("Splitter", (accounts) => {

	let splitter;

	before(async() => {
		splitter = await Splitter.deployed()
	});

	it('Should Create Payment Method', async() => {
		let accountArray = [accounts[1], accounts[2], accounts[3]];
		let ratioArray = [1, 2, 5];
		await splitter.createPaymentMethod(accountArray, ratioArray);
	});

	it('Should add payee', async() => {
		let newAccount1 = accounts[4];
		let newAccount2 = accounts[5];

		await splitter.addPayee(0, newAccount1, 3);
		await splitter.addPayee(0, newAccount2, 2);
	});

	it('Should remove payee', async() => {
		let newAccount = accounts[4];

		await splitter.removePayee(0, newAccount);
	})

	it('Should get Payment Method', async() => {
		let paymetMethod = await splitter.getPaymentMethod(0);

		console.log(paymetMethod);
	})

	it('Should get amount of Payees', async() => {
		let payeesNumber = await splitter.getPayeeNumber(0);

		console.log(payeesNumber.toString(10));
	})

	it('Should make Payment', async() => {
		await splitter.makePayment(0,{value: web3.utils.toWei('2', 'ether')})
	})

	it('Should get balances of Payees', async() => {
	
		await web3.eth.getBalance(
				accounts[1],(err, res) => { 
				console.log(res)
		});

		await web3.eth.getBalance(
				accounts[2],(err, res) => { 
				console.log(res)
		});

		await web3.eth.getBalance(
				accounts[3],(err, res) => { 
				console.log(res)
		});

		await web3.eth.getBalance(
				accounts[5],(err, res) => { 
				console.log(res)
		});

			
	})
})