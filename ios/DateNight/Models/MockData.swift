import Foundation

// MARK: - Mock User

struct MockUser: Identifiable, Hashable {
    let id: String
    let name: String
    let age: Int
    let avatar: String
    let photos: [String]
    let bio: String
    let interests: [String]
    var isOnline: Bool = false
}

// MARK: - Mock Conversation

struct MockConversation: Identifiable, Hashable {
    let id: String
    let user: MockUser
    let lastMessage: String
    let timestamp: String
    let unread: Int
    let isGroup: Bool
    var groupName: String?
    var isTyping: Bool = false
}

// MARK: - Mock Message

struct MockMessage: Identifiable, Hashable {
    let id: String
    let isSent: Bool
    let text: String
    let timestamp: String
}

// MARK: - Mock Activity

struct MockActivity: Identifiable, Hashable {
    let id: String
    let icon: String
    let iconColor: String
    let title: String
    let subtitle: String
    let timeAgo: String
}

// MARK: - Sample Data

enum MockData {
    static let currentUser = MockUser(
        id: "current-user",
        name: "You",
        age: 28,
        avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
        photos: [
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&h=800&fit=crop",
            "https://images.unsplash.com/photo-1598186951851-bddc3089d68b?w=800&h=800&fit=crop",
            "https://images.unsplash.com/photo-1545311630-51ea4a4c84de?w=800&h=800&fit=crop",
            "https://images.unsplash.com/photo-1604364260242-1156640c0dfb?w=800&h=800&fit=crop"
        ],
        bio: "Love live music and art galleries",
        interests: ["Music", "Art", "Food", "Comedy"],
        isOnline: true
    )

    static let users: [MockUser] = [
        MockUser(
            id: "1",
            name: "Emma",
            age: 26,
            avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1675663351050-89949e051c38?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1757439160077-dd5d62a4d851?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1762455129210-c886b9295056?w=800&h=800&fit=crop"
            ],
            bio: "Jazz enthusiast and foodie",
            interests: ["Music", "Food", "Wine"],
            isOnline: true
        ),
        MockUser(
            id: "2",
            name: "Sarah",
            age: 29,
            avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1652375186211-805106e54556?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1713779490284-a81ff6a8ffae?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1648237409808-aa4649c07ec8?w=800&h=800&fit=crop"
            ],
            bio: "Art lover, comedy fan",
            interests: ["Art", "Comedy", "Music"]
        ),
        MockUser(
            id: "3",
            name: "Alex",
            age: 27,
            avatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1650965238931-8f642566fb57?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1604364260242-1156640c0dfb?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1551883738-19ffa3dc4c43?w=800&h=800&fit=crop"
            ],
            bio: "Concert junkie and outdoor enthusiast",
            interests: ["Music", "Outdoors", "Food"]
        ),
        MockUser(
            id: "4",
            name: "Michael",
            age: 30,
            avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1765175095011-7c31690b4e48?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1762455129210-c886b9295056?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1713779490284-a81ff6a8ffae?w=800&h=800&fit=crop"
            ],
            bio: "Wine connoisseur, live music fan",
            interests: ["Wine", "Music", "Art"]
        ),
        MockUser(
            id: "5",
            name: "Jessica",
            age: 25,
            avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop",
            photos: [
                "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1727206842092-f4a602899f91?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1608405059861-b21a68ae76a2?w=800&h=800&fit=crop",
                "https://images.unsplash.com/photo-1648237409808-aa4649c07ec8?w=800&h=800&fit=crop"
            ],
            bio: "Yoga instructor who loves comedy shows",
            interests: ["Wellness", "Comedy", "Food"]
        )
    ]

    static let conversations: [MockConversation] = [
        MockConversation(
            id: "c1",
            user: users[0],
            lastMessage: "I'd love to go to the concert with you!",
            timestamp: "2m",
            unread: 2,
            isGroup: false
        ),
        MockConversation(
            id: "c2",
            user: users[1],
            lastMessage: "How about we invite more friends?",
            timestamp: "15m",
            unread: 0,
            isGroup: true,
            groupName: "Jazz Club Date"
        ),
        MockConversation(
            id: "c3",
            user: users[2],
            lastMessage: "Perfect, see you there!",
            timestamp: "1h",
            unread: 0,
            isGroup: false
        ),
        MockConversation(
            id: "c4",
            user: users[3],
            lastMessage: "What time should we meet?",
            timestamp: "3h",
            unread: 1,
            isGroup: false
        ),
        MockConversation(
            id: "c5",
            user: users[4],
            lastMessage: "Thanks for the recommendation!",
            timestamp: "1d",
            unread: 0,
            isGroup: false
        )
    ]

    static let chatMessages: [MockMessage] = [
        MockMessage(
            id: "m1",
            isSent: false,
            text: "Hey! I saw you're also interested in the jazz concert",
            timestamp: "10:30"
        ),
        MockMessage(
            id: "m2",
            isSent: true,
            text: "Yes! I love jazz. Have you been to that venue before?",
            timestamp: "10:32"
        ),
        MockMessage(
            id: "m3",
            isSent: false,
            text: "A couple of times, the atmosphere is incredible",
            timestamp: "10:33"
        ),
        MockMessage(id: "m4", isSent: false, text: "Would you like to go together?", timestamp: "10:33"),
        MockMessage(id: "m5", isSent: true, text: "I'd love to! Should we invite more people?", timestamp: "10:35"),
        MockMessage(id: "m6", isSent: false, text: "Great idea! We could do a group date", timestamp: "10:36"),
        MockMessage(
            id: "m7",
            isSent: true,
            text: "Perfect! I know a couple of people who'd be interested",
            timestamp: "10:38"
        ),
        MockMessage(id: "m8", isSent: false, text: "Awesome, let's plan it out this week!", timestamp: "10:39"),
        MockMessage(
            id: "m9",
            isSent: true,
            text: "Sounds great! I'll check schedules and get back to you",
            timestamp: "10:41"
        ),
        MockMessage(id: "m10", isSent: false, text: "I'd love to go to the concert with you!", timestamp: "10:42")
    ]

    static let activities: [MockActivity] = [
        MockActivity(
            id: "a1",
            icon: "heart.fill",
            iconColor: "pink",
            title: "Matched with Emma",
            subtitle: "Jazz Night - April 1",
            timeAgo: "2d"
        ),
        MockActivity(
            id: "a2",
            icon: "calendar",
            iconColor: "purple",
            title: "Joined Contemporary Art Exhibition",
            subtitle: "March 30, 6:00 PM",
            timeAgo: "3d"
        ),
        MockActivity(
            id: "a3",
            icon: "star.fill",
            iconColor: "green",
            title: "Saved Street Food Festival",
            subtitle: "April 2, 12:00 PM",
            timeAgo: "5d"
        )
    ]
}
