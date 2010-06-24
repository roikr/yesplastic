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
	virtual void setState(int state) = 0;
	
	virtual void initIn() = 0;
	virtual void prepareIn() = 0;
	virtual void initSet() = 0;
	virtual void prepareSet() = 0;
	virtual void prepareOut() = 0;
	virtual void finishOut() = 0;
	virtual void releaseSet() = 0;
	
	
	//int sequencesNumber();
	virtual void startTransition(bool bPlayIn) = 0;
	virtual bool didTransitionEnd() = 0;
	virtual float getScale() = 0;
	
};

#endif