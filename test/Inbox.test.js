// Functional tests for the contracts
const assert = require('assert');
const ganache = require('ganache-cli');

const Web3 = require('web3'); // constructor 

// Ganache supplies provider
// Ganache creates accounts to use - acts as the account for user 
const web3 = new Web3(ganache.provider());

const {interface, bytecode} = require('../compile');

let accounts;
let inbox;

beforeEach(async () => {
    // Get a list of all accounts
    accounts = await web3.eth.getAccounts(); // eth stands for ethereum
    console.log(accounts);

    // Use one of these accounts to deploy the contract
    inbox = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({data: bytecode, arguments: [1]}) // arguments are passed into the constructor
        .send({from: accounts[0], gas: '1000000'}); // Using first account for deployment
    console.log(inbox);
});

// Deploy contract to ganache, manipulate contract and assert
describe('Campaign', () => {
    it('accounts not null', () => { assert.notEqual(accounts, null); });

    it('deploys a contract', () => { 
        assert.notEqual(inbox, null);
        assert.ok(inbox.options.address); // exists
    });
});
