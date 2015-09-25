//
//  HiJackMgr.m
//  HiJack
//
//  Created by Thomas Schmid on 8/4/11.
//

#import "HiJackMgr.h"
#import "AudioUnit/AudioUnit.h"
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAXException.h"
#import "aurio_helper.h"

#import "CDUtil.h"
#import "CDConstants.h"

//#ifdef LogAudioDebug
//#import "DebugAudioLogFile.h"
//#endif


enum uart_state {
	STARTBIT = 0,
	SAMEBIT  = 1,
	NEXTBIT  = 2,
	STOPBIT  = 3,
	STARTBIT_FALL = 4,
	DECODE   = 5,
};

enum fsk_uart_state {
    fsk_prepare_state,
	fsk_start_state,
	fsk_data_state,
    fsk_STARTBIT,
    fsk_NEXTBIT,
    fsk_SAMEBIT
};

#define fc 1200
#define df 100
#define T (1/df)
#define N (SInt32)(T * THIS->hwSampleRate)
#define THRESHOLD 2200000 // threshold used to detect start bit 原来是200000
#define HIGHFREQ 1378.125 // baud rate. best to take a divisible number for 44.1kS/s
#define SAMPLESPERBIT 32 // (44100 / HIGHFREQ)  // how many samples per UART bit

#define FSKSAMPLESPERBIT 48

//#define SAMPLESPERBIT 5 // (44100 / HIGHFREQ)  // how many samples per UART bit
//#define HIGHFREQ (44100 / SAMPLESPERBIT) // baud rate. best to take a divisible number for 44.1kS/s
#define LOWFREQ (HIGHFREQ / 2)
#define SHORT (SAMPLESPERBIT/2 + SAMPLESPERBIT/4) // 
#define LONG (SAMPLESPERBIT + SAMPLESPERBIT/2)    //
#define NUMSTOPBITS 12 // number of stop bits to send before sending next value.
//#define NUMSTOPBITS 10 // number of stop bits to send before sending next value.
#define AMPLITUDE (1<<24)

#define MAX_VALUE 16777216
#define MIN_VALUE -16777216

//#define DEBUG // verbose output about the bits and symbols
#define DEBUG2 // output the byte values encoded
//#define DEBUGWAVE // enables output of the waveform after the 10th byte is sent. CAREFUL!!! Usually overloads debug output
//#define DECDEBUGBYTE // output the received byte only
//#define DECDEBUG // output for decoding debugging
//#define DECDEBUG2 // verbose decoding output

//用于fsk，表示一个bit由48个采样点确定
static const int PhasePointsCount = 48;

@interface HiJackMgr ()

void rioInterruptionListener(void *inClientData, UInt32 inInterruption);
void propListener(void * inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void * inData);

@end


@implementation HiJackMgr

@synthesize rioUnit;
@synthesize inputProc;
@synthesize unitIsRunning;
@synthesize uartByteTransmit;
@synthesize maxFPS;
@synthesize newByte;
@synthesize mute;
@synthesize soundChannel;

#pragma mark -Audio Session Interruption Listener

void rioInterruptionListener(void *inClientData, UInt32 inInterruption)
{
	printf("Session interrupted! --- %s ---", inInterruption == kAudioSessionBeginInterruption ? "Begin Interruption" : "End Interruption");
		
	if (inInterruption == kAudioSessionEndInterruption) {
		// make sure we are again the active session
        //自己试试完全注释掉原来的处理逻辑，自己销毁，自己重建
		//AudioSessionSetActive(true);
		//AudioOutputUnitStart(THIS->rioUnit);
        

	}
	
	if (inInterruption == kAudioSessionBeginInterruption) {
        
		//AudioOutputUnitStop(THIS->rioUnit);
    }
}

#pragma mark -Audio Session Property Listener

