runScriptFile("gameResource/script/objBase")
globalGameEnum = objBase:extend(
{

}
)
globalGameEnum.WINDOW_VERSION = 0
globalGameEnum.ANDROID_VERSION = 1

globalGameEnum.SCENE_ENUM_FIRST_GAME_SCENE = 0
globalGameEnum.SCENE_ENUM_CHOOSE_ROLE_SCENE = 1
globalGameEnum.SCENE_ENUM_GAME_SCENE = 2


globalGameEnum.currentGameVersion = globalGameEnum.WINDOW_VERSION

globalGameEnum.uiJsonFilePath = "gameResource/gameUIResource/"

globalGameEnum.CONFIGREADER_ENUM_MAINROLE = 0
globalGameEnum.CONFIGREADER_ENUM_NOROLE = 1

globalGameEnum.CONFIGREADER_ENUM_WHITE = 0
globalGameEnum.CONFIGREADER_ENUM_GREEN = 1
globalGameEnum.CONFIGREADER_ENUM_BLUE = 2
globalGameEnum.CONFIGREADER_ENUM_PURPLE = 3
globalGameEnum.CONFIGREADER_ENUM_GOLD = 4

globalGameEnum.CONFIGREADER_SCENE_CANSEE = 5
globalGameEnum.CONFIGREADER_SCENE_CANNOTSEE = 6

globalGameEnum.MOTION_HIT = 0
globalGameEnum.MOTION_ALERT = 1
globalGameEnum.MOTION_DEAD = 2
globalGameEnum.MOTION_DEFENCE = 3
globalGameEnum.MOTION_WALK = 6
globalGameEnum.MOTION_BACK = 7
globalGameEnum.MOTION_CONFURE = 9
globalGameEnum.MOTION_ATTACK0 = 4
globalGameEnum.MOTION_ATTACK1 = 5
globalGameEnum.MOTION_RUNTO = 8
globalGameEnum.MOTION_STANDING = 10
globalGameEnum.MOTION_EFFECT = 1

globalGameEnum.MotionPlayForever = "forever"
globalGameEnum.MotionPlayOnce = "once"

globalGameEnum.DIRECTION_RIGHTBOTTOM = 0
globalGameEnum.DIRECTION_LEFTBOTTOM = 1
globalGameEnum.DIRECTION_LEFTTOP = 2
globalGameEnum.DIRECTION_RIGHTTOP = 3
globalGameEnum.DIRECTION_BOTTOM = 4
globalGameEnum.DIRECTION_LEFT = 5
globalGameEnum.DIRECTION_TOP = 6
globalGameEnum.DIRECTION_RIGHT = 7
globalGameEnum.DIRECTION_EFFECT = 0

globalGameEnum.mainRoleId = nil

globalGameEnum.winWidth = 480
globalGameEnum.winHeight = 320

