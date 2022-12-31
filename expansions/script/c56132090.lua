--Torrential Depths
--Script by APurpleApple
local s = c56132090
function s.initial_effect(c)
	aux.EnableChangeCode(c,22702055,LOCATION_ONFIELD)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetOperation(s.topdeck)
	c:RegisterEffect(e0)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(s.buffVal)
	c:RegisterEffect(e1)
	--Def
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE + CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetOperation(s.topdeck)
	c:RegisterEffect(e3)
end
function s.buffVal(e,c)
	local r = c:GetRace()
	local v = Duel.GetMatchingGroup(Card.IsFacedown, 0, LOCATION_REMOVED, LOCATION_REMOVED, nil):GetCount()
	if r == RACE_SEASERPENT then return v * 50 end
	return 0
end
function s.topdeck(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,1)
	t = Duel.GetDecktopGroup(tp,1):GetFirst()
	if t and t:IsAbleToGrave() and Duel.SelectOption(tp,1191,1192)==0 
	then
		Duel.SendtoGrave(t,REASON_EFFECT)
	else
		Duel.Remove(t,POS_FACEDOWN,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c)
	return not c:IsRace(RACE_SEASERPENT)
end