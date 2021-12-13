import { RailsService } from '../rails/rails.service';
import { CableService } from '../rails/cable.service';
import { selectUser } from '../state/user.selectors';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { Message } from './message.model';
import { MessageNotification } from './message-notification.model';
import { map, distinctUntilChanged, switchMap, shareReplay } from 'rxjs/operators';
import { hasValue, mapOptional, orElse } from '../utils/optional';
import { fromDateString } from '../utils/instant'
import { Observable, of } from 'rxjs';
import { Store } from '@ngrx/store';

function parseMessage(message: any): Message {
  return {
    id: message.id,
    title: message.title,
    body: message.body,
    read: message.read,
    timestamp: fromDateString(message.created_at),
  }
}


@Injectable({
  providedIn: 'root',
})
export class MessagesService {
  constructor(private readonly rails: RailsService,
              private readonly cableService: CableService,
              private readonly store: Store) {}

  countUnread(): Observable<number> {
    return this.rails.ajax<number>(HttpVerb.Get, '/messages/count_unread', {})
  }

  markAsRead(messageId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Put, `/messages/${messageId}`, {message: {read: true}})
  }

  destroy(messageId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, `/messages/${messageId}`, {})
  }

  list(): Observable<Message[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, '/messages', {}).pipe(
      map(messages => messages.map(parseMessage)));
  }

  show(messageId: number): Observable<Message> {
    return this.rails.ajax<any>(HttpVerb.Get, `/messages/${messageId}`, {}).pipe(
      map(parseMessage));
  }

  unreadCountNotifications(): Observable<number> {
    return this.store.select(selectUser).pipe(
      distinctUntilChanged(undefined, user => orElse(mapOptional(user, user => user.id), undefined)),
      switchMap(user => {
        return hasValue(user) ? this.cableService.channelSubscription<number>('UnreadMessagesCountChannel') : of(0);
      }),
      shareReplay(),
    );
  }

  notifications(): Observable<MessageNotification> {
    return this.store.select(selectUser).pipe(
      distinctUntilChanged(undefined, user => orElse(mapOptional(user, user => user.id), undefined)),
      switchMap(user => {
        return hasValue(user) ? this.cableService.channelSubscription<MessageNotification>('MessageChannel') : of();
      }),
      shareReplay(),
    );
  }
}