void propListener(	void *                  inClientData,
				  AudioSessionPropertyID	inID,
				  UInt32                  inDataSize,
				  const void *            inData)
{
	HiJackMgr*THIS = (__bridge HiJackMgr*)inClientData;
	
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		try {
			// if there was a route change, we need to dispose the current rio unit and create a new one
            
            
            //试一下别的方法能不能替换掉这两行的作用
            
//			XThrowIfError(AudioComponentInstanceDispose(THIS->rioUnit), "couldn't dispose remote i/o unit");		
//			
//			SetupRemoteIO(THIS->rioUnit, THIS->inputProc, THIS->thruFormat);
			
            //AudioUnitReset(THIS->rioUnit, kAudioUnitScope_Global, 0);
            
            
            
			UInt32 size = sizeof(THIS->hwSampleRate);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &THIS->hwSampleRate), "couldn't get new sample rate");
//			printf("THIS->hwSampleRate: %f", THIS->hwSampleRate);
			////////////////XThrowIfError(AudioOutputUnitStart(THIS->rioUnit), "couldn't start unit");
			
			// we need to rescale the sonogram view's color thresholds for different input
			CFStringRef newRoute;
			size = sizeof(CFStringRef);
			XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute), "couldn't get new audio route");
			if (newRoute)
			{	
                //HeadsetInOut
				//CFShow(newRoute);
                if (CFStringCompare(newRoute, CFSTR("HeadsetInOut"), NULL) == kCFCompareEqualTo) {
                
                    THIS->newByte = FALSE;
                    THIS->mute = NO;
                }else {
                    
                    THIS->mute = YES;
                }
                //TODO: 应监听状态变化
                [[NSNotificationCenter defaultCenter] postNotificationName:AudioRouteChangeNotification object:[NSString stringWithFormat:@"%@",newRoute]];
			}
		} catch (CAXException e) {
			char buf[256];
			fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		}
		
	}
}


#pragma mark -RIO Render Callback

