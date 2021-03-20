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