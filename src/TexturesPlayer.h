#ifndef _TEXTURES_PLAYER
#define _TEXTURES_PLAYER


class TexturesPlayer {

public:
	TexturesPlayer() {};
	virtual void setup(string setName) = 0;
	virtual void update() = 0;
	virtual void translate() = 0;
	virtual void draw() = 0;
	virtual void exit() = 0;
	
	virtual void play(int i) = 0;
	virtual void setPush(bool bPush) = 0;
	virtual void setState(int state) = 0;
	
	virtual void initIdle() = 0;
	virtual void loadIdle() = 0;
	virtual void unloadIdle() = 0;
	virtual void initIn() = 0;
	virtual void loadIn() = 0;
	virtual void unloadIn() = 0;
	virtual void initSet() = 0;
	virtual void loadSet() = 0;
	virtual void unloadSet() = 0;
	virtual void initOut() = 0;
	virtual void loadOut() = 0;
	virtual void unloadOut() = 0;
	virtual void release() = 0;
	
	
	//int sequencesNumber();
	virtual void startTransition(bool bPlayIn) = 0;
	virtual bool didTransitionEnd() = 0;
	virtual float getScale() = 0;
	
};

#endif