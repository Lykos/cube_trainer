import { RailsService } from '@core/rails.service';
import { CableService } from '@core/cable.service';
import { Injectable } from '@angular/core';
import { Message } from './message.model';
import { MessageNotification } from './message-notification.model';
import { map } from 'rxjs/operators';
import { fromDateString } from '@utils/instant'
import { Observable } from 'rxjs';

interface RawMessage extends Omit<Message, 'timstamp'> {
  createdAt: string;
}

function parseMessage(message: RawMessage): Message {
  return {
    ...message,
    timestamp: fromDateString(message.createdAt),
  }
}

interface UnreadMessagesCount {
  readonly unreadMessagesCount: number;
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

  // Note that this is not a regular request to the backend. This uses action cable and will continuously update.
  unreadCountNotifications(): Observable<number> {
    return this.cableService.channelSubscription<UnreadMessagesCount>('UnreadMessagesCountChannel').pipe(
      map(m => m.unreadMessagesCount),
    );
  }

  notifications(): Observable<MessageNotification> {
    return this.cableService.channelSubscription<MessageNotification>('MessageChannel');
  }
}
