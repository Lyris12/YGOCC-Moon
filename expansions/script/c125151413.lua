--created by LeonDuvall, coded by Lyris
--The Floating Village Atop Lake Exodice
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(s.dfilter))
	e2:SetValue(s.dval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(4179255)
	e5:SetCondition(s.spcon)
	c:RegisterEffect(e5)
end
function s.dfilter(c)
	return c:IsFaceupEx() and c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_FIEND)
end
function s.dval(e,c)
	return Duel.GetMatchingGroupCount(s.dfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ct<2 then return false end
	local tep,trc=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_RACE)
	local tloc=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_LOCATION)
	return tep==1-tp and trc&RACE_FISH>0 and tloc==LOCATION_GRAVE
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid,te=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID,CHAININFO_TRIGGERING_EFFECT)
	Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,1,cid)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffectLabel(0,id)==Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID) then return end
	Duel.NegateActivation(ev)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xd16) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local turnp=Duel.GetTurnPlayer()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		and (turnp==tp or Duel.IsPlayerCanDraw(tp,1)) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
	if turnp==1-tp then
		e:SetCategory(e:GetCategory()|CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else e:SetCategory(e:GetCategory()&~CATEGORY_DRAW) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)<1 or Duel.GetTurnPlayer()==tp then return end
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.spcon(e,tp,eg)
	return eg:IsContains(e:GetHandler())
end
