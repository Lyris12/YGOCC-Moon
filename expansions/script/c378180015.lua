--Novandroid's Struggle for Survival
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--Monsters on Field Check
function s.cfilter(c,e,tp)
	return c:IsSetCard(0xfaef) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	return  #g==1 and g:IsExists(s.cfilter,1,nil,1) 
end

--Draw Effect
function s.filter(c)
	local lv1=c:GetLevel()
	return lv1~=0 and c:IsSetCard(0xfaef)  and ((c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)) or c:IsLocation(LOCATION_GRAVE))
end
--Level Check
function s.checkfilter(c)
	local lv1=c:GetLevel()
	return lv1~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	local ct=g:GetClassCount(Card.GetLevel)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetChainLimit(aux.FALSE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	local ct=g:GetClassCount(Card.GetLevel)
	Duel.Draw(p,ct,REASON_EFFECT)
	-- no damages
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetCode(EFFECT_CHANGE_DAMAGE)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	ge1:SetTargetRange(0,1)
	ge1:SetValue(0)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	local ge2=ge1:Clone()
	ge2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	ge2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge2,tp)
	local c=e:GetHandler()
	--no ss from extra deck
	local ge3=Effect.CreateEffect(c)
	ge3:SetType(EFFECT_TYPE_FIELD)
	ge3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ge3:SetDescription(aux.Stringid(id,0))
	ge3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge3:SetReset(RESET_PHASE+PHASE_END)
	ge3:SetTargetRange(1,0)
	ge3:SetTarget(s.splimit)
	Duel.RegisterEffect(ge3,tp)
end


function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end