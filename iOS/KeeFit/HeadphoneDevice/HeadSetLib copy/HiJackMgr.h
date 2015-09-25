//
//  HiJack.h
//  HiJack Library for easy interaction with a HiJack device. This library has two 
//  main functions, the 'send' function of HiJackMgr and the HiJackDelegate's 
//  receive function. 'send' is used to send a byte to the HiJack, while 'receive' is
//  triggered when the library decodes a message coming from the HiJack device.
//
//  Created by Thomas Schmid on 8/4/11.

#import <Foundation/Foundation.h>
#import "AudioUnit/AudioUnit.h"
#import "aurio_helper.h"
#import "CAStreamBasicDescription.h"


typedef enum{
    HeadSetConnectManchester,
    HeadSetConnectFsk
}HeadSetConnectMode;



@protocol HiJackDelegate;

@interface HiJackMgr : NSObject 
{
	id <HiJackDelegate>			theDelegate;
	
	AudioUnit					rioUnit;
	AURenderCallbackStruct		inputProc;
	DCRejectionFilter*			dcFilter;
	CAStreamBasicDescription	thruFormat;
	Float64						hwSampleRate;

	UInt8						uartByteTransmit;
	BOOL						mute;
	BOOL						newByte;
	UInt32						maxFPS;
//    int                        soundChannel; //0 is left channel,1 is right channel

}
	
- (void) setDelegate:(id <HiJackDelegate>) delegate;
- (id) init;
- (int) send:(UInt8)data;
- (void) fskSendData: (NSData *)data;
- (void) setupRemoteIo;
- (void) unSetupRemoteIo;

@property (nonatomic, assign)	AudioUnit				rioUnit;
@property (nonatomic, assign)	AURenderCallbackStruct	inputProc;
@property (nonatomic, assign)	int						unitIsRunning;
@property (nonatomic, assign)   UInt8					uartByteTransmit;
@property (nonatomic, assign)   UInt32					maxFPS;
@property (nonatomic, assign)	BOOL					newByte;
@property (nonatomic, assign)	BOOL					mute;
@property (nonatomic, assign)	int					soundChannel;

//引导码(fsk)
@property (nonatomic, assign)   int                     leadSignCount;

@property (nonatomic, copy)     NSData                  *dataToSend;
@property (nonatomic, assign)   int                     dataSendIndex;

//通讯算法模式，一种是曼彻斯特，一种是Fsk
@property (assign, atomic) HeadSetConnectMode headSetConnectMode;

@end
	
	
@protocol HiJackDelegate <NSObject>

- (int) receive:(UInt8)data;
@end