//曼彻斯特编解码
static void manchesterThru(void						*inRefCon,
                               AudioUnitRenderActionFlags 	*ioActionFlags,
                               const AudioTimeStamp 		*inTimeStamp,
                               UInt32 						inBusNumber,
                               UInt32 						inNumberFrames, 
                               AudioBufferList 			*ioData
                               ){
    
    HiJackMgr *THIS = (__bridge HiJackMgr *)inRefCon;
    
    // TX vars
    //	static UInt32 phase = 0;
	static UInt32 phase2 = 0;
	static UInt32 lastPhase2 = 0;
	static SInt32 sample = 0;
	static SInt32 lastSample = 0;
	static int decState = STARTBIT;
	static int byteCounter = 1;
	static UInt8 parityTx = 0;
	
	// UART decoding
	static int bitNum = 0;
	static uint8_t uartByte = 0;
	
	// UART encode
	static uint32_t phaseEnc = 0;
	static uint32_t nextPhaseEnc = SAMPLESPERBIT;
	static uint8_t uartByteTx = 0x0;
	static uint32_t uartBitTx = 0;
	static uint8_t state = STARTBIT;
	static float uartBitEnc[SAMPLESPERBIT];
	static uint8_t currentBit = 1;
	static UInt8 parityRx = 0;
	
	
	
	// Remove DC component
	//for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
	//	THIS->dcFilter[i].InplaceFilter((SInt32*)(ioData->mBuffers[i].mData), inNumberFrames, 1);
    
    
    //    if (!THIS->newByte) {
    
    
    
    
    SInt32* lchannel = (SInt32*)(ioData->mBuffers[0].mData);
    //	printf("sample %f\n", THIS->hwSampleRate);
    
    /************************************
     * UART Decoding
     ************************************/
#if 1
    for(int j = 0; j < inNumberFrames; j++) {
        float val = lchannel[j];
        
//        printf("%f\n", val);
        
        //#ifdef LogAudioDebug
        //        [[DebugAudioLogFile sharedDebugAudioLog] addNewSample:audioSampleValue];
        //#endif
        
#ifdef DEBUGWAVE
        printf("%8ld, %8.0f\n", phase2, val);
#endif
#ifdef DECDEBUG2
        if(decState == DECODE)
            printf("%8ld, %8.0f\n", phase2, val);
#endif
        phase2 += 1;
        if (val < -THRESHOLD) {
            sample = 0;
        } else if (val > THRESHOLD){
            sample = 1;
        }
        if (sample != lastSample) {
            // transition
            SInt32 diff = phase2 - lastPhase2;
            switch (decState) {
                case STARTBIT:
                    if (lastSample == 0 && sample == 1)
                    {
                        // low->high transition. Now wait for a long period
                        decState = STARTBIT_FALL;
                    }
                    break;
                case STARTBIT_FALL:
                    if (( SHORT < diff ) && (diff < LONG) )
                    {
                        // looks like we got a 1->0 transition.
                        bitNum = 0;
                        parityRx = 0;
                        uartByte = 0;
                        decState = DECODE;
                    } else {
                        decState = STARTBIT;
                    }
                    break;
                case DECODE:
                    if (( SHORT < diff) && (diff < LONG) ) {
                        // we got a valid sample.
                        if (bitNum < 8) {
                            uartByte = ((uartByte >> 1) + (sample << 7));
                            bitNum += 1;
                            parityRx += sample;
#ifdef DECDEBUG
                            printf("Bit %d value %ld diff %ld parity %d\n", bitNum, sample, diff, parityRx & 0x01);
#endif
                        } else if (bitNum == 8) {
                            // parity bit
                            if(sample != (parityRx & 0x01))
                            {
#ifdef DECDEBUGBYTE
                                printf(" -- parity %ld,  UartByte 0x%x\n", sample, uartByte);
#endif
                                decState = STARTBIT;
                            } else {
#ifdef DECDEBUG
                                printf(" ++ good parity %ld, UartByte 0x%x\n", sample, uartByte);
#endif
                                
                                bitNum += 1;
                            }
                            
                        } else {
                            // we should now have the stopbit
                            if (sample == 1) {
                                // we have a new and valid byte!
#ifdef DECDEBUGBYTE
                                printf(" ++ StopBit: %ld UartByte 0x%x\n", sample, uartByte);
#endif

                                
                                //////////////////////////////////////////////
                                // This is where we receive the byte!!!
                                
                                @autoreleasepool {
                                    if([THIS->theDelegate respondsToSelector:@selector(receive:)]) {
                                        
                                        [THIS->theDelegate receive:uartByte];
                                    }
                                }
                                
                            } else {
                                // not a valid byte.
#ifdef DECDEBUGBYTE
                                printf(" -- StopBit: %ld UartByte %d\n", sample, uartByte);
#endif
                            }
                            decState = STARTBIT;
                        }
                    } else if (diff > LONG) {
#ifdef DECDEBUG
                        printf("diff too long %ld\n", diff);
#endif
                        decState = STARTBIT;
                    } else {
                        // don't update the phase as we have to look for the next transition
                        lastSample = sample;
                        continue;
                    }
                    
                    break;
                default:
                    break;
            }
            lastPhase2 = phase2;
        }
        lastSample = sample;
    }
#endif
	
    //    }else{
    if (THIS->mute == NO) {
        // prepare sine wave
        
        SInt32 values[inNumberFrames];
        /*******************************
         * Generate 22kHz Tone
         *******************************/
        
        //		double waves;
        //		//printf("inBusNumber %d, inNumberFrames %d, ioData->NumberBuffers %d mNumberChannels %d\n", inBusNumber, inNumberFrames, ioData->mNumberBuffers, ioData->mBuffers[0].mNumberChannels);
        //		//printf("size %d\n", ioData->mBuffers[0].mDataByteSize);
        //		//printf("sample rate %f\n", THIS->hwSampleRate);
        //		for(int j = 0; j < inNumberFrames; j++) {
        //
        //
        //			waves = 0;
        //
        //			//waves += sin(M_PI * 2.0f / THIS->hwSampleRate * 22050.0 * phase);
        //			waves += sin(M_PI * phase+0.5); // This should be 22.050kHz
        //
        //			waves *= (AMPLITUDE); // <--------- make sure to divide by how many waves you're stacking
        //
        //			values[j] = (SInt32)waves;
        //			//values[j] += values[j]<<16;
        //			//printf("%d: %ld\n", phase, values[j]);
        //			phase++;
        //
        //		}
        //		// copy sine wave into left channels.
        //		//memcpy(ioData->mBuffers[0].mData, values, ioData->mBuffers[0].mDataByteSize);
        //		// copy sine wave into right channels.
        //		memcpy(ioData->mBuffers[1].mData, values, ioData->mBuffers[1].mDataByteSize);
        /*******************************
         * UART Encoding
         *******************************/
        for(int j = 0; j< inNumberFrames; j++) {
            if ( phaseEnc >= nextPhaseEnc){
                if (uartBitTx >= NUMSTOPBITS && THIS->newByte == TRUE) {
                    state = STARTBIT;
                    THIS->newByte = FALSE;
                } else {
                    state = NEXTBIT;
                }
            }
            
            switch (state) {
                case STARTBIT:
                {
                    //////////////////////////////////////////////
                    // FIXME: This is where we inject the message!
                    //////////////////////////////////////////////
                    
                    //uartByteTx = (uint8_t)THIS->slider.value;
                    uartByteTx = THIS->uartByteTransmit;
                    //uartByteTx = 255;
                    //uartByteTx += 1;
#ifdef DEBUG2
                    printf("-send-: 0x%x\n", uartByteTx);
#endif
                    byteCounter += 1;
                    uartBitTx = 0;
                    parityTx = 0;
                    
                    state = NEXTBIT;
                    // break; UNCOMMENTED ON PURPOSE. WE WANT TO FALL THROUGH!
                }
                case NEXTBIT:
                {
                    uint8_t nextBit;
                    if (uartBitTx == 0) {
                        // start bit
                        nextBit = 0;
                    } else {
                        if (uartBitTx == 9) {
                            // parity bit
                            nextBit = parityTx & 0x01;
                        } else if (uartBitTx >= 10) {
                            // stop bit
                            nextBit = 1;
                        } else {
                            nextBit = (uartByteTx >> (uartBitTx - 1)) & 0x01;
                            parityTx += nextBit;
                        }
                    }
                    if (nextBit == currentBit) {
                        if (nextBit == 0) {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = -sin(M_PI * 2.0f / THIS->hwSampleRate * HIGHFREQ * (p+1));
                            }
                        } else {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = sin(M_PI * 2.0f / THIS->hwSampleRate * HIGHFREQ * (p+1));
                            }
                        }
                    } else {
                        if (nextBit == 0) {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = sin(M_PI * 2.0f / THIS->hwSampleRate * LOWFREQ * (p+1));
                            }
                        } else {
                            for( uint8_t p = 0; p<SAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = -sin(M_PI * 2.0f / THIS->hwSampleRate * LOWFREQ * (p+1));
                            }
                        }
                    }
                    
#ifdef DEBUG
                    printf("BitTX %d: last %d next %d\n", uartBitTx, currentBit, nextBit);
#endif
                    currentBit = nextBit;
                    uartBitTx++;
                    state = SAMEBIT;
                    phaseEnc = 0;
                    nextPhaseEnc = SAMPLESPERBIT;
                    
                    break;
                }
                default:
                    break;
            }
            
            values[j] = (SInt32)(uartBitEnc[phaseEnc%SAMPLESPERBIT] * AMPLITUDE);
            
            if(values[j]>0) values[j] = MAX_VALUE;
            if(values[j]<0) values[j] = MIN_VALUE;
