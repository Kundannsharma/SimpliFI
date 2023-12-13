const express = require('express');
const mongoose = require('mongoose');
const {Web3} = require('web3');
const myTokenABI = require('./tokenABI.json');
const productStoreABI = require('./nft.json');


const app = express();
const port = 3000;

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/mydatabase', { useNewUrlParser: true, useUnifiedTopology: true });

const eventSchema = new mongoose.Schema({
  buyer: String,
  ethAmount: String,
  tokenAmount: String,
  productId: String,
  amountPaid: String,
}, { timestamps: true });

const Event = mongoose.model('Event', eventSchema);

const web3 = new Web3('https://eth-sepolia.g.alchemy.com/v2/ROZVbXzA7U4aA4_2ZDLEQqdxjmmfV_Yu');

const myTokenAddress = '0x8047D171b62156A64bCa74E0372C7BBf935D7179'; // Replace with your MyToken contract address
const myTokenContract = new web3.eth.Contract(myTokenABI, myTokenAddress);

const productStoreAddress = '0x4ea5E51b62e71661fF89e5A0b38d407594Ebc34F'; // Replace with your ProductStore contract address
const productStoreContract = new web3.eth.Contract(productStoreABI, productStoreAddress);

// Listen for BuyToken event from MyToken
myTokenContract.events.BuyToken()
  .on('data', async (event) => {
    const { buyer, ethAmount, tokenAmount } = event.returnValues;

    // Store data in MongoDB
    await Event.create({ buyer, ethAmount, tokenAmount });
  })
  .on('error', console.error);

// Listen for BuyProduct event from ProductStore
productStoreContract.events.BuyProduct()
  .on('data', async (event) => {
    const { buyer, productId, amountPaid } = event.returnValues;

    // Store data in MongoDB
    await Event.create({ buyer, productId, amountPaid });
  })
  .on('error', console.error);

// Express API routes
app.get('/token-buy-events', async (req, res) => {
  const events = await Event.find();
  res.json(events);
});

app.get('/product-buy-events', async (req, res) => {
  const events = await Event.find();
  res.json(events);
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
