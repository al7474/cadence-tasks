import { after, test } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const projectId = 'demo-cadence-tasks-rules';
const testEnvironment = await initializeTestEnvironment({
  projectId,
  firestore: {
    rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'),
  },
});

after(async () => {
  await testEnvironment.cleanup();
});

test('users can create, update, and delete only their own task documents', async () => {
  await testEnvironment.clearFirestore();

  const ownerId = 'owner-1';
  const otherUserId = 'owner-2';
  const ownerFirestore = testEnvironment.authenticatedContext(ownerId).firestore();
  const otherFirestore = testEnvironment
    .authenticatedContext(otherUserId)
    .firestore();
  const taskReference = doc(
    ownerFirestore,
    `users/${ownerId}/oneOffTasks/task-1`,
  );
  const otherTaskReference = doc(
    otherFirestore,
    `users/${ownerId}/oneOffTasks/task-1`,
  );
  const task = {
    userId: ownerId,
    id: 'task-1',
    title: 'Review release notes',
    notes: null,
    scheduledDate: '2026-11-22',
    scheduledTimeMinutes: null,
    reminderEnabled: false,
    status: 'pending',
    completedAtUtcMillis: null,
    snoozedUntilUtcMillis: null,
    updatedAtUtcMillis: 100,
    deletedAtUtcMillis: null,
    mutationId: 'mutation-1',
  };

  await assertSucceeds(setDoc(taskReference, task));
  await assertSucceeds(getDoc(taskReference));
  await assertFails(getDoc(otherTaskReference));
  await assertFails(
    setDoc(doc(ownerFirestore, `users/${otherUserId}/oneOffTasks/task-2`), {
      ...task,
      id: 'task-2',
    }),
  );

  await assertSucceeds(
    updateDoc(taskReference, {
      title: 'Review updated release notes',
      updatedAtUtcMillis: 200,
      mutationId: 'mutation-2',
    }),
  );
  await assertFails(
    updateDoc(taskReference, {
      title: 'Stale update',
      updatedAtUtcMillis: 50,
      mutationId: 'mutation-3',
    }),
  );
  await assertFails(deleteDoc(otherTaskReference));
  await assertSucceeds(deleteDoc(taskReference));

  const routineReference = doc(
    ownerFirestore,
    `users/${ownerId}/routineTemplates/routine-1`,
  );
  const otherRoutineReference = doc(
    otherFirestore,
    `users/${ownerId}/routineTemplates/routine-1`,
  );
  await assertSucceeds(
    setDoc(routineReference, {
      userId: ownerId,
      id: 'routine-1',
      title: 'Morning walk',
      notes: null,
      startDate: '2026-11-22',
      endDate: null,
      targetTimeMinutes: 480,
      recurrenceKind: 'daily',
      weekdaysMask: 0,
      intervalDays: null,
      reminderEnabled: false,
      isEnabled: true,
      updatedAtUtcMillis: 100,
      deletedAtUtcMillis: null,
      mutationId: 'routine-mutation-1',
    }),
  );
  await assertFails(deleteDoc(otherRoutineReference));
  await assertSucceeds(deleteDoc(routineReference));

  const occurrenceReference = doc(
    ownerFirestore,
    `users/${ownerId}/routineOccurrenceLogs/routine-1:2026-11-22`,
  );
  const otherOccurrenceReference = doc(
    otherFirestore,
    `users/${ownerId}/routineOccurrenceLogs/routine-1:2026-11-22`,
  );
  await assertSucceeds(
    setDoc(occurrenceReference, {
      userId: ownerId,
      routineId: 'routine-1',
      occurrenceDate: '2026-11-22',
      status: 'pending',
      completedAtUtcMillis: null,
      snoozedUntilUtcMillis: null,
      rescheduledDate: null,
      rescheduledTimeMinutes: null,
      updatedAtUtcMillis: 100,
      deletedAtUtcMillis: null,
      mutationId: 'occurrence-mutation-1',
    }),
  );
  await assertFails(deleteDoc(otherOccurrenceReference));
  await assertSucceeds(deleteDoc(occurrenceReference));
});

test('unauthenticated clients cannot access user task documents', async () => {
  await testEnvironment.clearFirestore();

  const anonymousFirestore = testEnvironment.unauthenticatedContext().firestore();
  await assertFails(
    getDoc(doc(anonymousFirestore, 'users/owner-1/oneOffTasks/task-1')),
  );
  await assertFails(
    setDoc(doc(anonymousFirestore, 'users/owner-1/oneOffTasks/task-1'), {
      userId: 'owner-1',
      id: 'task-1',
      title: 'Unauthorized',
      scheduledDate: '2026-11-22',
      reminderEnabled: false,
      status: 'pending',
      updatedAtUtcMillis: 100,
      mutationId: 'mutation-1',
    }),
  );
});

test('calendar display hours sync only to their authenticated account', async () => {
  await testEnvironment.clearFirestore();

  const ownerId = 'calendar-owner';
  const ownerFirestore = testEnvironment.authenticatedContext(ownerId).firestore();
  const otherFirestore = testEnvironment
    .authenticatedContext('calendar-other')
    .firestore();
  const preferencePath = `users/${ownerId}/calendarPreferences/display-hours`;
  const ownerReference = doc(ownerFirestore, preferencePath);
  const otherReference = doc(otherFirestore, preferencePath);
  const preference = {
    userId: ownerId,
    id: 'display-hours',
    startHour: 6,
    endHour: 22,
    updatedAtUtcMillis: 100,
    deletedAtUtcMillis: null,
    mutationId: 'calendar-mutation-1',
  };

  await assertSucceeds(setDoc(ownerReference, preference));
  await assertSucceeds(getDoc(ownerReference));
  await assertFails(getDoc(otherReference));
  await assertFails(
    setDoc(doc(ownerFirestore, `users/${ownerId}/calendarPreferences/other`), {
      ...preference,
      id: 'other',
    }),
  );
  await assertFails(
    updateDoc(ownerReference, {
      startHour: 22,
      endHour: 22,
      updatedAtUtcMillis: 200,
      mutationId: 'calendar-mutation-invalid',
    }),
  );
  await assertSucceeds(
    updateDoc(ownerReference, {
      startHour: 8,
      endHour: 20,
      updatedAtUtcMillis: 200,
      mutationId: 'calendar-mutation-2',
    }),
  );
  await assertFails(deleteDoc(otherReference));
  await assertSucceeds(deleteDoc(ownerReference));
});
