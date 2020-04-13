import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http_verb';
import { Message } from './message';
import { map } from 'rxjs/operators';
import { fromDateString } from '../utils/instant'
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class MessagesService {
  constructor(private readonly rails: RailsService) {}

  parseMessage(message: any): Message {
    return {
      id: message.id,
      title: message.title,
      body: message.body,
      read: message.read,
      timestamp: fromDateString(message.created_at),
    }
  }

  countUnread(userId: number): Observable<number> {
    return this.rails.ajax<number>(HttpVerb.Get, `/users/${userId}/unread_messages_count`, {})
  }

  list(userId: number): Observable<Message[]> {
    return this.rails.ajax<any[]>(HttpVerb.Get, `/users/${userId}/messages`, {}).pipe(
      map(messages => messages.map(this.parseMessage)));
  }

  show(userId: number, messageId: number): Observable<Message> {
    return this.rails.ajax<any>(HttpVerb.Get, `/users/${userId}/messages/${messageId}`, {}).pipe(
      map(this.parseMessage));
  }
}
