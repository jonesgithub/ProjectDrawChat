#import <Foundation/Foundation.h>

@protocol ArthurNetworkOperation_AsynPost <NSObject>
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection: (NSURLConnection *)connection didSuccessWithData: (NSDictionary *)dictData;
@end

@interface ArthurNetworkOperation : NSObject

@property (copy, nonatomic) NSString *strName;
@property (nonatomic, retain)  NSMutableData *receiveData;
@property (nonatomic, retain)  NSURLConnection *connection;
@property (nonatomic, assign)  id<ArthurNetworkOperation_AsynPost> delegate;

+(NSString *) synGet: (NSString *) str_url;
+(NSString *) synPost: (NSString *) str_url post_data:(NSString*)post_data;
//改良版
+(NSDictionary *) synPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName;
+(NSURLConnection *) asynGet: (NSString *) str_url delegate: (id)delegate;
+(NSURLConnection *) asynPostURL:(NSString *)strURL data:(NSDictionary*)dictData name:(NSString*)strName delegate: (id<ArthurNetworkOperation_AsynPost>) delegate;


@end
