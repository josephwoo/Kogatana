//
//  Kogatana-prefix.h
//  Kogatana
//
//  Created by Joe 楠 on 28/09/2017.
//

#ifndef Kogatana_prefix_h
#define Kogatana_prefix_h

static const int KOGLogPort = 7579; // "KO" 's ASCII = 75,79

#define within_main_thread(block,...) \
try {} @finally {} \
do { \
if ([[NSThread currentThread] isMainThread]) { \
if (block) { \
block(__VA_ARGS__); \
} \
} else { \
if (block) { \
dispatch_async(dispatch_get_main_queue(), ^(){ \
block(__VA_ARGS__); \
}); \
} \
} \
} while(0)

#endif /* Kogatana_prefix_h */
