import { RailsService } from '@core/rails.service';
import { CableService } from '@core/cable.service';
import { Injectable } from '@angular/core';
import { Message } from './message.model';
import { MessageNotification } from './message-notification.model';
import { map } from 'rxjs/operators';
import { fromDateString } from '@utils/instant'
import { Observable } from 'rxjs';
import { FieldMissingError, FieldTypeError } from '@shared/rails-parse-error';

interface RawMessage {
  readonly id?: unknown;
  readonly title?: unknown;
  readonly body?: unknown;
  readonly read?: unknown;
  readonly createdAt?: unknown;
}

function parseMessage(message: RawMessage): Message {
  if (message.id === undefined) {
    throw new FieldMissingError('id', 'message', message);
  }
  if (typeof message.id !== 'number') {
    throw new FieldTypeError('id', 'number', 'message', message);
  }
  if (message.title === undefined) {
    throw new FieldMissingError('title', 'message', message);
  }
  if (typeof message.title !== 'string') {
    throw new FieldTypeError('title', 'string', 'message', message);
  }
  if (message.body !== undefined && typeof message.body !== 'string') {
    throw new FieldTypeError('body', 'string', 'message', message);
  }
  if (message.read === undefined) {
    throw new FieldMissingError('read', 'message', message);
  }
  if (typeof message.read !== 'boolean') {
    throw new FieldTypeError('read', 'boolean', 'message', message);
  }
  if (message.createdAt === undefined) {
    throw new FieldMissingError('createdAt', 'message', message);
  }
  if (typeof message.createdAt !== 'string') {
    throw new FieldTypeError('createdAt', 'string', 'message', message);
  }
  return {
    id: message.id,
    title: message.title,
    body: message.body,
    read: message.read,
    timestamp: fromDateString(message.createdAt),
  }
}

interface UnreadMessagesCount {
  readonly unreadMessagesCount?: number;
}

@Injectable({
  providedIn: 'root',
})
export class MessagesService {
  constructor(private readonly rails: RailsService,
              private readonly cableService: CableService) {}

  markAsRead(messageId: number): Observable<void> {
    return this.rails.patch<void>(`/messages/${messageId}`, {message: {read: true}})
  }

  destroy(messageId: number): Observable<void> {
    return this.rails.delete<void>(`/messages/${messageId}`, {})
  }

  list(): Observable<Message[]> {
    return this.rails.get<RawMessage[]>('/messages', {}).pipe(
      map(messages => messages.map(parseMessage)));
  }

  show(messageId: number): Observable<Message> {
    return this.rails.get<RawMessage>(`/messages/${messageId}`, {}).pipe(
      map(parseMessage));
  }

  unreadCountNotifications(): Observable<number> {
    return this.cableService.channelSubscription<UnreadMessagesCount>('UnreadMessagesCountChannel').pipe(
      map(m => {
        if (m.unreadMessagesCount === undefined) {
          throw new FieldMissingError('unreadMessagesCount', 'UnreadMessagesCount', m);
        }
        return m.unreadMessagesCount;
      }),
    );
  }

  notifications(): Observable<MessageNotification> {
    return this.cableService.channelSubscription<MessageNotification>('MessageChannel');
  }
}
