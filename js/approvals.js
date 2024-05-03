const ethers = require('ethers')


    const start = async()=>{
        console.log('Starting approvals...')

        const fs = require('fs')

        require('dotenv').config()

        const path = require('path')

        const chainData  = JSON.parse( fs.readFileSync( path.resolve(__dirname, 'chainData.json') ) )

        console.log('Connecting to Avalanche Fuji Testnet...')
        const rpc = process.env.FUJI_RPC_URL;
        const prik = process.env.FUJI_ACCOUNT_PRIVATE_KEY

        console.log("Updatng chaindata object with Fuji Messenger Address...")
        const messengerFuji = process.env.FUJI_MESSENGER_ADDRESS
        chainData.chains[0].messengerAddress = messengerFuji

        const linkFuji = chainData.chains[0].LINKTokenAddress;

        let providerFj = new ethers.WebSocketProvider(rpc);
        let walletFj = new ethers.Wallet(prik, providerFj);

        const blkFj = await providerFj.getBlockNumber()
        console.log('Connected to Avalanche Fuji Testnet! Block:', blkFj)

        const abi =
        [
            "function approve(address,uint256)",
            "function allowance(address,address) view returns (uint256)"
        ]

        const linkCtrtFj = new ethers.Contract(linkFuji, abi, walletFj);

        const linkAllowanceFj = await linkCtrtFj.allowance(walletFj.address, messengerFuji)
        console.log('LINK allowance:', linkAllowanceFj.toString())

        if( linkAllowanceFj.toString() == '0' ){
            console.log('Approving LINK...')
            const tx = await linkCtrtFj.approve(messengerFuji, ethers.parseEther('2000000000000000000') );
            console.log('Approve tx:', tx.hash)

            const receipt = await tx.wait()
            console.log('Approve receipt:', receipt)

        }

        providerFj = null
        walletFj = null

        console.log('Connecting to Ethereum Sepolia Testnet...')
        const rpcS = process.env.SEPOLIA_RPC_URL;
        const prikS = process.env.SEPOLIA_ACCOUNT_PRIVATE_KEY

        console.log("Updatng chaindata object with Sepolia Messenger Address...")
        const messengerSepolia = process.env.SEPOLIA_MESSENGER_ADDRESS
        chainData.chains[1].messengerAddress = messengerSepolia
   

        const linkSepolia = chainData.chains[1].LINKTokenAddress;
        const providerSepolia = new ethers.WebSocketProvider(rpcS);
        const walletSp = new ethers.Wallet(prikS, providerSepolia);

        const blkSp = await providerSepolia.getBlockNumber()
        console.log('Connected to Ethereum Sepolia Testnet! Block:', blkSp)

        const linkCtrtSp = new ethers.Contract(linkSepolia, abi, walletSp);

        const linkAllowanceSp = await linkCtrtSp.allowance(walletSp.address, messengerSepolia)
        console.log('LINK allowance:', linkAllowanceSp.toString())

        if( linkAllowanceSp.toString() == '0' ){
            console.log('Approving LINK...')
            const tx = await linkCtrtSp.approve(messengerSepolia, ethers.parseEther('2000000000000000000') );
            console.log('Approve tx:', tx.hash)

            const receipt = await tx.wait()
            console.log('Approve receipt:', receipt)

        }

        console.log('Approvals done! \n Saving chainData object...')
        fs.writeFileSync( path.resolve(__dirname, 'chainData.json'), JSON.stringify(chainData, null, 2) )
        console.log('chainData object saved!')
    }

start()