#ifdef DEBUG
            printf("val %ld\n", values[j]);
#endif
            phaseEnc++;
            
        }
        memcpy(ioData->mBuffers[THIS->soundChannel].mData, values, ioData->mBuffers[THIS->soundChannel].mDataByteSize);
    }
    
    //    }
    
}

//FSK编解码
static void fskThru(
                    void						*inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)
{
    HiJackMgr *THIS = (__bridge HiJackMgr *)inRefCon;
    
    // UART decoding
	static int bitNum = 0;
	static uint8_t uartByte = 0;
	
	// UART encode
	static uint32_t phaseEnc = 0;
	static uint32_t nextPhaseEnc = FSKSAMPLESPERBIT;
	static uint8_t uartByteTx = 0x0;
	static uint32_t uartBitTx = 0;
	static float uartBitEnc[FSKSAMPLESPERBIT];
	static UInt8 parityRx = 0;
	static uint8_t state = fsk_STARTBIT;
    static uint8_t currentBit = 1;
    static int byteCounter = 1;
    static UInt8 parityTx = 0;
    
    
    
    static int amplitudeSamples[4] = {0}; //4个连续采样值的Buffer，用于判断当前大概的一个信号幅值情况
    
    static int phaseSamples[PhasePointsCount] = {0}; //48个连续采样值形成的buffer，用于判断上升沿的个数
    static int phaseSamplesHeaderIndex = 0;   //buffer的头索引(头指最新的值)
    
    static int currentUpCount = 0; //上升沿个数\
    
    static SInt32 lastVal = 0;      //上一个采样值
    
	SInt32* lchannel = (SInt32*)(ioData->mBuffers[0].mData);
	
    static fsk_uart_state currentState = fsk_prepare_state; //当前的状态
    
    static int currentBitValue = -1;
    
    
//    static int currentDataBit = -1;
    
    
    static int currentTime = 0;
    
    //发送过来的信号是否处于数据信号区
    static BOOL isInDataArea = NO;
    
//    static BOOL isInBigAmplitudeArea = NO;
    
//    static int continueSmallNum = 0;
    
    
//    static SInt32 pointIndex = 0;
//    static double upPointPosition = 0.0;
    
//    static BOOL isFall = YES;
    
    
    SInt32 values[inNumberFrames];
    
    
    if (!THIS->newByte) {
        
        
        
        //FSK通讯
        //接收数据区
        for(int j = 0; j < inNumberFrames; j++) {
            
            
            //            values[j] = sin(M_PI * 2.0f / 16 * (j%16)) * 5000;
            
            
            currentTime += 1;
            
            SInt32 val = lchannel[j];
            
//            printf("%d\n", (int)val);
            
            
            SInt32 localLastVal = lastVal;
            lastVal = val;
            
            
            //取出以前的值
            SInt32 tailVal = phaseSamples[(phaseSamplesHeaderIndex+1) % PhasePointsCount]; //倒数第一个值
            SInt32 secondTailVal = phaseSamples[(phaseSamplesHeaderIndex+2) % PhasePointsCount]; //倒数第二个值
            
            
            //更新phaseSamples
            phaseSamples[(phaseSamplesHeaderIndex+1) % PhasePointsCount] = val;
            phaseSamplesHeaderIndex = (phaseSamplesHeaderIndex+1) % PhasePointsCount;
            
            if (localLastVal < 0 && val > 0) {
                currentUpCount += 1;
            }
            
            if (tailVal < 0 && secondTailVal > 0) {
                //尾部要失去一个上升沿
                currentUpCount -= 1;
            }
            
            
            
            //            currentUpCount = getCycle(phaseSamples, 48);
            //            phaseSamples[47] = (int)val;
            
            //            printf("currentUpCount: %d\n", currentUpCount);
            
            //判断当前区域是否是幅值比较大的区域
            int bigSamplesCount = 0;
            for (int i=0; i<4; i++) {
                if (ABS(amplitudeSamples[i]) > 2000000) {
                    bigSamplesCount += 1;
                }
                if (i < 3) {
                    amplitudeSamples[i] = amplitudeSamples[i+1];
                }
            }
            amplitudeSamples[3] = val;
            
            if (bigSamplesCount>=2 && currentUpCount >= 7 && currentUpCount<=13) {
                isInDataArea = YES;
//                printf("%d\n", (int)val);
            }else{
                if (isInDataArea) {
                    //                    printf("!!!!!!!\n");
                }
                isInDataArea = NO;
            }
            
            if (!isInDataArea) {
                currentState = fsk_prepare_state;
                continue;
            }
            
            
            
            //确认当前识别出来的值
            
            
            
            if (currentUpCount <= 9 && currentUpCount >= 7) {
                currentBitValue = 1;
            }else if (currentUpCount <= 13 && currentUpCount >= 11){
                currentBitValue = 0;
            }

            
            
            if (currentState == fsk_prepare_state) {
                if (currentBitValue == 1) {
                    currentState = fsk_start_state;
                }
            }else if (currentState == fsk_start_state){
                if (currentBitValue == 0) {
                    //                printf("%d\n", (int)val);
                    currentState = fsk_data_state;
                    currentTime = -12;
                    uartByte = 0;
                    bitNum = 0;
                    parityRx = 0;
                }
            }else if (currentState == fsk_data_state){
//                printf("%d\n", (int)val);
                if (currentTime == 48) {
                    currentTime = 0;
//                    printf("%d, %d\n", currentBitValue, currentUpCount);
                    if (bitNum < 8) {
                        //                    printf("%d, %d\n", currentBitValue, currentUpCount);
                        
                        uartByte = (uartByte >> 1) + (currentBitValue << 7);
                        bitNum++;
                        parityRx += currentBitValue;
                    }else if (bitNum == 8){
                        // parity bit
                        if (currentBitValue != (parityRx & 0x01)) {
                            currentState = fsk_prepare_state;
                            currentBitValue = -1;
                        } else {
                            bitNum++;
                        }
                    }else{
                        if (currentBitValue == 1) {
                            
                            @autoreleasepool {
                                if([THIS->theDelegate respondsToSelector:@selector(receive:)]) {
                                    [THIS->theDelegate receive:uartByte];
                                }
                            }
                            
//                            printf("%x\n", uartByte);
                        }
                        currentState = fsk_prepare_state;
                        currentBitValue = -1;
                    }
                }
            }else{
                ;
            }
            
            lastVal = val;
        }
        
        
        //        memcpy(ioData->mBuffers[THIS->soundChannel].mData, values, ioData->mBuffers[THIS->soundChannel].mDataByteSize);
        
        
    }else{
        //发送数据区
        
        
        
        //FSK通讯
        for(int j = 0; j< inNumberFrames; j++) {
            
            if (THIS->_leadSignCount > 0) {
                for( uint8_t p = 0; p<FSKSAMPLESPERBIT; p++)
                {
                    uartBitEnc[p] = sin(M_PI * 2.0f / THIS->hwSampleRate * 7350.0 * (p+1));
                }
                values[j] = (SInt32)(uartBitEnc[phaseEnc%FSKSAMPLESPERBIT] * AMPLITUDE);
                phaseEnc++;
                phaseEnc = phaseEnc%FSKSAMPLESPERBIT;
                //            printf("val %ld\n", values[j]);
            }else{
                
                if ( phaseEnc >= nextPhaseEnc){
                    if (uartBitTx >= NUMSTOPBITS && THIS->newByte == TRUE) {
                        state = fsk_STARTBIT;
                        THIS->_dataSendIndex ++;
                        if (THIS->_dataSendIndex >= [THIS->_dataToSend length]) {
                            THIS->newByte = FALSE;
                            
                            //把已经填充好的数据返回再说
                            for (int i = 0 ; i < j; i++) {
                                //                                printf("%d\n", (int)(values[i]));
                                SInt32 *bufferPoint = (SInt32 *)ioData->mBuffers[1].mData;
                                bufferPoint[i] = values[i];
                            }
                            
                            return;
                        }else{
                            Byte *bytes = (Byte *)[THIS->_dataToSend bytes];
                            THIS->uartByteTransmit = (SInt8)bytes[THIS->_dataSendIndex];
                        }
                        
                    } else {
                        state = fsk_NEXTBIT;
                    }
                }
                
                switch (state) {
                    case fsk_STARTBIT:
                    {
                        //////////////////////////////////////////////
                        // FIXME: This is where we inject the message!
                        //////////////////////////////////////////////
                        
                        //uartByteTx = (uint8_t)THIS->slider.value;
                        uartByteTx = THIS->uartByteTransmit;
                        //uartByteTx = 255;
                        //uartByteTx += 1;
#ifdef DEBUG2
                        printf("-send-: 0x%x\n", uartByteTx);
#endif
                        byteCounter += 1;
                        uartBitTx = 0;
                        parityTx = 0;
                        
                        state = fsk_NEXTBIT;
                        // break; UNCOMMENTED ON PURPOSE. WE WANT TO FALL THROUGH!
                    }
                    case fsk_NEXTBIT:
                    {
                        uint8_t nextBit;
                        if (uartBitTx == 0) {
                            // start bit
                            nextBit = 0;
                        } else {
                            if (uartBitTx == 9) {
                                // parity bit
                                nextBit = parityTx & 0x01;
                            } else if (uartBitTx >= 10) {
                                // stop bit
                                nextBit = 1;
                            } else {
                                nextBit = (uartByteTx >> (uartBitTx - 1)) & 0x01;
                                parityTx += nextBit;
                            }
                        }
                        if (nextBit == 0) {
                            for( uint8_t p = 0; p<FSKSAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = sin(M_PI * 2.0f / THIS->hwSampleRate * 11025.0 * (p+1));
                            }
                        } else {
                            for( uint8_t p = 0; p<FSKSAMPLESPERBIT; p++)
                            {
                                uartBitEnc[p] = sin(M_PI * 2.0f / THIS->hwSampleRate * 7350.0 * (p+1));
                            }
                        }
                        
#ifdef DEBUG
                        printf("BitTX %d: last %d next %d\n", uartBitTx, currentBit, nextBit);
#endif
                        currentBit = nextBit;
                        uartBitTx++;
                        state = fsk_SAMEBIT;
                        phaseEnc = 0;
                        nextPhaseEnc = FSKSAMPLESPERBIT;
                        
                        break;
                    }
                    default:
                        break;
                }
                
                values[j] = (SInt32)(uartBitEnc[phaseEnc%FSKSAMPLESPERBIT] * AMPLITUDE);
                
                //        if(values[j]>0) values[j] = MAX_VALUE;
                //        if(values[j]<0) values[j] = MIN_VALUE;
                
                //            printf("val %ld\n", values[j]);
                
                
#ifdef DEBUG
                printf("val %ld\n", values[j]);
#endif
                phaseEnc++;
            }
            
        }
        
        
        int soundChannel = 1;
        for (int i = 0 ; i < inNumberFrames; i++) {
//            printf("%d\n", (int)(values[i]));
            SInt32 *bufferPoint = (SInt32 *)ioData->mBuffers[soundChannel].mData;
            bufferPoint[i] = values[i];
        }
        
        //        memcpy(ioData->mBuffers[THIS->soundChannel].mData, values, ioData->mBuffers[THIS->soundChannel].mDataByteSize);
        
        THIS->_leadSignCount --;
        
        
        
    }
}

