import { AngularTokenService } from 'angular-token';
import { Injectable } from '@angular/core';
import { Cable, ChannelNameWithParams, Channel } from 'actioncable';
import * as ActionCable from 'actioncable';
import { environment } from './../../environments/environment';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class CableService {
  private consumer: Cable;

  constructor(private readonly tokenService: AngularTokenService) {}

  private getOrCreateConsumer() {
    if (!this.consumer) {
      const authData = this.tokenService.currentAuthData;
      if (!authData) {
        throw new Error('Tried to create a consumer before authentication.');
      }
      this.consumer = ActionCable.createConsumer(`${environment.actionCableUrl}?client=${authData.client}&uid=${authData.uid}&access_token=${authData.accessToken}`);
    }
    return this.consumer;
  }

  channelSubscription<X>(channelName: string | ChannelNameWithParams): Observable<X> {
    return new Observable(subscriber => {
      const channel: Channel = this.getOrCreateConsumer().subscriptions.create(channelName, {
        disconnected: () => {
          subscriber.complete();
        },
        received: (x: X) => {
          subscriber.next(x);
        },
      });
      return () => {
        channel.unsubscribe();
      };
    });
  }
}
