//
//  URLDatabaseHandler.m
//  Practice3
//
//  Created by Mike on 2/21/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "URLDatabaseHandler.h"

@implementation URLDatabaseHandler




-(bool) queryCounter : (bool) bStartUp
{
  UIDevice *device = [UIDevice currentDevice];
  NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
  // Create url connection and fire request
  // Start NSURLSession
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  // POST parameters
  NSURL *url = [NSURL URLWithString:@"http://www.lewisandpark.com/Stats/"];
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  NSString *params=nil;
  if(!bStartUp)
    params = [NSString stringWithFormat:@"device_id=%@", uniqueIdentifier];
  else
    params = [NSString stringWithFormat:@"device_id=%@&startup=1", uniqueIdentifier];
  
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
  
  // NSURLSessionDataTask returns data, response, and error
  NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                   {
                                     // Remove progress window
                                     NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                     NSInteger statusCode = [httpResponse statusCode];
                                     if(error == nil)
                                     {
                                       if (statusCode == 400 || statusCode==401)
                                       {
                                         return true;
                                       }
                                       else if (statusCode == 200)
                                       {
                                         // Parse out the JSON data
                                         NSError *jsonError;
                                         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions
                                                                                                error:&jsonError];
                                         
                                         //NSString* unlockCode = [json objectForKey:@"unlock_code"];
                                         // JSON data parsed, continue handling response
                                         self.m_bSearchLimitExceeded=false;
                                       }
                                       else
                                       {
                                         return false;self.m_bSearchLimitExceeded=false;
                                       }
                                     }
                                     else
                                     {
                                       
                                     }}];
  
  [dataTask resume];
  return;
}










@end