static OSStatus	PerformThru(
							void						*inRefCon,
							AudioUnitRenderActionFlags 	*ioActionFlags,
							const AudioTimeStamp 		*inTimeStamp,
							UInt32 						inBusNumber,
							UInt32 						inNumberFrames,
							AudioBufferList 			*ioData)
{
	HiJackMgr *THIS = (__bridge HiJackMgr *)inRefCon;
	OSStatus err = AudioUnitRender(THIS->rioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
	
    if (err) { printf("PerformThru: error %d\n", (int)err); return err; }
    
    if (THIS->_headSetConnectMode == HeadSetConnectManchester) {
        manchesterThru(inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    }else{
        fskThru(inRefCon, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, ioData);
    }
	
	return err;
}


- (void) setDelegate:(id <HiJackDelegate>) delegate {
	theDelegate = delegate;
}

- (id) init {
	// Initialize our remote i/o unit
    self.headSetConnectMode = (HeadSetConnectMode)[CDUtil headSetConnectMode];
    
    self.soundChannel = [CDUtil soundChannelIndex];
    
	inputProc.inputProc = PerformThru;
	inputProc.inputProcRefCon = (__bridge void*)self;
	
	newByte = FALSE;
	
	try {
		
		// Initialize and configure the audio session
		XThrowIfError(AudioSessionInitialize(NULL, NULL, rioInterruptionListener, (__bridge void*)self), "couldn't initialize audio session");
//        NSLog(@"audio in HiJackMgr.mm");
		//////////XThrowIfError(AudioSessionSetActive(true), "couldn't set audio session active\n"); 为了解决进入程序时ipod自动关闭的问题 注释掉
		
		UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "couldn't set audio category");
		XThrowIfError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void*)self), "couldn't set property listener");
		
        UInt32 allowAudioShouldDuck = true;//设置是否与ipod混合(ipod声音变小,应用程序声音变大)
        AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck, sizeof(allowAudioShouldDuck), &allowAudioShouldDuck);
        
        
        AudioSessionSetActive(false);
        
        Float32 preferredBufferSize = .005;
		XThrowIfError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "couldn't set i/o buffer duration");
		
		UInt32 size = sizeof(hwSampleRate);
		XThrowIfError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &hwSampleRate), "couldn't get hw sample rate");
		
		XThrowIfError(SetupRemoteIO(rioUnit, inputProc, thruFormat), "couldn't setup remote i/o unit");
		
		dcFilter = new DCRejectionFilter[thruFormat.NumberChannels()];
		
		UInt32 maxFPSt;
		size = sizeof(maxFPSt);
		XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFPSt, &size), "couldn't get the remote I/O unit's max frames per slice");
		self.maxFPS = maxFPSt;
		
		/////////////XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
		
		size = sizeof(thruFormat);
		XThrowIfError(AudioUnitGetProperty(rioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &thruFormat, &size), "couldn't get the remote I/O unit's output client format");
		
		unitIsRunning = 1;
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		unitIsRunning = 0;
		if (dcFilter) delete[] dcFilter;
	}
	catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
		unitIsRunning = 0;
		if (dcFilter) delete[] dcFilter;
	}
    
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute,&propertySize,&state);
    if ([(__bridge NSString *)state isEqualToString:@"HeadsetInOut"]) 
        mute = NO;
    else 
        mute = YES;
    
	return self;
}

