//
//  NotificationService.swift
//  TwitterUIKit
//
//  Created by Maciej on 08/11/2022.
//

import FirebaseFirestore
import FirebaseAuth

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(toUser user: User, type: NotificationType, tweetId: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let userId = user.id else { return }
        
        let usersRef = Firestore.firestore().collection("users")
        
        var data = ["timestamp": Timestamp(date: Date()),
                    "uid": uid,
                    "type": type.rawValue
                    
        ] as [String: Any]
        
        if let tweetId = tweetId {
            data["tweetId"] = tweetId
        }
        
        usersRef.document(userId).collection("user-notifications").document()
            .setData(data) { _ in
                
            }

        
//        if let tweetId = tweetId {
//            guard let tweetUid = tweet.user?.id else { return }
//            data["tweetId"] = tweet.id
//            usersRef.document(user.id).collection("user-notifications").document()
//                .setData(data) { _ in
//                    print("DEBUG: Successfully sent notification of type: \(type) to user: \(tweetUid)..")
//                }
//        } else {
//            guard let userId = user?.id else { return }
//            usersRef.document(userId).collection("user-notifications").document()
//                .setData(data) { _ in
//                    print("DEBUG: Successfully sent notification of type: \(type) to user: \(userId)..")
//                }
//        }
        
    }
    
    func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var notifications = [Notification]()
        
        let usersRef = Firestore.firestore().collection("users")
        
        usersRef.document(uid).collection("user-notifications").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
                                  
            if documents.count == 0 { completion(notifications) }
            
            documents.forEach { document in
                guard var notification = try? document.data(as: Notification.self) else { return }
                
                UserService.shared.fetchUser(withUid: notification.uid) { user in
                    notification.user = user
                    notifications.append(notification)
                    completion(notifications.sorted(by: { $0.timestamp > $1.timestamp } ))
                }
            }
        }
    }
    
}
