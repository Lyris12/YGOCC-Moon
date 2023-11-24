--created by Jake, coded by Lyris
--Dawn-Eyes Kabuto Dragon
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetCondition(s.ddcon)
	e1:SetTarget(s.ddtg)
	e1:SetOperation(s.ddop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.reg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c,tc)
	return tc:GetLinkedGroup():IsContains(c) or c:IsLocation(LOCATION_SZONE)
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE,nil,e:GetHandler())
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetParam(ct)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,ct-1)
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(s.filter,p,LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE,nil,e:GetHandler())
	if Duel.Draw(p,ct,REASON_EFFECT)<1 then return end
	if ct>1 then
		Duel.ShuffleHand(p)
		Duel.DiscardHand(p,ct-1,ct-1,REASON_EFFECT+REASON_DISCARD)
	end
end
function s.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:IsPreviousControler(1-tp) then seq=seq+16 end
	return c:IsPreviousSetCard(0x613) c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:FilterCount(s.cfilter,nil,tp,e:GetHandler():GetLinkedZone())==1
end
function s.reg(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,0,0)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x613)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)-1
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetParam(ct)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,p,LOCATION_MZONE,0,nil)-1
	if ct>0 then Duel.Draw(p,ct,REASON_EFFECT) end
end
