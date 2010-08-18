#ifndef _CONSTANTS
#define _CONSTANTS

#define FRAME_RATE 25

//#define SUB_TEXTURE_WIDTH 320
//#define SUB_TEXTURE_HEIGHT 480
#define TEXTURE_WIDTH 1024
#define TEXTURE_HEIGHT 1024
//#define COLUMN_FRACTION  (320.0/1024.0)
//#define ROW_FRACTION (480.0/1024.0)

//#define TEXTURE_CAPACITY 6

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 480

enum {
	SOLO_STATE,
	BAND_STATE,
};


enum {
	MANUAL_MODE,
	LOOP_MODE
};

enum {
	SONG_IDLE,
	SONG_RECORD,
	SONG_PLAY,
	SONG_RENDER_AUDIO
};

enum {
	TRANSITION_IDLE,
	TRANSITION_SETUP,
	TRANSITION_SETUP_FINISHED,
	TRANSITION_RELEASE_SET,
	TRANSITION_RELEASE_SET_FINISHED,
	TRANSITION_INIT_IN,
	TRANSITION_INIT_IN_FINISHED,
	TRANSITION_PLAYING_OUT,
	TRANSITION_PLAYING_IN,
	TRANSITION_INIT_SET,
	TRANSITION_INIT_SET_FINISHED,
	TRANSITION_CHANGE_SOUND_SET,
	TRANSITION_CHANGE_SOUND_SET_FINISHED
};

#endif 