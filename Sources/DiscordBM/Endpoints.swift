import Foundation
import NIOHTTP1

public enum EndpointIdentity: Int, Hashable, CaseIterable {
    case getGateway
    case getGatewayBot
    case createInteractionResponse
    case editOriginalInteractionResponse
    case deleteOriginalInteractionResponse
    case postFollowupGatewayInteractionResponse
    case editGatewayInteractionResponseFollowup
    case postCreateMessage
    case patchEditMessage
    case deleteMessage
    case createApplicationGlobalCommand
    case getApplicationGlobalCommands
    case deleteApplicationGlobalCommand
    case getGuild
    case searchGuildMembers
    case getGuildMember
    case getChannel
    case leaveGuild
    case createGuildRole
    case addGuildMemberRole
    case removeGuildMemberRole
    case addReaction
}

/// API Endpoint.
enum Endpoint {
    case getGateway
    case getGatewayBot
    
    case createInteractionResponse(id: String, token: String)
    case editOriginalInteractionResponse(appId: String, token: String)
    case deleteOriginalInteractionResponse(appId: String, token: String)
    case postFollowupGatewayInteractionResponse(appId: String, token: String)
    case editGatewayInteractionResponseFollowup(appId: String, id: String, token: String)
    
    case postCreateMessage(channelId: String)
    case patchEditMessage(channelId: String, messageId: String)
    case deleteMessage(channelId: String, messageId: String)
    
    case createApplicationGlobalCommand(appId: String)
    case getApplicationGlobalCommands(appId: String)
    case deleteApplicationGlobalCommand(appId: String, id: String)
    
    case getGuild(id: String)
    case searchGuildMembers(id: String)
    case getGuildMember(id: String, userId: String)
    
    case getChannel(id: String)
    
    case leaveGuild(id: String)
    
    case createGuildRole(guildId: String)
    case addGuildMemberRole(guildId: String, userId: String, roleId: String)
    case removeGuildMemberRole(guildId: String, userId: String, roleId: String)
    
    case addReaction(channelId: String, messageId: String, emoji: String)
    
    var identity: EndpointIdentity {
        switch self {
        case .getGateway: return .getGateway
        case .getGatewayBot: return .getGatewayBot
        case .createInteractionResponse: return .createInteractionResponse
        case .editOriginalInteractionResponse: return .editOriginalInteractionResponse
        case .deleteOriginalInteractionResponse: return .deleteOriginalInteractionResponse
        case .postFollowupGatewayInteractionResponse: return .postFollowupGatewayInteractionResponse
        case .editGatewayInteractionResponseFollowup: return .editGatewayInteractionResponseFollowup
        case .postCreateMessage: return .postCreateMessage
        case .patchEditMessage: return .patchEditMessage
        case .deleteMessage: return .deleteMessage
        case .createApplicationGlobalCommand: return .createApplicationGlobalCommand
        case .getApplicationGlobalCommands: return .getApplicationGlobalCommands
        case .deleteApplicationGlobalCommand: return .deleteApplicationGlobalCommand
        case .getGuild: return .getGuild
        case .searchGuildMembers: return .searchGuildMembers
        case .getGuildMember: return .getGuildMember
        case .getChannel: return .getChannel
        case .leaveGuild: return .leaveGuild
        case .createGuildRole: return .createGuildRole
        case .addGuildMemberRole: return .addGuildMemberRole
        case .removeGuildMemberRole: return .removeGuildMemberRole
        case .addReaction: return .addReaction
        }
    }
    
    var isCacheable: Bool {
        self.httpMethod == .GET
    }
    
    var urlSuffix: String {
        switch self {
        case .getGateway:
            return "gateway"
        case .getGatewayBot:
            return "gateway/bot"
        case let .createInteractionResponse(id, token):
            return "interactions/\(id)/\(token)/callback"
        case let .editOriginalInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .deleteOriginalInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)/messages/@original"
        case let .postFollowupGatewayInteractionResponse(appId, token):
            return "webhooks/\(appId)/\(token)"
        case let .editGatewayInteractionResponseFollowup(appId, id, token):
            return "webhooks/\(appId)/\(token)/messages/\(id)"
        case let .postCreateMessage(channelId):
            return "channels/\(channelId)/messages"
        case let .patchEditMessage(channelId, messageId):
            return "channels/\(channelId)/messages/\(messageId)"
        case let .deleteMessage(channelId, messageId):
            return "channels/\(channelId)/messages/\(messageId)"
        case let .createApplicationGlobalCommand(appId):
            return "applications/\(appId)/commands"
        case let .getApplicationGlobalCommands(appId):
            return "applications/\(appId)/commands"
        case let .deleteApplicationGlobalCommand(appId, id):
            return "applications/\(appId)/commands/\(id)"
        case let .getGuild(id):
            return "guilds/\(id)"
        case let .searchGuildMembers(id):
            return "guilds/\(id)/members/search"
        case let .getGuildMember(id, userId):
            return "guilds/\(id)/members/\(userId)"
        case let .getChannel(id):
            return "channels/\(id)"
        case let .leaveGuild(id):
            return "users/@me/guilds/\(id)"
        case let .createGuildRole(guildId):
            return "guilds/\(guildId)/roles"
        case let .addGuildMemberRole(guildId, userId, roleId):
            return "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .removeGuildMemberRole(guildId, userId, roleId):
            return "guilds/\(guildId)/members/\(userId)/roles/\(roleId)"
        case let .addReaction(channelId, messageId, emoji):
            return "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
        }
    }
    
    var url: String {
        let suffix = urlSuffix.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
        ) ?? urlSuffix
        return "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/" + suffix
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getGateway: return .GET
        case .getGatewayBot: return .GET
        case .createInteractionResponse: return .POST
        case .editOriginalInteractionResponse: return .PATCH
        case .deleteOriginalInteractionResponse: return .DELETE
        case .postFollowupGatewayInteractionResponse: return .POST
        case .editGatewayInteractionResponseFollowup: return .PATCH
        case .postCreateMessage: return .POST
        case .patchEditMessage: return .PATCH
        case .deleteMessage: return .DELETE
        case .createApplicationGlobalCommand: return .POST
        case .getApplicationGlobalCommands: return .GET
        case .deleteApplicationGlobalCommand: return .DELETE
        case .getGuild: return .GET
        case .searchGuildMembers: return .GET
        case .getGuildMember: return .GET
        case .getChannel: return .GET
        case .leaveGuild: return .DELETE
        case .createGuildRole: return .POST
        case .addGuildMemberRole: return .PUT
        case .removeGuildMemberRole: return .DELETE
        case .addReaction: return .PUT
        }
    }
    
    var id: Int {
        switch self {
        case .getGateway: return 1
        case .getGatewayBot: return 2
        case .createInteractionResponse: return 3
        case .editOriginalInteractionResponse: return 4
        case .deleteOriginalInteractionResponse: return 5
        case .postFollowupGatewayInteractionResponse: return 6
        case .editGatewayInteractionResponseFollowup: return 7
        case .postCreateMessage: return 8
        case .patchEditMessage: return 9
        case .deleteMessage: return 10
        case .createApplicationGlobalCommand: return 11
        case .getApplicationGlobalCommands: return 12
        case .deleteApplicationGlobalCommand: return 13
        case .getGuild: return 14
        case .searchGuildMembers: return 15
        case .getGuildMember: return 16
        case .getChannel: return 17
        case .leaveGuild: return 18
        case .createGuildRole: return 19
        case .addGuildMemberRole: return 20
        case .removeGuildMemberRole: return 21
        case .addReaction: return 22
        }
    }
}
