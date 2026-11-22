// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          Text(
            'Last updated: November 22, 2026',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Text(
            'Cadence Tasks stores routine and task data on your device or browser. '
            'If you sign in with Google, the app syncs that content through '
            'Google Firebase services and associates it with your Firebase '
            'user ID.',
          ),
          SizedBox(height: 16),
          Text('Data processed', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'Google provides your sign-in identity, which can include your '
            'user ID, email address, and display name. The app stores the '
            'routine and task titles, notes, schedules, recurrence settings, '
            'completion state, and synchronization metadata that you create.',
          ),
          SizedBox(height: 16),
          Text(
            'How data is used',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Data is used to provide the agenda, routines, reminders, and '
            'sync across devices signed in to the same account. Android '
            'reminders are scheduled locally on your Android device. Cadence Tasks '
            'does not use advertising or analytics SDKs.',
          ),
          SizedBox(height: 16),
          Text(
            'Storage and retention',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Local data is stored in the app on your device or browser. Synced data is '
            'stored in Cloud Firestore in the United States multi-region '
            'location selected for this project. It remains there until you '
            'delete your account and data.',
          ),
          SizedBox(height: 16),
          Text('Deletion', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'Use Settings > Delete account and data to permanently delete '
            'your Cadence Tasks Firebase account, its synced task and routine '
            'documents, and the corresponding local records on this device. '
            'A device that is offline during deletion may retain its local copy '
            'until it reconnects and receives the deletion or you clear that '
            "device's app data. When signed out, use Settings > Delete local "
            'data to remove all local task and routine data for every account '
            'on that device or browser. This does not delete your Google account. '
            'Google and Firebase may retain service logs as described in their '
            'policies.',
          ),
          SizedBox(height: 16),
          Text(
            'Service providers',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Google Sign-In and Firebase Authentication and Cloud Firestore '
            'process data to provide sign-in and synchronization. Their '
            'services are subject to Google privacy terms.',
          ),
          SizedBox(height: 16),
          Text('Contact', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'For privacy questions, use the project issue tracker at '
            'github.com/al7474/pulse-routines/issues. Do not post task content '
            'or other private information in a public issue.',
          ),
        ],
      ),
    );
  }
}
