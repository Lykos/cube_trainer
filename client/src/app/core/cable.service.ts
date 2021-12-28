import { AngularTokenService } from 'angular-token';
import { Injectable } from '@angular/core';
import { Cable, ChannelNameWithParams, Channel } from 'actioncable';
import * as ActionCable from 'actioncable';
import { environment } from '@environment';
import { Observable, of } from 'rxjs';
import { distinctUntilChanged, switchMap, shareReplay } from 'rxjs/operators';
import { mapOptional, orElse } from '@utils/optional';
import { Store } from '@ngrx/store';
import { User } from './user.model';
import { selectUser } from '@store/user.selectors';

@Injectable({
  providedIn: 'root'
})
export class CableService {
  private consumer$: Observable<Cable>;

  constructor(private readonly tokenService: AngularTokenService,
              private readonly store: Store) {
    this.consumer$ = this.switchToActiveUser(() => this.createConsumer());
  }

  private switchToActiveUser<X>(f: (user: User) => Observable<X>) {
    return this.store.select(selectUser).pipe(
      distinctUntilChanged(undefined as any, user => orElse(mapOptional(user, user => user.id), undefined)),
      switchMap(user => orElse(mapOptional(user, f), of())),
      shareReplay(),
    );
  }

  private createConsumer(): Observable<Cable> {
    return new Observable<Cable>(subscriber => {
      try {
        const authData = this.tokenService.currentAuthData;
        if (!authData) {
          throw new Error('Tried to create a consumer before authentication.');
        }
        console.log('Connecting to ActionCable');
        subscriber.next(ActionCable.createConsumer(`${environment.actionCableUrl}/?client=${authData.client}&uid=${authData.uid}&access_token=${authData.accessToken}`));
        subscriber.complete();
      } catch (error: any) {
        subscriber.error(error);
      }
    });
  }

  channelSubscription<X>(channelName: string | ChannelNameWithParams): Observable<X> {
    return this.consumer$.pipe(switchMap(consumer => {
      return new Observable<X>(subscriber => {
        const channel: Channel = consumer.subscriptions.create(channelName, {
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
    }));
  }
}
