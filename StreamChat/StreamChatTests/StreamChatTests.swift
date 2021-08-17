//
//  StreamChatTests.swift
//  StreamChatTests
//
//  Created by 강경 on 2021/08/11.
//

import XCTest
@testable import StreamChat

final class StreamChatTests: XCTestCase {
    
    let host = ChattingConstant.host
    let port = ChattingConstant.port
    let userName = "TestName"
    let actName = "act"
    let observerName = "observer"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    // TODO: - Server에 의존하지 않는 테스트 구현
    // MARK: - 메시지 전송 및 수신
    func test_메시지_전송_및_수신() throws {
        let messageToSend = "message for test"
        let chatting = try Chatting(userName: userName, host: host, port: port)
        chatting.enterTheChatRoom()
        try chatting.send(message: messageToSend)
        
        let receivedData = try chatting.receivedData()
        let receivedMessage = receivedData.message
        
        chatting.leaveTheChatRoom()
        chatting.disconnect()
        
        XCTAssertEqual(messageToSend, receivedMessage)
    }
    
    func test_보내는_메시지_글자수_제한() throws {
        let sixtyCharacterString = "012345678901234567890123456789012345678901234567890123456789"
        let threeHundredCharacterString = """
            \(sixtyCharacterString)\(sixtyCharacterString)\(sixtyCharacterString)
            \(sixtyCharacterString)\(sixtyCharacterString)
            """
        let messageToSend = threeHundredCharacterString
        let chatting = try Chatting(userName: userName, host: host, port: port)
        chatting.enterTheChatRoom()
        
        do {
            try chatting.send(message: messageToSend)
        } catch {
            let stringOfError: String = "\(error)"
            XCTAssertEqual(stringOfError, ChattingError.sendingMessagesIsLimitedTo300.description)
        }
        
        chatting.leaveTheChatRoom()
        chatting.disconnect()
    }
    
    // MARK: - 채팅참가 알림 및 수신
    func test_채팅참가_알림_및_수신() throws {
        let chatParticipationNotification = "\(actName) has joined"
        let chattingOfObserver = try Chatting(userName: observerName, host: host, port: port)
        chattingOfObserver.enterTheChatRoom()
        
        let chattingOfAct = try Chatting(userName: actName, host: host, port: port)
        chattingOfAct.enterTheChatRoom()
        
        let receivedData = try chattingOfObserver.receivedData()
        let receivedMessage = "\(receivedData.userName) \(receivedData.message)"
        chattingOfAct.leaveTheChatRoom()
        chattingOfAct.disconnect()
        chattingOfObserver.leaveTheChatRoom()
        chattingOfObserver.disconnect()

        XCTAssertEqual(chatParticipationNotification, receivedMessage)
    }
    
    // MARK: - 채팅방 나가기 알림 및 수신
    func test_채팅방_나가기_알림_및_수신() throws {
        let leaveChatNotification = "\(actName) has left"
        let chattingOfObserver = try Chatting(userName: observerName, host: host, port: port)
        chattingOfObserver.enterTheChatRoom()
        
        let chattingOfAct = try Chatting(userName: actName, host: host, port: port)
        chattingOfAct.enterTheChatRoom()
        
        _ = try chattingOfObserver.receivedData()
        chattingOfAct.leaveTheChatRoom()
        
        let receivedData = try chattingOfObserver.receivedData()
        let receivedMessage = "\(receivedData.userName) \(receivedData.message)"
        chattingOfAct.disconnect()
        chattingOfObserver.leaveTheChatRoom()
        chattingOfObserver.disconnect()

        XCTAssertEqual(leaveChatNotification, receivedMessage)
    }
    
    func test_아이디_올바른_String값_적절성판단() throws {
        let validName = "TestName"
        let messageToSend = "message for test"
        let chatting = try Chatting(userName: validName, host: host, port: port)
        chatting.enterTheChatRoom()
        try chatting.send(message: messageToSend)
        
        let receivedData = try chatting.receivedData()
        let receivedUserName = receivedData.userName
        
        chatting.leaveTheChatRoom()
        chatting.disconnect()
        
        XCTAssertEqual(validName, receivedUserName)
    }
    
    func test_아이디_올바르지않은_String값_적절성판단() throws {
        let invalidName = "END"
        do {
            _ = try Chatting(userName: invalidName, host: host, port: port)
        } catch {
            let stringOfError: String = "\(error)"
            XCTAssertEqual(stringOfError, ChattingError.unavailableCharactersWereUsed.description)
        }
    }
}
