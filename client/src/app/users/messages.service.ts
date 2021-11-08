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

  countUnread(userId: number): Observable<number> {
    return this.rails.ajax<number>(HttpVerb.Get, `/users/${userId}/messages/count_unread`, {})
  }

  markAsRead(userId: number, messageId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Put, `/users/${userId}/messages/${messageId}`, {message: {read: true}})
  }

  destroy(userId: number, messageId: number): Observable<void> {
    return this.rails.ajax<void>(HttpVerb.Delete, `/users/${userId}/messages/${messageId}`, {})
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
