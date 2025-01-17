const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore.docuemnt("/followers/{userId}/userFollowers/{followerId}")
    .onCreate(async (snapshots, context) => {
        console.log("followers Created", snapshots.data());
        const userId = context.params.userId;
        const followerId = context.params.followerId;
        //  1). Create followed user's post Ref
        const followedUserPostsRef = admin
            .firestore()
            .collection('posts')
            .doc(userId)
            .collection(userPosts);
        //  2). Create followed user's timeline Ref
        const timelinePostsRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts');
        //  3). Get followed user's post
        const querySnapshot = await followedUserPostsRef.get();
        //  4). Add each user's post to followings timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                timelinePostsRef.doc(postId).set(postData);

            }

        });
    });

exports.onDeleteFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onDelete(async (snapshots, context) => {
        console.log("follower deleted", snapshots.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;
        const timelinePostsRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .where("ownerId", "==", userId);


        const querySnapshot = await timelinePostsRef.get();
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();

            }
        })
    });

// When the post is created, add this post to the timeline of all user's followers
exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onCreate(async (snapshot, context) => {
        const postCreated = snapshot.data();
        const userId = context.prams.userId;
        const postId = context.prams.postId;

        // Get all the followers of the user who made the post
        const userFollowersRef = admin.firestore.collection('followers').doc(userId).collection('userFollowers');
        const querySnapshot = userFollowersRef.get();
        // Add new post to each followers timeline
        querySnapshot.forEach(follower => {
            const followerId = follower.id;
            admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .set(postCreated);

        });
    });
exports.onUpdatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onUpdate(async (change, context) => {
        const postUpdated = change.after.data();
        const userId = context.prams.userId;
        const postId = context.prams.postId;
        // Get all the followers of the user who made the post
        const userFollowersRef = admin.firestore
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = userFollowersRef.get();

        // Update each post in each followers' timeline
        querySnapshot.forEach(follower => {
            const followerId = follower.id;
            admin.firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.update(postUpdated);
                    }
                });

        });
    });


exports.onDeletePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onDelete(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1) Get all the followers of the user who made the post
        const userFollowersRef = admin
            .firestore()
            .collection("followers")
            .doc(userId)
            .collection("userFollowers");

        const querySnapshot = await userFollowersRef.get();
        // 2) Delete each post in each follower's timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .doc(postId)
                .get()
                .then(doc => {
                    if (doc.exists) {
                        doc.ref.delete();
                    }
                });
        });
    });

// exports.onCreateActivityFeedItem = functions.firestore
//     .document("/feed/{userId}/feedItems/{activityFeedItem}")
//     .onCreate(async (snapshot, context) => {
//         console.log("Activity Feed Item Created", snapshot.data());

//         // 1) Get user connected to the feed
//         const userId = context.params.userId;

//         const userRef = admin.firestore().doc(`users/${userId}`);
//         const doc = await userRef.get();

//         // 2) Once we have user, check if they have a notification token; send notification, if they have a token
//         const androidNotificationToken = doc.data().androidNotificationToken;
//         const createdActivityFeedItem = snapshot.data();
//         if (androidNotificationToken) {
//             sendNotification(androidNotificationToken, createdActivityFeedItem);
//         } else {
//             console.log("No token for user, cannot send notification");
//         }

//         function sendNotification(androidNotificationToken, activityFeedItem) {
//             let body;

//             // 3) switch body value based off of notification type
//             switch (activityFeedItem.type) {
//                 case "comment":
//                     body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData
//                         }`;
//                     break;
//                 case "like":
//                     body = `${activityFeedItem.username} liked your post`;
//                     break;
//                 case "follow":
//                     body = `${activityFeedItem.username} started following you`;
//                     break;
//                 default:
//                     break;
//             }

//             // 4) Create message for push notification
//             const message = {
//                 notification: { body },
//                 token: androidNotificationToken,
//                 data: { recipient: userId }
//             };

//             // 5) Send message with admin.messaging()
//             admin
//                 .messaging()
//                 .send(message)
//                 .then(response => {
//                     // Response is a message ID string
//                     console.log("Successfully sent message", response);
//                 })
//                 .catch(error => {
//                     console.log("Error sending message", error);
//                 });
//         }
//     });
