#ifndef _MIDI_TRACK
#define _MIDI_TRACK

#import <string> // for iPhone
#import <vector>
#import <queue>
#import <map>

using namespace std;

class TexturesPlayer;
class ofxRKAQSoundPlayer;
class ofxXmlSettings;

struct sample{
	
	int num;
	vector<sample*> cutoff;	
	bool all_cutoff;
	
};

struct event{
	int time;
	int note;
	int velocity;
};

struct loop{
	vector<event> events;
	int numTicks;
};
	

class MidiTrack {
public:
	MidiTrack() {};

	void setup(int playerNum);
	void setTexturesPlayer(TexturesPlayer *texturesPlayer);
	//void start();
	void update();
	void exit();
	
	void setVolume(float volume); //  0.0 to 1.0
	float getVolume();
	void playMidi(int time,int midiNote,int velocity);
	void play(int num);
	
	void changeLoop(int loopNum);
	
	void addEvent(int time,int note,int velocity);
	
	void releaseSoundSet();
	void loadSoundSet(string soundSet);
	void loadLoopFinished();
	void setupSoundSet();
	
	string getCurrentSoundSet();
	
	string getCurrentVideoSet();
	
	
	void setMode(int mode,bool reset);
	int getMode();
	
	static void Init();
	static void SetBPM(int bpmVal);
	static int GetBPM();
	static void UpdateTicks();
	static void SetSongMode(int songMode);
	static int GetSongMode();
	bool isSongDone();
	void setupSong();

	int getCurrentLoop();
	
	static int currentTick;
	static int loopTick;
	
	void addMidiToXML(ofxXmlSettings *xml);

private:
	void seekPlayhead();
	void record(int midiNote);
		
	static int startTime;
	static int startTick;
	static float ticksForMS;
	static int songMode; 
	static int bpm;
	
	string soundSet;
	string prefix;
	string videoSet;
	
	
	bool multi;
	
	
	
	map<int,int> keyToMidi;
	map<int,int> midiToSample;
	
	void loadLoop(string filename);
	
	vector<loop> loops;
	vector<loop>::iterator currentLoop;
	vector<event>::iterator playhead;
	vector<event> song;
	vector<event>::iterator songhead;
	
	int lastPlayed;

	TexturesPlayer *texturesPlayer;
	
	float volume;
	bool enable;

	queue<pair<int,int> > animations;
	//vector<int> priorities; // ticks trick
	
	
	
	ofxRKAQSoundPlayer* midiInstrument;
	
	int mode;
	int playerNum;
};

#endif