import { RailsService } from '../rails/rails.service';
import { Injectable } from '@angular/core';
import { HttpVerb } from '../rails/http-verb';
import { Message } from './message.model';
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
      map(messages => messages.map(this.parseMessage)));
  }

  show(messageId: number): Observable<Message> {
    return this.rails.ajax<any>(HttpVerb.Get, `/messages/${messageId}`, {}).pipe(
      map(this.parseMessage));
  }
}
