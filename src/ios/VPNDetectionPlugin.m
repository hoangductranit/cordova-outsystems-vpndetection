/********* VPNDetectionPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <sys/utsname.h>

@interface VPNDetectionPlugin : CDVPlugin
- (void)detectVPN:(CDVInvokedUrlCommand*)command;
@end

@implementation VPNDetectionPlugin

- (void)detectVPN:(CDVInvokedUrlCommand*)command
{

    NSString *jsonVPNs = [command argumentAtIndex:0];

    // If the JSON is empty or null, use the default value
    if (jsonVPNs == nil || [jsonVPNs isEqualToString:@""]) {
            jsonVPNs = @"[\"tap\",\"tun\",\"ppp\",\"ipsec\",\"utun\"]";
    }

    BOOL isVPNActive = [self isModerniOS] ? [self checkForVPNOnModerniOS:jsonVPNs] : [self checkForVPNOnLegacyiOS:jsonVPNs];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isVPNActive];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Function to check iOS version and determine if it's a modern iOS (>= iOS 10)
- (BOOL)isModerniOS {
    // iOS version check
    if (@available(iOS 10.0, *)) {
        return YES;
    }
    return NO;
}

// VPN Detection for Legacy iOS (pre-iOS 10)
- (BOOL)checkForVPNOnLegacyiOS:(NSString *)jsonVPNs
{
    // Remove brackets and quotes from the JSON string
    jsonVPNs = [jsonVPNs stringByReplacingOccurrencesOfString:@"[" withString:@""];
    jsonVPNs = [jsonVPNs stringByReplacingOccurrencesOfString:@"]" withString:@""];
    jsonVPNs = [jsonVPNs stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    NSArray * vpns = [jsonVPNs componentsSeparatedByString:@","];

    NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSDictionary *keys = dict[@"__SCOPED__"];

    for (NSString* key in keys.allKeys) {
        for(NSString* vpn in vpns){
            if([key containsString:vpn]){
                return true;
            }
        }
    }
    return false;
}

// VPN Detection for Modern iOS (iOS 10+)
- (BOOL)checkForVPNOnModerniOS:(NSString *)jsonVPNs
{
    // Remove brackets and quotes from the JSON string
    jsonVPNs = [jsonVPNs stringByReplacingOccurrencesOfString:@"[" withString:@""];
    jsonVPNs = [jsonVPNs stringByReplacingOccurrencesOfString:@"]" withString:@""];
    jsonVPNs = [jsonVPNs stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    NSArray * vpns = [jsonVPNs componentsSeparatedByString:@","];

    // Check active network interfaces for VPN-related identifiers
    NSDictionary *networkDict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSDictionary *scopedDict = networkDict[@"__SCOPED__"];

    // Check if any known VPN interface is active
    for (NSString *interface in scopedDict.allKeys) {
        for (NSString *vpn in vpns) {
            if ([interface containsString:vpn]) {
                return YES;
            }
        }
    }

    return NO;
}
@end
