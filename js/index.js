const ethers = require('ethers')


    const start = async()=>{
        console.log('CCIP Messenger started!')



        const arg  = parseInt( process.argv[2] )

        require('dotenv').config()
        const fs = require('fs')
        const path = require('path')

        chainData  = JSON.parse( fs.readFileSync( path.resolve(__dirname, 'chainData.json') ) )

        
        if( arg == 0 ){
            console.log('Connecting to Avalanche Fuji Testnet...')
            const rpc = process.env.FUJI_RPC_URL;
            const prik = process.env.FUJI_ACCOUNT_PRIVATE_KEY

            const messengerAddress = chainData.chains[0].messengerAddress;

            const provider = new ethers.providers.JsonRpcProvider(rpc);
            const wallet = new ethers.Wallet(prik, provider);

            console.log('Connected to Avalanche Fuji Testnet!')

            const abi = 
            [
                "function sendMessage(uint64,address,bytes)",
                "event MessageSent(bytes32,uint64,address,bytes,address,uint256)",
                "event MessageReceived(bytes32,uint64,address,bytes)",
                "event MessageAcknowledged(bytes32,uint64,address,bytes)",
                "event ErrorReceived(bytes32,uint64,address,bytes)"
            ]

            //subscribe to events
            const msgrCtrt = new ethers.Contract(messengerAddress, abi, provider);
            msgrCtrt.on('MessageSent', (msgId, chain, dest, msg, feeToken, fee) => {
                console.log('Message [', msgId, '] to chain <', chain, '>:<', dest, '> sent.'); 
                console.log('Message: ', msg)
            })
            msgrCtrt.on('MessageReceived', (msgId, chain, src, msg) => {
                console.log('Message [', msgId, '] from chain <', chain, '> received from <', src, '>');
                console.log("Message:", msg)
                const chId = chainData.chains[0].chainlinkId
                const rcvr = chainData.chains[0].messengerAddress
                const data = ethers.toUtf8Bytes('Hola Don José!')
                
                msgrCtrt.sendMessage(chId, rcvr, data).then( (tx) => {
                    console.log('Transaction with Message sent. Tx:', tx.hash)
                }).catch( (err) => {
                    console.log('Error sending message:', err)
                })
            })
            msgrCtrt.on('MessageAcknowledged', (msgId, chain, dest, msg) => {
                console.log('Message [', msgId, '] to chain <', chain, '> to <', dest, '> acknowledged');
                console.log("Message:", msg)
            })
            msgrCtrt.on('ErrorReceived', (msgId, chain, dest, msg) => {
                console.log('Message [', msgId, '] to chain <', chain, '> to <', dest, '> errored');
                console.log("Message:", msg)
            })

            const chId = chainData.chains[1].chainlinkId
            const dest = chainData.chains[1].messengerAddress
            const data = ethers.toUtf8Bytes('Hola Don Pepito!')
            
            msgrCtrt.sendMessage(chId, dest, data).then( (tx) => {
                console.log('Transaction with Message sent. Tx:', tx.hash)
            }).catch( (err) => {
                console.log('Error sending message:', err)
            })

        }
        else if( arg == 1 ){
            const prik = process.env.SEPOLIA_ACCOUNT_PRIVATE_KEY
            console.log('TODO: sepolia')
            console.log('Connecting to Ethereum Sepolia Testnet...')
            const rpc = process.env.SEPOLIA_RPC_URL;

            const messengerAddress = chainData.chains[1].messengerAddress;

            const provider = new ethers.providers.JsonRpcProvider(rpc);
            const wallet = new ethers.Wallet(prik, provider);

            console.log('Wallet Address:', wallet.address)

            const abi = 
            [
                "function sendMessage(uint64,address,bytes)",
                "event MessageSent(bytes32,uint64,address,bytes,address,uint256)",
                "event MessageReceived(bytes32,uint64,address,bytes)",
                "event MessageAcknowledged(bytes32,uint64,address,bytes)",
                "event ErrorReceived(bytes32,uint64,address,bytes)"
            ]

            //subscribe to events
            const msgrCtrt = new ethers.Contract(messengerAddress, abi, provider);
            msgrCtrt.on('MessageSent', (msgId, chain, dest, msg, feeToken, fee) => {
                console.log('Message [', msgId, '] to chain <', chain, '>:<', dest, '> sent.'); 
                console.log('Message: ', msg)
            })
            msgrCtrt.on('MessageReceived', (msgId, chain, src, msg) => {
                console.log('Message [', msgId, '] from chain <', chain, '> received from <', src, '>');
                console.log("Message:", msg)

            })
            msgrCtrt.on('MessageAcknowledged', (msgId, chain, dest, msg) => {
                console.log('Message [', msgId, '] to chain <', chain, '> to <', dest, '> acknowledged');
                console.log("Message:", msg)
            })
            
            msgrCtrt.on('ErrorReceived', (msgId, chain, dest, msg) => {
                console.log('Message [', msgId, '] to chain <', chain, '> to <', dest, '> errored');
                console.log("Message:", msg)
            })
        }
    }


    start()
    
