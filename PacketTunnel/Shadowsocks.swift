//
//  Shadowsocks.swift
//  PacketTunnel
//
//  Created by Aofei Sheng on 2018/3/23.
//  Copyright © 2018 Aofei Sheng. All rights reserved.
//

import NEKit
import UIKit
import CocoaLumberjackSwift

class Shadowsocks: Observer<ProxyServerEvent> {
	let serverAddress: String
	let serverPort: UInt16
	let localAddress: String
	let localPort: UInt16
	let password: String
	let method: String

//    private let socks5ProxyServer: GCDSOCKS5ProxyServer
    private let httpProxyServer:  GCDHTTPProxyServer
    
	init(serverAddress: String, serverPort: UInt16, localAddress: String, localPort: UInt16, password: String, method: String) {
        
        DDLog.add(DDTTYLogger.sharedInstance); // TTY = Xcode console
        // TTY = Xcode 控制台
        DDLog.add(DDASLLogger.sharedInstance); // ASL = Apple System Logs
        
        ObserverFactory.currentFactory = DebugObserverFactory()
        
		self.serverAddress = serverAddress
		self.serverPort = serverPort
		self.localAddress = localAddress
		self.localPort = localPort
		self.password = password
		self.method = method
        httpProxyServer = GCDHTTPProxyServer(address: IPAddress(fromString: localAddress), port: NEKit.Port(port: localPort))
//        socks5ProxyServer = GCDSOCKS5ProxyServer(address: IPAddress(fromString: localAddress), port: NEKit.Port(port: localPort))
        
        NSLog("[hdq]%@", httpProxyServer)
		let cryptoAlgorithm: CryptoAlgorithm
		switch method {
		case "AES-128-CFB":
			cryptoAlgorithm = .AES128CFB
		case "AES-192-CFB":
			cryptoAlgorithm = .AES192CFB
		case "ChaCha20":
			cryptoAlgorithm = .CHACHA20
		case "Salsa20":
			cryptoAlgorithm = .SALSA20
		case "RC4-MD5":
			cryptoAlgorithm = .RC4MD5
		default:
			cryptoAlgorithm = .AES256CFB
		}

		RuleManager.currentManager = RuleManager(
			fromRules: [
				AllRule(
					adapterFactory: ShadowsocksAdapterFactory(
						serverHost: serverAddress,
						serverPort: Int(serverPort),
						protocolObfuscaterFactory: ShadowsocksAdapter.ProtocolObfuscater.OriginProtocolObfuscater.Factory(),
						cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory(password: password, algorithm: cryptoAlgorithm),
						streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.OriginStreamObfuscater.Factory()
					)
				),
			],
			appendDirect: true
		)
	}

	func start() throws {
        do{
            try httpProxyServer.start()
            NSLog("[hdq]start %@", httpProxyServer)
        }catch {
            NSLog("[hdq]%@", error.localizedDescription)
        }
	}

	func stop() {
		httpProxyServer.stop()
	}
}
