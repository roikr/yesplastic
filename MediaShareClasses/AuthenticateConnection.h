//
//  AuthenticateConnection.h
//  IMBooster
//
//  Created by Roee Kremer on 01/01/10.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZoozzConnection.h"

@protocol AuthenticateConnectionDelegate;

@class SKPaymentTransaction;
@interface AuthenticateConnection : NSObject<ZoozzConnectionDelegate> {	
	id <AuthenticateConnectionDelegate> delegate;
	ZoozzConnection *connection;
	SKPaymentTransaction *transaction;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) ZoozzConnection *connection;
@property (nonatomic, retain) SKPaymentTransaction *transaction;

//- (id) initWithRequestType:(ZoozzRequestType)requestType withTransaction:(SKPaymentTransaction *)theTransaction withProductIdentifier:(NSString *)identifier delegate:(id<AuthenticateConnectionDelegate>)theDelegate;
- (id) initWithTransaction:(SKPaymentTransaction *)theTransaction delegate:(id<AuthenticateConnectionDelegate>)theDelegate;
- (id) initWithProductIdentifier:(NSString *)identifier delegate:(id<AuthenticateConnectionDelegate>)theDelegate;
- (id) initWithDelegate:(id<AuthenticateConnectionDelegate>)theDelegate;

@end


@protocol AuthenticateConnectionDelegate<NSObject>
- (void)AuthenticateConnectionDidFinishLoading:(AuthenticateConnection *)authenticateConnection;
- (void)AuthenticateConnectionDidFailLoading:(AuthenticateConnection *)authenticateConnection;
@end
