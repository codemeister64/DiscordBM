@testable import DiscordBM
import XCTest

class GatewayModelsTests: XCTestCase {
    
    func testEventDecode() throws {
        
        do {
            let text = """
            {
                "t": null,
                "s": null,
                "op": 11,
                "d": null
            }
            """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .heartbeatAccepted)
            XCTAssertEqual(decoded.sequenceNumber, nil)
            XCTAssertEqual(decoded.type, nil)
            XCTAssertTrue(decoded.data == nil)
        }
        
        do {
            let text = """
            {
            "t": "MESSAGE_CREATE",
            "s": 130,
            "op": 0,
            "d": {
                "type": 0,
                "tts": false,
                "timestamp": "2022-10-07T19:44:07.295000+00:00",
                "referenced_message": null,
                "pinned": false,
                "nonce": "1028029979960541184",
                "mentions": [],
                "mention_roles": [],
                "mention_everyone": false,
                "member": {
                    "roles": [
                        "431921695524126722"
                    ],
                    "premium_since": null,
                    "pending": false,
                    "nick": null,
                    "mute": false,
                    "joined_at": "2020-04-18T00:10:04.414000+00:00",
                    "flags": 0,
                    "deaf": false,
                    "communication_disabled_until": null,
                    "avatar": null
                },
                "id": "1028029980795478046",
                "flags": 0,
                "embeds": [],
                "edited_timestamp": null,
                "content": "blah bljhshADh blah",
                "components": [],
                "channel_id": "435923868503506954",
                "author": {
                    "username": "GoodUser",
                    "public_flags": 0,
                    "id": "560661188019488714",
                    "discriminator": "4443",
                    "avatar_decoration": null,
                    "avatar": "845407ec1491b55828cc1f91c2436e8b"
                },
                "attachments": [],
                "guild_id": "439103874612675485"
                }
            }
            """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .dispatch)
            XCTAssertEqual(decoded.sequenceNumber, 130)
            XCTAssertEqual(decoded.type, "MESSAGE_CREATE")
            guard case let .messageCreate(message) = decoded.data else {
                XCTFail("Unexpected data: \(String(describing: decoded.data))")
                return
            }
            XCTAssertEqual(message.type, .default)
            XCTAssertEqual(message.tts, false)
            XCTAssertEqual(message.timestamp.date.timeIntervalSince1970, 1665171847.295)
            XCTAssertTrue(message.referenced_message == nil)
            XCTAssertEqual(message.pinned, false)
            XCTAssertEqual(message.nonce?.asString, "1028029979960541184")
            XCTAssertTrue(message.mentions.isEmpty)
            XCTAssertEqual(message.mention_roles, [])
            XCTAssertEqual(message.mention_everyone, false)
            let member = try XCTUnwrap(message.member)
            XCTAssertEqual(member.roles, ["431921695524126722"])
            XCTAssertEqual(member.premium_since?.date, nil)
            XCTAssertEqual(member.pending, false)
            XCTAssertEqual(member.nick, nil)
            XCTAssertEqual(member.mute, false)
            XCTAssertEqual(member.joined_at?.date.timeIntervalSince1970, 1587168604.414)
            XCTAssertEqual(member.flags, [])
            XCTAssertEqual(member.deaf, false)
            XCTAssertEqual(member.communication_disabled_until?.date, nil)
            XCTAssertEqual(member.avatar, nil)
            XCTAssertEqual(message.id, "1028029980795478046")
            XCTAssertEqual(message.flags, [])
            XCTAssertTrue(message.embeds.isEmpty)
            XCTAssertEqual(message.edited_timestamp?.date, nil)
            XCTAssertEqual(message.content, "blah bljhshADh blah")
            XCTAssertTrue(message.components?.isEmpty == true)
            XCTAssertEqual(message.channel_id, "435923868503506954")
            let author = try XCTUnwrap(message.author)
            XCTAssertEqual(author.username, "GoodUser")
            XCTAssertEqual(author.public_flags, [])
            XCTAssertEqual(author.id, "560661188019488714")
            XCTAssertEqual(author.discriminator, "4443")
            XCTAssertEqual(author.avatar_decoration, nil)
            XCTAssertEqual(author.avatar, "845407ec1491b55828cc1f91c2436e8b")
            XCTAssertTrue(message.attachments.isEmpty)
            XCTAssertEqual(message.guild_id, "439103874612675485")
        }
    }
    
    /// Test that collections of raw-representable codable enums
    /// don't fail on decoding unknown values.
    func testNoThrowEnums() throws {
        do {
            let text = """
            {
                "values": [
                    1,
                    2,
                    3,
                    500
                ]
            }
            """
            
            /// The values include `500` which is not in `DiscordChannel.Kind`.
            /// Decoding the `500` normally fails, but based on our `ToleratesDecode` hack,
            /// this should never fail in internal `DiscordBM` decode processes.
            let decoded = try JSONDecoder().decode(
                TestContainer<DiscordChannel.Kind>.self,
                from: Data(text.utf8)
            ).values
            XCTAssertEqual(decoded.count, 3)
        }
        
        do {
            let text = """
            {
                "values": [
                    "online",
                    "dnd",
                    "bothOfflineAndOnlineWhichIsInvalid",
                    "idle",
                    "offline"
                ]
            }
            """
            
            /// Refer to the comment above for some explanations.
            let decoded = try JSONDecoder().decode(
                TestContainer<Gateway.Status>.self,
                from: Data(text.utf8)
            ).values
            XCTAssertEqual(decoded.count, 4)
        }
        
        do {
            let text = """
            {
                "scopes": [
                    "something.completely.new",
                    "activities.read",
                    "activities.write",
                    "applications.builds.read",
                    "applications.builds.upload",
                    "applications.commands"
                ],
                "permissions": "15"
            }
            """
            
            /// Refer to the comment above for some explanations.
            let decoded = try JSONDecoder().decode(
                PartialApplication.InstallParams.self,
                from: Data(text.utf8)
            )
            XCTAssertEqual(decoded.scopes.count, 5)
            XCTAssertEqual(decoded.permissions.toBitValue(), 15)
        }
    }
}

private struct TestContainer<C: Codable>: Codable {
    var values: [C]
}
