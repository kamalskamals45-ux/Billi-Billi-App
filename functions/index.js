const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');

initializeApp();
setGlobalOptions({ region: 'us-central1', maxInstances: 10 });

const db = getFirestore();

async function profileName(uid) {
  const snap = await db.collection('users').doc(uid).get();
  if (!snap.exists) return 'Billi Billi User';
  const name = snap.data()?.displayName;
  return typeof name === 'string' && name.trim() ? name.trim() : 'Billi Billi User';
}

async function notifyUser(targetUid, { title, body, type, actorUid, postId, chatId }) {
  if (!targetUid || !actorUid || targetUid === actorUid) return;

  const actorName = await profileName(actorUid);
  const notificationRef = db
    .collection('users').doc(targetUid)
    .collection('notifications').doc();

  await notificationRef.set({
    type,
    actorUid,
    actorName,
    title,
    body,
    ...(postId ? { postId } : {}),
    ...(chatId ? { chatId } : {}),
    createdAt: FieldValue.serverTimestamp(),
    read: false,
  });

  const tokensSnap = await db
    .collection('users').doc(targetUid)
    .collection('deviceTokens').get();
  if (tokensSnap.empty) return;

  const tokens = tokensSnap.docs
    .map((doc) => doc.data()?.token)
    .filter((token) => typeof token === 'string' && token.length > 0);
  if (!tokens.length) return;

  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title, body },
    data: {
      type,
      ...(postId ? { postId } : {}),
      ...(chatId ? { chatId } : {}),
    },
    android: {
      priority: 'high',
      notification: { channelId: 'billi_billi_notifications' },
    },
  });

  const deletes = [];
  response.responses.forEach((result, index) => {
    if (!result.success) {
      const code = result.error?.code || '';
      if (code.includes('registration-token-not-registered') || code.includes('invalid-registration-token')) {
        deletes.push(tokensSnap.docs.find((doc) => doc.data()?.token === tokens[index]));
      }
    }
  });
  await Promise.all(deletes.filter(Boolean).map((doc) => doc.ref.delete()));
}

exports.notifyOnFollow = onDocumentCreated('users/{targetUid}/followers/{actorUid}', async (event) => {
  const { targetUid, actorUid } = event.params;
  await notifyUser(targetUid, {
    type: 'follow',
    title: 'New follower',
    body: `${await profileName(actorUid)} started following you.`,
    actorUid,
  });
});

exports.notifyOnLike = onDocumentCreated('posts/{postId}/likes/{actorUid}', async (event) => {
  const { postId, actorUid } = event.params;
  const post = await db.collection('posts').doc(postId).get();
  if (!post.exists) return;
  const ownerUid = post.data()?.ownerUid;
  await notifyUser(ownerUid, {
    type: 'like',
    title: 'New like',
    body: `${await profileName(actorUid)} liked your post.`,
    actorUid,
    postId,
  });
});

exports.notifyOnComment = onDocumentCreated('posts/{postId}/comments/{commentId}', async (event) => {
  const { postId } = event.params;
  const comment = event.data?.data();
  if (!comment) return;
  const post = await db.collection('posts').doc(postId).get();
  if (!post.exists) return;
  const ownerUid = post.data()?.ownerUid;
  const actorUid = comment.ownerUid;
  await notifyUser(ownerUid, {
    type: 'comment',
    title: 'New comment',
    body: `${await profileName(actorUid)} commented on your post.`,
    actorUid,
    postId,
  });
});

exports.notifyOnMessage = onDocumentCreated('chats/{chatId}/messages/{messageId}', async (event) => {
  const message = event.data?.data();
  if (!message) return;
  const actorUid = message.senderId;
  const targetUid = message.receiverId;
  if (!actorUid || !targetUid) return;
  await notifyUser(targetUid, {
    type: 'message',
    title: 'New message',
    body: `${await profileName(actorUid)} sent you a message.`,
    actorUid,
    chatId: event.params.chatId,
  });
});
