#include "cocos2d.h"
#include "CCEGLView.h"
#include "AppDelegate.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "CCLuaEngine.h"
#else
#include "lua\cocos2dx_support\CCLuaEngine.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "Lua_extensions_CCB.h"
#else
#include "lua\cocos2dx_support\Lua_extensions_CCB.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "Lua_web_socket.h"
#else
#include "lua\cocos2dx_support\Lua_web_socket.h"
#endif
#endif


USING_NS_CC;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    //SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    CCDirector *pDirector = CCDirector::sharedDirector();
    pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());

    // turn on display FPS
    pDirector->setDisplayStats(false);

    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 60);
    
    // register lua engine
    CCLuaEngine* pEngine = CCLuaEngine::defaultEngine();
    CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);

    CCLuaStack *pStack = pEngine->getLuaStack();
    lua_State *tolua_s = pStack->getLuaState();
    tolua_extensions_ccb_open(tolua_s);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)    
    pStack = pEngine->getLuaStack();
    tolua_s = pStack->getLuaState();
    tolua_web_socket_open(tolua_s);
#endif
        
    std::vector<std::string> searchPaths;
    //searchPaths.push_back("gameConfig");
	//searchPaths.push_back("gameUIResource");
	//searchPaths.push_back("script");
	/*
    searchPaths.insert(searchPaths.begin(), "scenetest/ArmatureComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/AttributeComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/BackgroundComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/EffectComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/LoadSceneEdtiorFileTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/ParticleComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/SpriteComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/TmxMapComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/UIComponentTest");
    searchPaths.insert(searchPaths.begin(), "scenetest/TriggerTest");
	*/
#if CC_TARGET_PLATFORM == CC_PLATFORM_BLACKBERRY
    searchPaths.push_back("TestCppResources");
    searchPaths.push_back("script");
#endif
    CCFileUtils::sharedFileUtils()->setSearchPaths(searchPaths);

    pEngine->executeScriptFile("gameResource/script/main.lua");
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	CCEGLView* eglView = CCEGLView::sharedOpenGLView();
	eglView->setDesignResolutionSize(480,320,kResolutionShowAll);
#endif
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    CCDirector::sharedDirector()->stopAnimation();

    //SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    CCDirector::sharedDirector()->startAnimation();

    //SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}