- (int) send:(UInt8) data {
    
	if (newByte == FALSE) {
		// transmitter ready
		self.uartByteTransmit = data;
		newByte = TRUE;
		return 0;
	} else {
		return 1;
	}
}

- (void) fskSendData: (NSData *)data{
    self.dataToSend = data;
    self.dataSendIndex = 0;
    Byte *bytes = (Byte *)[data bytes];
    self.uartByteTransmit = (SInt8)bytes[0];
    newByte = TRUE;
}

- (void) unSetupRemoteIo{
    AudioOutputUnitStop(rioUnit);
    AudioUnitUninitialize(rioUnit);
}

- (void) setupRemoteIo{
    
    UInt32 sessionCategory =kAudioSessionCategory_PlayAndRecord;//设置后台播放
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,sizeof (sessionCategory), &sessionCategory);
    
    XThrowIfError(AudioUnitInitialize(rioUnit), "couldn't initialize the remote I/O unit");
    XThrowIfError(AudioOutputUnitStart(rioUnit), "couldn't start remote i/o unit");
    //XThrowIfError(SetupRemoteIO(rioUnit, inputProc, thruFormat), "couldn't setup remote i/o unit");
}

- (void)dealloc
{
    NSLog(@"%@", @"hijack delloc");
    AudioUnitUninitialize(rioUnit);
	delete[] dcFilter;
//	[super dealloc];
}


@end
